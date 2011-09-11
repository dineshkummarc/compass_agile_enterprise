module Knitkit
  module ErpApp
    module Desktop
      class ContentController < Knitkit::ErpApp::Desktop::AppController
         def update
          id      = params[:id]
          html    = params[:html]
          content = Content.find(id)
          content.body_html = html
    
          render :json => content.save ? {:success => true} : {:success => false}
        end

        def save_excerpt
          id      = params[:id]
          html    = params[:html]
          result = {}
          content = Content.find(id)
          content.excerpt_html = html
        
          render :json => content.save ? {:success => true} : {:success => false}
        end
      end
    end
  end
end
