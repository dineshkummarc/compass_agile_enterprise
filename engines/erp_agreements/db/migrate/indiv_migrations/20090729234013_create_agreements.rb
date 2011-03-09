class CreateAgreements < ActiveRecord::Migration
  def self.up
    create_table :agreements do |t|

        t.column  :description,       :string
      
        t.column  :agreement_type_id, :integer      
        t.column  :agreement_status,  :string

        t.column  :product_id,        :integer 
    
        t.column  :agreement_date,    :date   
        t.column  :from_date,         :date
        t.column  :thru_date,         :date

	t.column 	:external_identifier, 	:string
	t.column 	:external_id_source, 	:string

        t.timestamps

    end
  end

  def self.down
    drop_table :agreements
  end
end
