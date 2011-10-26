class WebsiteNavItem < ActiveRecord::Base
  belongs_to :website_nav
  belongs_to :linked_to_item, :polymorphic => true
  
  has_security
  acts_as_nested_set
  include ErpTechSvcs::Utils::DefaultNestedSetMethods

  def path
    linked_to_item.nil? ? url : linked_to_item.path
  end
  
  def positioned_children
    children.sort_by{|child| [child.position]}
  end

  def website_nav
    website_nav_id.nil? ? self.parent.website_nav : WebsiteNav.find(website_nav_id)
  end

end
