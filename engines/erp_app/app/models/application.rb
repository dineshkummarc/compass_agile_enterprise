class Application < ActiveRecord::Base
  has_user_preferences

  has_and_belongs_to_many :app_containers
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :widgets
  
  def available_widget_xtypes(user)
    xtypes = []
    self.widgets.each do |widget|
      if(user.contains_roles?(widget.roles.collect{|r| r.internal_identifier}))
        xtypes << widget.xtype
      end
    end

    xtypes.to_json
  end
end
