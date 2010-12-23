class BaseScheduling < ActiveRecord::Migration
  def self.up
    unless table_exists?(:delayed_jobs)
      create_table :delayed_jobs, :force => true do |t|
        t.integer  :priority, :default => 0
        t.integer  :attempts, :default => 0
        t.text     :handler
        t.text     :last_error
        t.datetime :run_at
        t.datetime :locked_at
        t.string   :locked_by
        t.datetime :failed_at
        t.timestamps
      end
    end
  end

  def self.down
    [:delayed_jobs].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
  
end
