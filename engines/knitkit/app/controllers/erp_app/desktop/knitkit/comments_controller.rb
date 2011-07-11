class ErpApp::Desktop::Knitkit::CommentsController < ErpApp::Desktop::Knitkit::BaseController
  def get
    Comment.include_root_in_json = false

    content = Content.find(params[:content_id])
    sort  = params[:sort] || 'created_at'
    dir   = params[:dir] || 'DESC'
    limit = params[:limit] || 10
    start = params[:start] || 0

    Comment.class_eval do
      def approved_by_username
        approved_by.nil? ? '' : approved_by.login
      end
    end

    comments = content.comments.recent.find(:all, :order => "#{sort} #{dir}", :limit => limit, :offset => start)

    render :inline => "{totalCount:#{content.comments.count}, comments:#{comments.to_json(:methods => [:approved?, :approved_by_username])}}"
  end

  def approve
    comment = Comment.find(params[:id])

    comment.approve(current_user)

    render :inline => {:success => true}.to_json
  end

  def delete
    comment = Comment.find(params[:id])
    comment.destroy
    render :inline => {:success => true}.to_json
  end
end
