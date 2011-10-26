module Knitkit
  module ErpApp
    module Desktop
      class CommentsController < Knitkit::ErpApp::Desktop::AppController
        
        def index
          content = Content.find(params[:content_id])
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || 'created_at'
          dir  = sort_hash[:direction] || 'DESC'
          limit = params[:limit] || 10
          start = params[:start] || 0

          Comment.class_eval do
            def approved_by_username
              approved_by.nil? ? '' : approved_by.username
            end
          end
          
          #limit and offset are not working rails issue?
          comments = content.comments.order("#{sort} #{dir}").offset(start).limit(limit)
    
          render :inline => "{totalCount:#{comments.count}, comments:#{comments.to_json(:methods => [:approved?, :approved_by_username])}}"
        end

        def approve
          comment = Comment.find(params[:id])
          comment.approve(current_user)
          
          render :json => {:success => true}
        end

        def delete
          comment = Comment.find(params[:id])
          comment.destroy
          
          render :json => {:success => true}
        end

      end#CommentsController
    end#Desktop
  end#ErpApp
end#Knitkit
