class CreateNewWebsiteInquiriesTable < ActiveRecord::Migration
  def self.up
    unless table_exists?(:website_inquiries)
      create_table :website_inquiries do |t|
        t.integer :website_id

        t.timestamps
      end

      add_index :website_inquiries, :website_id
    end
  end

  def self.down
    [ :website_inquiries ].each do |tbl|
       if table_exists?(tbl)
         drop_table tbl
       end
     end    
  end
end
