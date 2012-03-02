module ErpProducts
	module Extensions
		module ActiveRecord
			module ActsAsProductOffer

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def acts_as_product_offer
            extend ActsAsProductOffer::SingletonMethods
            include ActsAsProductOffer::InstanceMethods

            after_initialize :initialize_product_offer
            after_create :save_product_offer
            after_update :save_product_offer
            after_destroy :destroy_product_offer

            has_one :product_offer, :as => :product_offer_record

            [:description, :description=].each do |m| delegate m, :to => :product_offer end
          end
        end

        module SingletonMethods
        end

        module InstanceMethods
          def initialize_product_offer
            if self.new_record? && self.product_offer.nil?
              product_offer = ProductOffer.new
              self.product_offer = product_offer
              product_offer.save
              self.save
            end
          end

          def save_product_offer
            self.product_offer.description = self.description
            self.product_offer.save
          end

          def destroy_product_offer
            self.product_offer.destroy if (self.product_offer && !self.product_offer.frozen?)
          end

        end
      end
    end
  end
end