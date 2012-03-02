module Knitkit
  module ErpApp
    module Desktop
      class PositionController < Knitkit::ErpApp::Desktop::AppController
        
        def update
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'drag_item', 'WebsiteTree') do

              params[:position_array].each do |position|
                model = position['klass'].constantize.find(position['id'])
                model.position = position['position'].to_i
                model.save
              end

              render :json => {:success => true}
              
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end
        
      end#PositionController
    end#Desktop
  end#ErpApp
end#Knitkit

