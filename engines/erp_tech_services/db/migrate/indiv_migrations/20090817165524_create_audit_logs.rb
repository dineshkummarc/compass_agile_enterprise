class CreateAuditLogs < ActiveRecord::Migration
  def self.up
    create_table :audit_logs do |t|
      t.column :application_id, :string

      t.column :user_id, :integer

      t.column :event_id, :integer

      t.column :description, :string


      t.timestamps

    end
  end

  def self.down
    drop_table :audit_logs
  end
end
