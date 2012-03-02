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
      html += '<div class="'+css_class+'">'
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

  # render a piece of content by internal identifier regardless if it belongs to a section or not
  def render_content(iid)
    content = Content.find_by_internal_identifier(iid)
    content_version = Content.get_published_version(@active_publication, content) unless @active_publication.nil?
    content_version = content if @active_publication.nil? or content_version.nil?

    if content_version.nil?
      return ''
    else
      return raw content_version.body_html.nil? ? '' : content_version.body_html
    end
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

    render :partial => 'shared/knitkit/bread_crumb', :locals => {:links => links}
  end
  #options
  #menu
  # - use a designed layout not sections
  #layout
  # - use defined layout
  def render_menu(contents, options={})
    locals = {:contents => contents}
    if options[:menu]
      menu = WebsiteNav.find_by_name_and_website_id(options[:menu], @website.id)
      raise "Menu with name #{options[:menu]} does not exist" if menu.nil?
      layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/knitkit/default_menu"
      locals[:menu_items] = menu.website_nav_items.positioned
    else
      layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/knitkit/default_section_menu"
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
      menu = WebsiteNav.find_by_name_and_website_id(options[:menu], @website.id)
      raise "Menu with name #{options[:menu]} does not exist" if menu.nil?
      locals[:menu_items] = (options[:menu_item].nil? ? menu.all_menu_items.find{|item| menu_item_selected(item)}.positioned_children : menu.all_menu_items.find{|item| item.title = options[:menu_item]}.positioned_children)
      raise "No menu items exist" if locals[:menu_items].nil?
      layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/knitkit/default_sub_menu"
    else
      section = options[:section_unique_name].nil? ? @website_section : WebsiteSection.find_by_internal_identifier(options[:section_unique_name])
      raise "No website sections exist" if section.nil?
      locals[:section] = section
      layout = options[:layout] ? "menus/#{options[:layout]}" : "menus/knitkit/default_sub_section_menu"
    end

    render :partial => layout, :locals => locals
  end

  def tool_tip(message, img_src=nil)
    img_src = img_src || '/images/knitkit/tooltip.gif'
    raw "<a href='#' class='tooltip'>&nbsp;<img src='#{img_src}' alt='ToolTip' /><span>#{message}</span></a>"
  end

end
