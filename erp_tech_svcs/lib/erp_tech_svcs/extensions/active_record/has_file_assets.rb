module ErpTechSvcs
	module Extensions
		module ActiveRecord
			module HasFileAssets

				def self.included(base)
					base.extend(ClassMethods)  	        	      	
				end

				module ClassMethods

					def has_file_assets
						has_many :files, :as => :file_asset_holder, :class_name => 'FileAsset', :dependent => :delete_all 

						extend ErpTechSvcs::Extensions::ActiveRecord::HasFileAssets::SingletonMethods
						include ErpTechSvcs::Extensions::ActiveRecord::HasFileAssets::InstanceMethods
																		
					end

				end
  		
				module SingletonMethods
				end
				
				module InstanceMethods
          def add_file(path, data)
						FileAsset.create!(:file_asset_holder => self, :base_path => path, :data => data)
          end

          def images
						self.files.find(:all, :conditions => ['type = ?', 'Image'])
          end

          def templates
						self.files.find(:all, :conditions => ['type = ?', 'Template'])
          end
          
				end
			end
		end
	end
end