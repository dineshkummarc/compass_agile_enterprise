class BlogsController < ArticlesController
  def index
    @blog = Blog.find(params[:section_id])
    @contents = @blog.find_blog_posts

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contents }
    end
  end

  def show
    @blog = Blog.find(params[:section_id])
    @content = @blog.find_blog_post(params[:id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @content }
    end
  end
end
