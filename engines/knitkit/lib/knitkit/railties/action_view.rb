ActionView::Base.class_eval do
  def render_content(name)
    html = ''
    contents = @website_section.contents.select{|item| item.content_area == name.to_s}
    published_contents = []
    contents.each do |content|
      content_version = Content.get_published_verison(@website, content)
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
end
