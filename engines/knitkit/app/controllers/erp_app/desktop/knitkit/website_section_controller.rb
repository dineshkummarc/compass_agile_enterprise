class ErpApp::Desktop::Knitkit::WebsiteSectionController < ErpApp::Desktop::Knitkit::BaseController
  before_filter :set_website_section, :only => [:update, :update_security, :add_layout, :get_layout, :save_layout]

  def new
    ignored_params = %w{action controller websiteId website_section_id in_menu}

    website = nil
    website_section = nil

    result = {}
    if (params[:title] == 'Blog' || params[:title] == 'blog') && params[:type] == 'Blog'
      result[:sucess] = false
      result[:msg] = 'Blog can not be the title of a Blog'
    else
      website_section = WebsiteSection.new
      params.each do |k,v|
        next if k == 'type' && v == 'Page'
        website_section.send(k + '=', v) unless ignored_params.include?(k.to_s)
      end
      website_section.in_menu = params[:in_menu] == 'yes'
      
      if website_section.save
        unless params[:websiteId].blank?
          website = Website.find(params[:websiteId])
          website.website_sections << website_section
          website.save
        else
          parent_website_section = WebsiteSection.find(params[:website_section_id])
          website = parent_website_section.website
          website.website_sections << website_section
          website.save
          website_section.move_to_child_of(parent_website_section)
          parent_website_section.save
        end
        
        result[:success] = true
        result[:node] = build_section_hash(website_section, website_section.website)
      else
        result[:success] = false
      end

    end

    render :inline => result.to_json

  end

  def delete
    WebsiteSection.destroy(params[:id])
    render :inline => {:success => true}.to_json
  end

  def update_security
    website = Website.find(params[:site_id])
    if(params[:secure] == "true")
      @website_section.add_role(website.role)
    else
      @website_section.remove_role(website.role)
    end

    render :inline => {:success => true}.to_json
  end

  def update
    @website_section.in_menu = params[:in_menu] == 'yes'
    @website_section.title = params[:title]
    @website_section.save

    render :inline => {:success => true}.to_json
  end

  def add_layout
    @website_section.create_layout
    render :inline => {:success => true}.to_json
  end

  def get_layout
    render :text => @website_section.layout
  end
  
  def save_layout
    @website_section.layout = params[:content]
    
    if @website_section.save
      render :inline => {:success => true}.to_json
    else
      render :inline => {:success => false}.to_json
    end
  end

  def available_articles
    current_articles = Article.find(:all,
        :joins => "INNER JOIN website_section_contents ON website_section_contents.content_id = contents.id",
      :conditions => "website_section_id = #{params[:section_id]}")

    available_articles = Article.all - current_articles

    render :inline => available_articles.to_json(:only => [:title, :id])
  end
  
  def existing_sections
    WebsiteSection.include_root_in_json = false

    website = Website.find(params[:website_id])
    WebsiteSection.class_eval do
      def title_permalink
        "#{self.title} - #{self.full_path}"
      end
    end
    render :inline => website.all_sections.to_json(:only => [:id], :methods => [:title_permalink])
  end
  
  protected
  
  def set_website_section
    @website_section = WebsiteSection.find(params[:id])
  end
  
end
