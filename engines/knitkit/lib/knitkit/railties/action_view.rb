ActionView::Base.class_eval do
  def render_content(name)
    html = ''
    contents = @website_section.contents.select{|item| item.content_area == name.to_s}
    published_contents = []
    contents.each do |content|
      content_version = Content.get_published_verison(@active_publication, content)
      published_contents << content_version unless content_version.nil?
    end

    contents = published_contents.sort_by{|content_version| content_version.content.position(@website_section.id).blank? ? 0 : content_version.content.position(@website_section.id) }
    contents.each do |content|
      body_html = content.body_html.nil? ? '' : content.body_html
      html << body_html
    end

    html
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

    html
  end

  def render_menu(contents, options=nil)
    active_theme = @website.themes.active.first unless @website.themes.active.empty?
    if !options.nil? && !options[:name].blank?
      menu = WebsiteNav.find_by_name(options[:name].to_s)
      raise "Menu with name #{options[:name]} does not exist" if menu.nil?
      if !active_theme.nil? && active_theme.has_template?('templates/menus', "_#{options[:name]}.html.erb")
        render :partial => "menus/#{options[:name]}", :locals => {:menu => menu}
      else
        render :partial => "menus/default", :locals => {:menu => menu}
      end
    else
      render :partial => "shared/default_section_menu", :locals => {:contents => contents}
    end
  end
end
