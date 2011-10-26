module Knitkit
  module ErpApp
    module Desktop
      class PositionController < Knitkit::ErpApp::Desktop::AppController
        
        def update
          params[:position_array].each do |position|
            model = position['klass'].constantize.find(position['id'])
            model.position = position['position'].to_i
            model.save
          end

          render :json => {:success => true}
        end
        
      end#PositionController
    end#Desktop
  end#ErpApp
end#Knitkit

