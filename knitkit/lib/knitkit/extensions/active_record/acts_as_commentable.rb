module Knitkit
  module Extensions
    module ActiveRecord
      module ActsAsCommentable
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def acts_as_commentable
            has_many :comments, :as => :commented_record, :dependent => :destroy do
              def limit(limit)
                find(:all, :limit => limit)
              end
            end

            extend ActsAsCommentable::SingletonMethods
            include ActsAsCommentable::InstanceMethods
          end

        end

        module SingletonMethods
        end

        module InstanceMethods
        end
      end
    end
  end
end
