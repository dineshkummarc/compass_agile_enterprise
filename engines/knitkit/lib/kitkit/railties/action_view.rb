ActionView::Base.class_eval do
  def render_content(name)
    html = ''
    contents = @section.contents.select{|item| item.content_area == name.to_s}
    contents = contents.sort_by{|content| content.position(@section.id).blank? ? 0 : content.position(@section.id) }
    contents.each do |content|
      body_html = content.body_html.nil? ? '' : content.body_html
      html << body_html
    end

    html
  end
end
