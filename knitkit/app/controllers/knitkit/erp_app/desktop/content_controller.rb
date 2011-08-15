module Knitkit
  module ErpApp
    module Desktop
      class ContentController < Knitkit::ErpApp::Desktop::AppController
         def update
          id      = params[:id]
          html    = params[:html]
          result = {}
          content = Content.find(id)
          content.body_html = html
          if content.save
            result[:success] = true
          else
            result[:success] = false
          end

          render :inline => result.to_json
        end

        def save_excerpt
          id      = params[:id]
          html    = params[:html]
          result = {}
          content = Content.find(id)
          content.excerpt_html = html
          if content.save
            result[:success] = true
          else
            result[:success] = false
          end

          render :inline => result.to_json
        end
      end
    end
  end
end
