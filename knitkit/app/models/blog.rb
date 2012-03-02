class Blog < WebsiteSection
  def find_blog_posts
    Article.find_by_website_section_id(self.id).sort_by{|article| article.created_at}.reverse
  end

  def find_published_blog_posts(active_publication)
    Article.find_published_by_section(active_publication, self).sort_by{|article| article.created_at}.reverse
  end

  def find_published_blog_posts_with_tag(active_publication, tag)
    Article.find_published_by_section_with_tag(active_publication, self, tag).sort_by{|article| article.created_at}.reverse
  end

  def find_blog_post(permalink)
    Article.joins(:website_section_contents).where('website_section_contents.website_section_id = ? and permalink = ?',self.id, permalink).first
  end

  def find_published_blog_post(active_publication, permalink)
    Article.find_published_by_section(active_publication, self).find{|item| item.permalink == permalink}
  end
end
