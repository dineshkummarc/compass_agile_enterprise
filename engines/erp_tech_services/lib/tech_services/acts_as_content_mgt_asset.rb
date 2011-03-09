module TechServices::ContentMgt
	module ActsAsContentMgtAsset

		def self.included(base)
      base.extend(ClassMethods)  	        	      	
    end

		module ClassMethods

  		def acts_as_content_mgt_asset
  		    			
  			has_one :content_mgt_asset, :as => :digital_asset
  												
			  extend TechServices::ContentMgt::ActsAsContentMgtAsset::SingletonMethods
			  include TechServices::ContentMgt::ActsAsContentMgtAsset::InstanceMethods												
											     			
		  end

		end
  		
		module SingletonMethods			
		end
				
		module InstanceMethods
      def root
        self.content_mgt_asset
      end

      def after_update
      
        #puts "after update called on #{self.class}"
      
      end  
      
      def after_create
      
        c = ContentMgtAsset.create
        c.description = self.description
        c.digital_asset = self
        
        c.save
        self.save
        
      end
      
      def after_destroy
        if self.content_mgt_asset && !self.content_mgt_asset.frozen?
          self.content_mgt_asset.destroy
        end
      end
					
    	def to_label
        "#{description}"
    	end
    	
    	def to_s
        "#{description}"
    	end
    	
		end

	end
  		
end