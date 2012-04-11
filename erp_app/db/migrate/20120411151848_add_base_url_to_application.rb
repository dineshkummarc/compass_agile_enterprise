class AddBaseUrlToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :base_url, :string unless column_exists? :applications, :base_url
  end
end
