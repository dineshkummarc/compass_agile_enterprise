class BlogsController < ArticlesController
  def index
    @blog = Blog.find(params[:section_id])
    @contents = @blog.find_published_blog_posts(@active_publication)
  end

  def show
    @blog = Blog.find(params[:section_id])
    @published_content = @blog.find_published_blog_post(@active_publication, params[:id])
  end
end
