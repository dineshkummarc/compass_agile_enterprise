module Knitkit
class CommentsController < BaseController
  def add
    user    = current_user
    website_section = WebsiteSection.find(params[:section_id])
    content = Content.find(params[:content_id])
    comment = params[:comment]

    @comment = content.add_comment({:commentor_name => user.party.description, :email => user.email, :comment => comment})

    if @comment.valid?
      render :text => '<div class="sexysuccess">Comment pending approval.</span>'
    else
      render :text => '<div class="sexyerror">Error. Comment cannot be blank.</span>'
    end
  end

  #no section to set
  def set_section
    return false
  end
end
end
