class CommentsController < BaseController
  def add
    user    = current_user
    website_section = WebsiteSection.find(params[:section_id])
    content = Content.find(params[:content_id])
    comment = params[:comment]

    content.add_comment({:commentor_name => user.party.description, :email => user.email, :comment => comment})

    redirect_to "/#{website_section.permalink}/#{content.permalink}"
  end

  #no section to set
  def set_section
    return false
  end
end
