module Knitkit
  class CommentsController < BaseController
    def add
      user    = current_user
      content = Content.find(params[:content_id])
      comment = params[:comment]

      @comment = content.add_comment({:commentor_name => user.party.description, :email => user.email, :comment => comment})

      render :text => (@comment.valid? ? '<div class="sexysuccess">Comment pending approval.</span>' : '<div class="sexyerror">Error. Comment cannot be blank.</span>')
    end

    #no section to set
    def set_section
      return false
    end
  end
end
