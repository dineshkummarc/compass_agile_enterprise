class Blog < WebsiteSection
  
  def find_blog_posts
    Article.find_by_website_section_id(self.id).sort_by{|article| article.created_at}.reverse
  end

  def find_published_blog_posts(active_publication)
    Article.find_published_by_section(active_publication, self).sort_by{|article| article.created_at}.reverse
  end

  def find_blog_post(permalink)
    Article.find(
      :first,
      :joins => "INNER JOIN website_section_contents ON website_section_contents.content_id = contents.id",
      :conditions => ['website_section_contents.website_section_id = ? and permalink = ?',self.id, permalink])
  end

  def find_published_blog_post(active_publication, permalink)
    Article.find_published_by_section(active_publication, self).find{|item| item.permalink == permalink}
  end
end
