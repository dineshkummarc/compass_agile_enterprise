ActionView::Base.class_eval do

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
