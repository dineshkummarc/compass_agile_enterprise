module ErpTechSvcs
	module Extensions
		module ActiveRecord
			module HasFileAssets

				def self.included(base)
					base.extend(ClassMethods)  	        	      	
				end

				module ClassMethods
					def has_file_assets
						extend HasFileAssets::SingletonMethods
						include HasFileAssets::InstanceMethods
						
						has_many :files, :as => :file_asset_holder, :class_name => 'FileAsset', :dependent => :delete_all 								
					end
				end
  		
				module SingletonMethods
				end
				
				module InstanceMethods

          # Capabilites can be passed via a hash
          # {
          #   :download => ['admin', 'employee'],
          #   :edit     => ['admin']
          # }
          #
          def add_file(data, path=nil, capabilities=nil)
						file_asset = FileAsset.create!(:file_asset_holder => self, :base_path => path, :data => data)

            #set capabilites if they are passed
            capabilities.each do |capability_type, roles|
              file_asset.add_capability(capability_type, nil, roles)
            end if capabilities

            file_asset
          end

          def images
						self.files.where('type = ?', 'Image')
          end

          def templates
						self.files.where('type = ?', 'Template')
          end
          
				end
			end
		end
	end
end