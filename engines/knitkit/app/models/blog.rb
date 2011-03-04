class Blog < Section
  
  def find_blog_posts
    Article.find_by_section_id(self.id).sort_by{|article| article.created_at}.reverse
  end

  def find_published_blog_posts(site)
    Article.find_published_by_site_section(site, self).sort_by{|article| article.created_at}.reverse
  end

  def find_blog_post(permalink)
    Article.find(
      :first,
      :joins => "INNER JOIN section_contents ON section_contents.content_id = contents.id",
      :conditions => ['section_contents.section_id = ? and permalink = ?',self.id, permalink])
  end

  def find_published_blog_post(site, permalink)
    Article.find_published_by_site_section(site, self).find{|item| item.permalink == permalink}
  end
end
