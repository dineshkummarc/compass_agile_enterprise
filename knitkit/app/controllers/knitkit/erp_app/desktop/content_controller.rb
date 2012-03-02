module Knitkit
  module ErpApp
    module Desktop
      
      class ContentController < Knitkit::ErpApp::Desktop::AppController
        def update
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'edit_html', 'Article') do
              id      = params[:id]
              html    = params[:html]
              content = Content.find(id)
              content.body_html = html
    
              render :json => (content.save ? {:success => true} : {:success => false})
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def save_excerpt
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'edit_excerpt', 'Article') do
              id      = params[:id]
              html    = params[:html]
              content = Content.find(id)
              content.excerpt_html = html
        
              render :json => (content.save ? {:success => true} : {:success => false})
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

      end#ContentController
    end#Desktop
  end#ErpApp
end#Knitkit
