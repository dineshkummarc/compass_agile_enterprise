class ErpApp::Desktop::Knitkit::WebsiteSectionController < ErpApp::Desktop::Knitkit::BaseController
  IGNORED_PARAMS = %w{action controller node_id}

  before_filter :set_website_section, :only => [:update_security, :add_layout, :get_layout, :save_layout]

  def new
    result = {}
    if (params[:title] == 'Blog' || params[:title] == 'blog') && params[:type] == 'Blog'
      result[:sucess] = false
      result[:msg] = 'Blog can not be the title of a Blog'
    else
      website_section = WebsiteSection.new
      params.each do |k,v|
        next if k == 'type' && v == 'Page'
        website_section.send(k + '=', v) unless IGNORED_PARAMS.include?(k.to_s)
      end
      save_result = website_section.save

      if save_result
        node_id = params[:node_id]
        type = node_id.split('_')[0]
        id   = node_id.split('_')[1]

        if type == 'section'
          parent = Section.find(id)
          website_section.move_to_child_of(parent)
        else
          website = Website.find(id)
          website.website_sections << website_section
          website.save
        end

        result[:success] = true
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
  
  protected
  
  def set_website_section
    @website_section = WebsiteSection.find(params[:id])
  end
  
end
