class BaseTxnsAndAccts < ActiveRecord::Migration
  def self.up
    
    unless table_exists?(:biz_txn_events)
      create_table :biz_txn_events do |t|
	      t.column  :description,  			    :string
	      t.column	:biz_txn_acct_root_id, 	:integer
		  	t.column	:biz_txn_type_id,       :integer
		  	t.column 	:entered_date,          :datetime
		  	t.column 	:post_date,             :datetime
	      t.column  :biz_txn_record_id,    	:integer
	      t.column  :biz_txn_record_type,  	:string
		  	t.column 	:external_identifier, 	:string
		  	t.column 	:external_id_source, 	  :string
	      t.timestamps
      end

      add_index :biz_txn_events, :biz_txn_acct_root_id
      add_index :biz_txn_events, :biz_txn_type_id
      add_index :biz_txn_events, [:biz_txn_record_id, :biz_txn_record_type], :name => "btai_1"
    end
    
    unless table_exists?(:biz_txn_event_descs)
      create_table :biz_txn_event_descs do |t|
		    t.column		:biz_txn_event_id,  :integer
		    t.column		:language_id,       :integer
		    t.column		:locale_id,		      :integer
		    t.column		:priority,      		:integer		
		    t.column		:sequence,      		:integer		
		    t.column		:short_description, :string
		    t.column		:long_description,  :string
        t.timestamps
      end

      add_index :biz_txn_event_descs, :biz_txn_event_id
      add_index :biz_txn_event_descs, :language_id
      add_index :biz_txn_event_descs, :locale_id
    end
    
    unless table_exists?(:biz_txn_types)
      create_table :biz_txn_types do |t|
      	t.column  :parent_id,    :integer
      	t.column  :lft,          :integer
      	t.column  :rgt,          :integer

        #custom columns go here
      	t.column  :description,         :string
      	t.column  :comments,            :string
		    t.column 	:internal_identifier, :string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string
      	t.timestamps
      end

      add_index :biz_txn_types, [:parent_id,:lft,:rgt], :name => 'biz_txn_type_nested_set_idx'
    end
    
    unless table_exists?(:biz_txn_relationships)
      create_table :biz_txn_relationships do |t|
        t.column  :biz_txn_rel_type_id, :integer
        t.column  :description,         :string 
        t.column  :txn_event_id_from,   :integer
        t.column  :txn_event_id_to,     :integer
        t.column  :status_type_id,      :integer
        t.column  :from_date,           :date
        t.column  :thru_date,           :date 
        t.timestamps
      end

      add_index :biz_txn_relationships, :biz_txn_rel_type_id
      add_index :biz_txn_relationships, :status_type_id
    end
    
    unless table_exists?(:biz_txn_rel_types)
      create_table :biz_txn_rel_types do |t|
      	t.column  	:parent_id,    :integer
      	t.column  	:lft,          :integer
      	t.column  	:rgt,          :integer
        #custom columns go here   
      	t.column  :description,         :string
      	t.column  :comments,            :string
		    t.column 	:internal_identifier, :string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string
      	t.timestamps
      end

      add_index :biz_txn_rel_types, :parent_id
    end
    
    unless table_exists?(:biz_txn_statuses)
      create_table :biz_txn_statuses do |t|
        t.column  :description, :string
        t.column  :comments,    :string
        t.timestamps
      end
    end
    
    unless table_exists?(:biz_txn_tasks)
      create_table :biz_txn_tasks do |t|
        t.column  :description, :string
        t.timestamps
      end
    end
    
    unless table_exists?(:biz_txn_task_types)
      create_table :biz_txn_task_types do |t|
        t.column  :parent_id,    :integer
        t.column  :lft,          :integer
        t.column  :rgt,          :integer
        #custom columns go here   
        t.column  :description, :string
        t.column  :comments,    :string
        t.timestamps
      end

      add_index :biz_txn_task_types, :parent_id
    end
    
    unless table_exists?(:biz_txn_party_roles)
      create_table :biz_txn_party_roles do |t|
      	t.column  :biz_txn_event_id, 	         :integer
    	  t.column  :party_id, 			             :integer
      	t.column  :biz_txn_party_role_type_id, :integer    	
      	t.timestamps
      end

      add_index :biz_txn_party_roles, :biz_txn_event_id
      add_index :biz_txn_party_roles, :party_id
      add_index :biz_txn_party_roles, :biz_txn_party_role_type_id
    end
    
    unless table_exists?(:biz_txn_party_role_types)
      create_table :biz_txn_party_role_types do |t|
        t.column  :parent_id,    :integer
        t.column  :lft,          :integer
        t.column  :rgt,          :integer
        #custom columns go here   
        t.column  :description,         :string
        t.column  :comments,            :string
        t.column  :internal_identifier, :string
        t.timestamps
      end

      add_index :biz_txn_party_role_types, :parent_id
    end
    
    unless table_exists?(:biz_txn_acct_roots)
      create_table :biz_txn_acct_roots do |t|
		    t.column 	:description,			    :string
		    t.column 	:status, 				      :integer
      	t.column  :biz_txn_acct_id,    	:integer
      	t.column  :biz_txn_acct_type,  	:string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string
        t.column  :type,                :string
        t.timestamps
      end

      add_index :biz_txn_acct_roots, [:biz_txn_acct_id, :biz_txn_acct_type], :name => "btai_2"
    end
    
    unless table_exists?(:biz_txn_acct_status_types)
      create_table :biz_txn_acct_status_types do |t|
        t.timestamps
      end
    end
  
    unless table_exists?(:biz_txn_acct_types)
      create_table :biz_txn_acct_types do |t|
        t.column  	:parent_id,    			:integer
        t.column  	:lft,          			:integer
        t.column  	:rgt,          			:integer
        #custom columns go here   
        t.column  :description,         :string
        t.column  :comments,            :string
		    t.column 	:internal_identifier, :string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string
        t.timestamps
      end

      add_index :biz_txn_acct_types, :parent_id
    end
    
    unless table_exists?(:biz_txn_acct_statuses)
      create_table :biz_txn_acct_statuses do |t|
        t.timestamps
      end
    end
    
    unless table_exists?(:biz_txn_acct_rel_types)
      create_table :biz_txn_acct_rel_types do |t|
      	t.column  	:parent_id,    :integer
      	t.column  	:lft,          :integer
      	t.column  	:rgt,          :integer
        #custom columns go here   
      	t.column  :description,         :string
      	t.column  :comments,            :string
		    t.column 	:internal_identifier, :string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string
      	t.timestamps
      end

      add_index :biz_txn_acct_rel_types, :parent_id
    end
    
    unless table_exists?(:biz_txn_acct_relationships)
      create_table :biz_txn_acct_relationships do |t|
        t.column  :biz_txn_acct_rel_type_id,  :integer
        t.column  :description,               :string
        t.column  :biz_txn_acct_root_id_from, :integer
        t.column  :biz_txn_acct_root_id_to,   :integer
        t.column  :status_type_id,            :integer
        t.column  :from_date,                 :date
        t.column  :thru_date,                 :date 
        t.timestamps
      end

      add_index :biz_txn_acct_relationships, :biz_txn_acct_rel_type_id
      add_index :biz_txn_acct_relationships, :status_type_id

    end
    
    unless table_exists?(:biz_txn_acct_party_roles)
      create_table :biz_txn_acct_party_roles do |t|
        t.column  :description,               		:string
        t.column  :biz_txn_acct_root_id,      		:integer
        t.column  :party_id,                  		:integer
        t.column  :biz_txn_acct_pty_rtype_id, 		:integer
        t.column  :is_default_billing_acct_flag,  :integer
        t.timestamps
      end

      add_index :biz_txn_acct_party_roles, :biz_txn_acct_root_id
      add_index :biz_txn_acct_party_roles, :party_id
      add_index :biz_txn_acct_party_roles, :biz_txn_acct_pty_rtype_id
    end
    
    unless table_exists?(:biz_txn_acct_pty_rtypes)
      create_table :biz_txn_acct_pty_rtypes do |t|
      	t.column  	:parent_id,    :integer
      	t.column  	:lft,          :integer
      	t.column  	:rgt,          :integer
        #custom columns go here   
      	t.column  :description,         :string
      	t.column  :comments,            :string
		    t.column 	:internal_identifier, :string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string
      	t.timestamps
      end

      add_index :biz_txn_acct_pty_rtypes, :parent_id
    end
    
    unless table_exists?(:biz_acct_txn_tasks)
      create_table :biz_acct_txn_tasks do |t|
		    t.column  :biz_txn_task_id,     :integer
		    t.column  :biz_txn_account_id,  :integer
		    t.column  :description, 		    :string
		    t.column  :comments,            :string
		    t.column  :entered_date,      	:datetime
		    t.column  :requested_date,     	:datetime
        t.timestamps
      end

      add_index :biz_acct_txn_tasks, :biz_txn_task_id
      add_index :biz_acct_txn_tasks, :biz_txn_account_id
    end

    unless table_exists?(:biz_txn_agreement_role_types)
      create_table :biz_txn_agreement_role_types do |t|
        t.column  :parent_id,    :integer
        t.column  :lft,          :integer
        t.column  :rgt,          :integer
        #custom columns go here
        t.column  :description,         :string
        t.column  :comments,            :string
        t.column  :internal_identifier, :string
        t.timestamps
      end

      add_index :biz_txn_agreement_role_types, :parent_id
    end
    
    unless table_exists?(:biz_txn_agreement_roles)
      create_table :biz_txn_agreement_roles do |t|
        t.references  :biz_txn_event,                   :polymorphic => true
        t.column      :agreement_id,                    :integer
        t.column      :biz_txn_agreement_role_type_id,  :integer
        t.timestamps
      end

      add_index :biz_txn_agreement_roles, :agreement_id
      add_index :biz_txn_agreement_roles, :biz_txn_agreement_role_type_id
    end
    
    unless table_exists?(:financial_txns)
      create_table :financial_txns do |t|
        t.integer :money_id
        t.date    :apply_date
        
        t.timestamps
      end  
    end

    unless table_exists?(:financial_txn_assns)
      create_table :financial_txn_assns do |t|
        t.references :financial_txn
        t.references :financial_txn_record, :polymorphic => true

        t.timestamps
      end
    end
    
    unless table_exists?(:financial_txn_accounts)
      create_table :financial_txn_accounts do |t|
        t.column :account_number,    :string
        t.column :agreement_id,      :integer
        t.column :balance_id,        :integer
        t.column :balance_date,      :date
        t.column :calculate_balance, :boolean
        t.column :payment_due_id,    :integer
        t.column :due_date,          :date
        
        #polymorphic tables 
        t.references  :financial_account, :polymorphic => true
        
        t.timestamps
      end  
    end
    
    unless table_exists?(:base_txn_contexts)
      create_table :base_txn_contexts do |t|
	      t.references  :biz_txn_event
	      t.references	:txn_context_record, 	:polymorphic => true
	      
	      t.timestamps
      end
      
      add_index :base_txn_contexts, [:txn_context_record_id, :txn_context_record_type], :name => 'txn_context_record_idx'
    end
    
  end

  def self.down
    [ 
      :biz_txn_agreement_roles, :biz_txn_agreement_role_types, :biz_acct_txn_tasks, 
      :biz_txn_acct_pty_rtypes, :biz_txn_acct_party_roles, :biz_txn_acct_relationships, 
      :biz_txn_acct_rel_types, :biz_txn_acct_statuses, :biz_txn_acct_types, 
      :biz_txn_acct_status_types, :biz_txn_acct_roots, :biz_txn_party_role_types, 
      :biz_txn_party_roles, :biz_txn_task_types, :biz_txn_tasks, 
      :biz_txn_statuses, :biz_txn_rel_types, :biz_txn_relationships,:base_txn_contexts,
      :biz_txn_types, :biz_txn_event_descs, :biz_txn_events,:financial_txn_accounts,:financial_txns
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
end
