module ErpTechSvcs
	module Utils
		module DefaultNestedSetMethods
			def self.included(base)
				base.extend(ClassMethods)
			end

			def to_label
				"#{description}"
			end

			def leaf
			  children.size == 0
			end

			def to_json_with_leaf(options = {})
				self.to_json_without_leaf(options.merge(:methods => :leaf))
			end
			alias_method_chain :to_json, :leaf

			module ClassMethods
				def find_roots
					find( :all, :conditions => {:parent_id => nil })
				end

				def find_children(parent_id = nil)
					parent_id.to_i == 0 ? self.roots : find(parent_id).children
				end
			end
		end
	end
end

