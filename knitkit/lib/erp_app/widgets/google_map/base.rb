module ErpApp
  module Widgets
    module GoogleMap
      class Base < ErpApp::Widgets::Base
        def index
          @uuid = Digest::SHA1.hexdigest(Time.now.to_s + rand(100).to_s)
          @drop_pins = params[:drop_pins]
          @zoom = params[:zoom] || 18
          @map_type = params[:map_type] || 'SATELLITE'

          render
        end
  
        #should not be modified
        #modify at your own risk
        self.view_paths = File.join(File.dirname(__FILE__),"/views")
        
        def locate
          File.dirname(__FILE__)
        end
        
        class << self
          def title
            "Google Map"
          end
          
          def widget_name
            File.basename(File.dirname(__FILE__))
          end
          
          def base_layout
            begin
              file = File.join(File.dirname(__FILE__),"/views/layouts/base.html.erb")
              IO.read(file)
            rescue
              return nil
            end
          end
        end
       
      end
    end
  end
end
