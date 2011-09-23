ActionView::Base.class_eval do

  def published_content_created_by
    "by #{@published_content.content.created_by.username}" rescue ''
  end

  def blog_add_comment_form
    render :partial => 'add_comment' unless current_user.nil?
  end  

  def blog_topics(css_class='tag_link')
    html = ''
    
    @website_section.get_topics.each do |tag|
      html += '<div class="'+tag_link+'">'+
      html += link_to(tag.name, main_app.blog_tag_path(@website_section.id, tag.id))
      html += '</div>'
    end
    
    raw html
  end
  

  def blog_rss_links(link_title='RSS Feed')
    if params[:action] == 'tag'
      return link_to link_title, main_app.blog_tag_url(params[:section_id], params[:tag_id], :rss)
    else
      return link_to link_title, main_app.blogs_url(params[:section_id], :rss)
    end
  end

  def blog_recent_approved_comments
    if @published_content.content.comments.recent.approved.empty?
      return 'No Comments'
    else
      html = ''
      
      @published_content.content.comments.recent.approved.each do |comment|
        html += render :partial => 'comment', :locals => {:comment => comment}
      end
      
      return raw html
    end
  end

  def blog_pagination(css_class, params)
    return will_paginate @contents, :class => css_class, :params => { 
                                                                :section_id => params[:section_id],                                            
                                                                :per_page => params[:per_page],
                                                                :format => params[:format],
                                                                :only_path => true,
                                                                :use_route => params[:use_route],
                                                                :scope => main_app
                                                              }    
  end
  
  # render a piece of content by permalink regardless if it belongs to a section or not
  def render_content(permalink)
    content = Content.find_by_permalink(permalink.to_s)
    content_version = Content.get_published_version(@active_publication, content)
    raw content.body_html.nil? ? '' : content.body_html
  end

  def render_content_area(name)
    html = ''
    
    section_contents = WebsiteSectionContent.joins(:content).where('website_section_id = ? and content_area = ?', @website_section.id, name.to_s).order('position')
    published_contents = []
    section_contents.each do |sc|
      content_version = Content.get_published_version(@active_publication, sc.content)
      published_contents << content_version unless content_version.nil?    
    end
    
    html = published_contents.collect do |content|
      content.body_html.nil? ? '' : content.body_html
    end.join('')

    raw html
  end

  def render_version_viewing
    html = ''

    if !session[:website_version].blank? && !session[:website_version].empty?
      site_version_hash = session[:website_version].find{|item| item[:website_id] == @website.id}
      unless site_version_hash.nil?
        if site_version_hash[:version].to_f != @website.active_publication.version
          html = "<div style='float:left;'>Viewing version #{site_version_hash[:version].to_f} <a href='/view_current_publication'>View current publication</a></div>"
        end
      end
    end

    raw html
  end

  def render_menu(contents, options=nil)
    active_theme = @website.themes.active.first unless @website.themes.active.empty?
    if !options.nil? && !options[:name].blank?
      menu = WebsiteNav.find_by_name(options[:name].to_s)
      raise "Menu with name #{options[:name]} does not exist" if menu.nil?
      if !active_theme.nil? && active_theme.has_template?('templates/menus/knitkit', "_#{options[:name]}.html.erb")
        render :partial => "menus/knitkit/#{options[:name]}", :locals => {:menu => menu}
      else
        render :partial => "menus/knitkit/default", :locals => {:menu => menu}
      end
    else
      render :partial => "shared/knitkit/default_section_menu", :locals => {:contents => contents}
    end
  end
end
