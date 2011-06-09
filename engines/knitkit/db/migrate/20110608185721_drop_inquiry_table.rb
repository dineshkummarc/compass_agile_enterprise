class DropInquiryTable < ActiveRecord::Migration
  def self.up
     [ :website_inquiries ].each do |tbl|
        if table_exists?(tbl)
          drop_table tbl
        end
      end
  end

  def self.down
  end
end
