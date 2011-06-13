class Application < ActiveRecord::Base
  has_user_preferences

  has_and_belongs_to_many :app_containers
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :widgets


  def build_widget_roles_js
    widget_roles = []

    widgets.each do |widget|
      widget_roles << "{xtype:'#{widget.xtype}', roles:[#{widget.roles.collect{|role| "'#{role.internal_identifier}'"}.join(',')}]}"
    end

    "widget_roles:[#{widget_roles.join(',')}]"
  end

  def load_resources
    resource_loader = self.resource_loader.constantize.new(self)
    resource_loader.load_resources
  end
  
end
