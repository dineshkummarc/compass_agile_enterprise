module CanBePublished
    def self.included(base)
      base.extend(ClassMethods)
    end

		module ClassMethods

  		def can_be_published
        extend CanBePublished::SingletonMethods
		include CanBePublished::InstanceMethods
		  end

		end

		module SingletonMethods
		end

		module InstanceMethods
      def publish(site, comment, version)
        site.publish_element(comment, self, version)
      end

      def before_destroy()
        published_element = PublishedElement.find(:first,
          :conditions => ['published_element_record_id = ? and (published_element_record_type = ? or published_element_record_type = ?)', self.id, self.class.to_s, self.class.superclass.to_s])
        unless published_element.nil?
          published_element.destroy
        end
      end
    end
  end

ActiveRecord::Base.send(:include, CanBePublished)
