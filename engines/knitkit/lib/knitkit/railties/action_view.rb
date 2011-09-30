ActionView::Base.class_eval do
  
  # render a piece of content by permalink regardless if it belongs to a section or not
  def render_content(permalink)
    content = Content.find_by_permalink(permalink.to_s)
    content_version = Content.get_published_version(@active_publication, content)
    body_html = content.body_html.nil? ? '' : content.body_html
    
    body_html
  end

  def render_content_area(name)
    html = ''
    
    section_contents = WebsiteSectionContent.find(:all,
      :joins => :content,
      :conditions => {
        :website_section_id => @website_section.id,
        :content_area => name.to_s },
      :order => :position )
      
    published_contents = []
    section_contents.each do |sc|
      content_version = Content.get_published_version(@active_publication, sc.content)
      published_contents << content_version unless content_version.nil?    
    end
    
    published_contents.each do |content|
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
  
  def menu_item_selected(menu_item, check_referer=false)
    result = false
    url = menu_item.url.index('/') == 0 ? menu_item.url : "/#{menu_item.url}"
    result = request.path == url 
    if !result and check_referer
      referer = URI::parse(request.referer)
      result = referer.path == url
    end
    result
  end

  #options
  #nothing
  # - uses current page to lookup section and go up tree
  #menu
  # - menu to look for menu title in
  #menu_item
  # - title of menu_item to start breadcrumbs at
  #section_permalink
  # - sections permalink to start breadcrumbs at
  def build_crumbs(options={})
    links = []
    if options[:menu]
      menu = WebsiteNav.find_by_name(options[:menu])
      raise "Menu with name #{options[:menu]} does not exist" if menu.nil?
      menu_item = menu.website_nav_items.find(:first, :conditions => ["title = ?", options[:menu_item]])
      raise "Menu Item with Title #{options[:menu]} does not exist" if menu_item.nil?
      links = menu_item.self_and_ancestors.map{|child| {:url => child.menu_url, :title => child.title}}
    elsif options[:section_permalink]
      section = WebsiteSection.find_by_permalink(options[:section_permalink])
      raise "Website Section with that permalink does not exist" if section.nil?
      links = section.self_and_ancestors.map{|child| {:url => child.permalink, :title => child.title}}
    else
      links = @website_section.self_and_ancestors.map{|child| {:url => child.permalink, :title => child.title}}
    end
    links

    render :partial => 'shared/bread_crumb', :locals => {:links => links}
  end
  #options
  #menu
  # - use a designed layout not sections
  #layout
  # - use defined layout
  def render_menu(contents, options={})
    locals = {:contents => contents}
    if options[:menu]
      menu = WebsiteNav.find_by_name(options[:menu])
      raise "Menu with name #{options[:menu]} does not exist" if menu.nil?
      layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/default_menu"
      locals[:menu] = menu
    else
      layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/default_section_menu"
    end

    render :partial => layout, :locals => locals
  end

  #options
  #menu
  # - use a designed layout not sections
  #layout
  # - use defined layout
  def render_sub_menu(contents, start, options={})
    locals = {:contents => contents}
    if options[:menu]
      menu = WebsiteNav.find_by_name(options[:menu])
      raise "Menu with name #{options[:menu]} does not exist" if menu.nil?
      menu_item = menu.website_nav_items.find(:first, :conditions => ["title = ?", start])
      raise "Menu Item with Title #{start} does not exist" if menu_item.nil?
      locals[:menu_item] = menu_item
      layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/default_sub_menu"
    else
      section = WebsiteSection.find_by_permalink(start)
      raise "Website Section with that permalink does not exist" if section.nil?
      locals[:section] = section
      layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/default_sub_section_menu"
    end
    
    render :partial => layout, :locals => locals
  end
end
