class UpdateRoles < ActiveRecord::Migration
  def up

    roles_users = ActiveRecord::Base.connection.select_all("select * from roles_users")
    roles_users.each do |role_user|
      secured_model = SecuredModel.find_by_secured_record_id_and_secured_record_type(role_user['user_id'], 'User')
      if secured_model.nil?
        secured_model = SecuredModel.new
        secured_model.secured_record = User.find(role_user['user_id'])
        secured_model.save
      end
      secured_model.roles << Role.find(role_user['role_id'])
    end

    roles_widgets = ActiveRecord::Base.connection.select_all("select * from roles_widgets")
    roles_widgets.each do |role_widget|
      secured_model = SecuredModel.find_by_secured_record_id_and_secured_record_type(role_widget['widget_id'], 'Widget')
      if secured_model.nil?
        secured_model = SecuredModel.new
        secured_model.secured_record = Widget.find(role_widget['widget_id'])
        secured_model.save
      end
      secured_model.roles << Role.find(role_widget['role_id'])
    end

    drop_table :roles_users
    drop_table :roles_widgets

  end

  def down
  end
end
