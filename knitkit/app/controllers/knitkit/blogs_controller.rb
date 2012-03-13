module Knitkit
  class BlogsController < BaseController
    PER_PAGE = 10
  
    def index
      @blog = Blog.find(@website_section.id)
      params[:use_route] = 'blogs'
    
      @contents = @blog.find_published_blog_posts(@active_publication).paginate(:page => params[:page], :per_page => PER_PAGE)
    end

    def tag
      @blog = Blog.find(@website_section.id)
      @tag = ActsAsTaggableOn::Tag.find(params[:tag_id])
      params[:use_route] = 'blog_tag'

      @contents = @blog.find_published_blog_posts_with_tag(@active_publication, @tag).paginate(:page => params[:page], :per_page => PER_PAGE)
    
      render :index
    end

    def show
      @blog = Blog.find(@website_section.id)
      @published_content = @blog.find_published_blog_post(@active_publication, params[:id])
    end
  end
end
