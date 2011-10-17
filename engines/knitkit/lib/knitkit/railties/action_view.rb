ActionView::Base.class_eval do
  
  # render a piece of content by permalink regardless if it belongs to a section or not
  def render_content(iid)
    content = Content.find_by_internal_identifier(iid)
    content_version = Content.get_published_version(@active_publication, content)
    content_version.body_html.nil? ? '' : content_version.body_html
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
  
  def menu_item_selected(menu_item)
    result = false
    result = request.path == menu_item.path
    unless result
      menu_item.descendants.each do |child|
        result = request.path == child.path
        break if result
      end
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
  #section_unique_name
  # - sections permalink to start breadcrumbs at
  def build_crumbs(options={})
    links = []
    if options[:menu]
      menu = WebsiteNav.find_by_name(options[:menu])
      raise "Menu with name #{options[:menu]} does not exist" if menu.nil?
      menu_item = menu.website_nav_items.find(:first, :conditions => ["title = ?", options[:menu_item]])
      raise "Menu Item with Title #{options[:menu]} does not exist" if menu_item.nil?
      links = menu_item.self_and_ancestors.map{|child| {:url => child.path, :title => child.title}}
    elsif options[:section_unique_name]
      section = WebsiteSection.find_by_internal_identifier(options[:section_unique_name])
      raise "Website Section with that unique name does not exist" if section.nil?
      links = section.self_and_ancestors.map{|child| {:url => child.path, :title => child.title}}
    else
      links = @website_section.self_and_ancestors.collect{|child| {:url => child.path, :title => child.title}}
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
      locals[:menu_items] = menu.website_nav_items.positioned
    else
      layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/default_section_menu"
    end

    render :partial => layout, :locals => locals
  end

  #options
  #menu
  # - use a designed layout not sections
  #menu_item
  # - menu item title to start at
  #section_unique_name
  # - section to begin at
  #layout
  # - use defined layout
  def render_sub_menu(contents, options={})
    locals = {:contents => contents}
    if options[:menu]
      menu = WebsiteNav.find_by_name(options[:menu])
      raise "Menu with name #{options[:menu]} does not exist" if menu.nil?
      locals[:menu_items] = (options[:menu_item].nil? ? menu.all_menu_items.find{|item| menu_item_selected(item)}.positioned_children : menu.all_menu_items.find{|item| item.title = options[:menu_item]}.positioned_children) 
      raise "No menu items exist" if locals[:menu_items].nil?
      layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/default_sub_menu"
    else
      section = options[:section_unique_name].nil? ? @website_section : WebsiteSection.find_by_internal_identifier(options[:section_unique_name])
      raise "No website sections exist" if section.nil?
      locals[:section] = section
      layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/default_sub_section_menu"
    end
    
    render :partial => layout, :locals => locals
  end
end
