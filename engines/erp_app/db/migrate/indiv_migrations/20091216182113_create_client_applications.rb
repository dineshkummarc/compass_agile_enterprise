class CreateClientApplications < ActiveRecord::Migration
  def self.up
    create_table :desktops do |t|
      t.column :user_id, :integer
      t.column :wallpaper, :string, :default => "/shared/images/wallpaper/desktop.gif"
      t.timestamps
    end

    create_table :clients do |t|
      t.column :type, :string
      t.column :name, :string
      t.column :short_name, :string
      t.column :icon, :string
      t.column :default_width, :integer
      t.column :default_height, :integer
      t.timestamps
    end

    create_table :client_preferences do |t|
      t.column :user_id, :integer
      t.column :client_id, :integer
      t.column :window_left, :integer
      t.column :window_top, :integer
      t.column :window_width, :integer
      t.column :window_height, :integer
      t.column :short_cut, :boolean, :default => false
      t.column :icon_left, :integer
      t.column :icon_right, :integer
    end

    app1 = GlobalClient.create(:name => "My Profile", :short_name => "My Profile", :icon => "gears", :default_width => 500, :default_height => 300)
    app8 = SystemClient.create(:name => "Data Mgt Scaffolds", :short_name => "data_mgt_scaffold", :icon => "folder_gear", :default_width => 925, :default_height => 638)
    app9 = SystemClient.create(:name => "Content Mgt", :short_name => "content_mgt_app", :icon => "content", :default_width => 925, :default_height => 638)
    app10 = SystemClient.create(:name => "Knowledge Mgt", :short_name => "knowledge_mgt_app", :icon => "knowledge", :default_width => 925, :default_height => 638)
    app11 = SystemClient.create(:name => "Product Config", :short_name => "product_config_app", :icon => "prodconfig", :default_width => 925, :default_height => 638)

    users = User.find(:all)
    users.each do |user|
      if user.contains_role?("agent")
        Desktop.create(:user => user)
      ClientPreference.create(:user => user, :client => app1, :window_width => app1.default_width, :window_height => app1.default_height)
      ClientPreference.create(:user => user, :client => app8, :window_width => app8.default_width, :window_height => app8.default_height, :short_cut => true)
      ClientPreference.create(:user => user, :client => app9, :window_width => app9.default_width, :window_height => app9.default_height, :short_cut => true)
      ClientPreference.create(:user => user, :client => app10, :window_width => app10.default_width, :window_height => app10.default_height, :short_cut => true)
      ClientPreference.create(:user => user, :client => app11, :window_width => app11.default_width, :window_height => app11.default_height, :short_cut => true)
      end
    end
  end

  def self.down
    drop_table :desktops

    drop_table :clients
    drop_table :client_preferences
  end
end
