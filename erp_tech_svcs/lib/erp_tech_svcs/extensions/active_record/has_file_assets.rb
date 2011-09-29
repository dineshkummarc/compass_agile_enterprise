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
				  
          def add_file(data, path=nil)
						FileAsset.create!(:file_asset_holder => self, :base_path => path, :data => data)
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