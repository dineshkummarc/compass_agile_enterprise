ActionView::Base.class_eval do
  def render_content(name)
    html = ''
    contents = @section.contents.select{|item| item.content_area == name.to_s}
    published_contents = []
    contents.each do |content|
      content_version = Content.get_published_verison(@site, content)
      published_contents << content_version unless content_version.nil?
    end

    contents = published_contents.sort_by{|content_version| content_version.content.position(@section.id).blank? ? 0 : content_version.content.position(@section.id) }
    contents.each do |content|
      body_html = content.body_html.nil? ? '' : content.body_html
      html << body_html
    end

    html
  end
end
