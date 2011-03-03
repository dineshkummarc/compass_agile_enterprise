class Blog < Section
  
  def find_blog_posts
    Article.find_by_section_id(self.id).sort_by{|article| article.created_at}.reverse
  end

  def find_blog_post(permalink)
    Article.find(
      :first,
      :joins => "INNER JOIN section_contents ON section_contents.content_id = contents.id",
      :conditions => ['section_contents.section_id = ? and permalink = ?',self.id, permalink])
  end
end
