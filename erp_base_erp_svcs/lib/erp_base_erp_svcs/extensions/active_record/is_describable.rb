module ErpBaseErpSvcs
	module Extensions
		module ActiveRecord
			module IsDescribable
			
				def self.included(base)
					base.extend(ClassMethods)  	        	      	
				end

				module ClassMethods
			  
					def is_describable
						has_many :descriptions, :class_name => 'DescriptiveAsset', :as => :described_record, :dependent => :destroy
					
						extend ErpBaseErpSvcs::Extensions::ActiveRecord::IsDescribable::SingletonMethods
						include ErpBaseErpSvcs::Extensions::ActiveRecord::IsDescribable::InstanceMethods
																		
					end
				end
				
				module SingletonMethods			
				end
						
				module InstanceMethods
				  def find_descriptions_by_view_type(view_iid)
					self.descriptions.where('view_type_id = ?', ViewType.find_by_internal_identifier(view_iid).id)
				  end

				  def find_description_by_iid(iid)
					self.descriptions.where('internal_identifier = ?', iid)
				  end

				  def add_description(view_type, description)
					descriptive_asset = DescriptiveAsset.create(
					  :view_type => view_type,
					  :description => description)
					descriptive_asset.described_record = self
					self.descriptions << descriptive_asset
				  end
				end
			end
		end
	end
end