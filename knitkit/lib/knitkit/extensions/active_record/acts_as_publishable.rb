module Knitkit
  module Extensions
    module ActiveRecord
      module ActsAsPublishable
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def can_be_published
            after_destroy :destroy_published_elements

            extend ActsAsPublishable::SingletonMethods
            include ActsAsPublishable::InstanceMethods
          end

        end

        module SingletonMethods
        end

        module InstanceMethods
          def publish(site, comment, version, current_user)
            site.publish_element(comment, self, version, current_user)
          end

          def destroy_published_elements
            published_elements = PublishedElement.where('published_element_record_id = ? and (published_element_record_type = ? or published_element_record_type = ?)', self.id, self.class.to_s, self.class.superclass.to_s)
            published_elements.each do |published_element|
              published_element.destroy
            end
          end
        end
      end
    end
  end
end
