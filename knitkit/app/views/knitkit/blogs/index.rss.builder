xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @blog.title
    xml.description @blog.title
    
    if params[:action] == 'tag'
      xml.link main_app.blog_tag_url(params[:section_id], params[:tag_id], :rss)
    else
      xml.link main_app.blogs_url(params[:section_id], :rss)
    end
    
    for article in @contents
      xml.item do
        xml.title article.title
        xml.description article.excerpt_html
        xml.pubDate article.created_at.to_s(:rfc822)
        xml.link main_app.blog_article_url(params[:section_id], article.permalink)
        xml.guid main_app.blog_article_url(params[:section_id], article.permalink)
      end
    end
  end
end