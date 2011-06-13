class BaseTxnsAndAccountsIndexes < ActiveRecord::Migration
  def self.up
    add_index :biz_txn_events, :biz_txn_acct_root_id
    add_index :biz_txn_events, :biz_txn_type_id
    add_index :biz_txn_events, [:biz_txn_record_id, :biz_txn_record_type], :name => "btai_1"
    
    add_index :biz_txn_event_descs, :biz_txn_event_id
    add_index :biz_txn_event_descs, :language_id
    add_index :biz_txn_event_descs, :locale_id
    
    add_index :biz_txn_types, :parent_id
    
    add_index :biz_txn_relationships, :biz_txn_rel_type_id
    add_index :biz_txn_relationships, :status_type_id
    
    add_index :biz_txn_rel_types, :parent_id
    
    add_index :biz_txn_task_types, :parent_id
    
    add_index :biz_txn_party_roles, :biz_txn_event_id
    add_index :biz_txn_party_roles, :party_id
    add_index :biz_txn_party_role_types, :parent_id
    
    add_index :biz_txn_acct_roots, [:biz_txn_acct_id, :biz_txn_acct_type], :name => "btai_2"
    
    add_index :biz_txn_acct_types, :parent_id
    
    add_index :biz_txn_acct_rel_types, :parent_id
    
    add_index :biz_txn_acct_relationships, :biz_txn_acct_rel_type_id
    add_index :biz_txn_acct_relationships, :status_type_id
    
    add_index :biz_txn_acct_party_roles, :biz_txn_acct_root_id
    add_index :biz_txn_acct_party_roles, :party_id
    add_index :biz_txn_acct_party_roles, :biz_txn_acct_pty_rtype_id
    
    add_index :biz_txn_acct_pty_rtypes, :parent_id
    
    add_index :biz_acct_txn_tasks, :biz_txn_task_id
    add_index :biz_acct_txn_tasks, :biz_txn_account_id
    
    add_index :biz_txn_agreement_role_types, :parent_id
    
    add_index :biz_txn_agreement_roles, :agreement_id
    add_index :biz_txn_agreement_roles, :biz_txn_agreement_role_type_id

    ### Conditional checks: since these columns may have been added with a later migration,
    ### we check that the column exists before adding an index on it.
    
    if columns(:biz_txn_party_roles).collect {|c| c.name }.include?('biz_txn_party_role_type_id')
      add_index :biz_txn_party_roles, :biz_txn_party_role_type_id
    end  

  end

  def self.down
    remove_index :biz_txn_events, :biz_txn_acct_root_id
    remove_index :biz_txn_events, :biz_txn_type_id
    remove_index :biz_txn_events, :name => "btai_1"
    
    remove_index :biz_txn_event_descs, :biz_txn_event_id
    remove_index :biz_txn_event_descs, :language_id
    remove_index :biz_txn_event_descs, :locale_id
    
    remove_index :biz_txn_types, :parent_id
    
    remove_index :biz_txn_relationships, :biz_txn_rel_type_id
    remove_index :biz_txn_relationships, :status_type_id
    
    remove_index :biz_txn_rel_types, :parent_id
    
    remove_index :biz_txn_task_types, :parent_id
    
    remove_index :biz_txn_party_roles, :biz_txn_event_id
    remove_index :biz_txn_party_roles, :party_id
    
    remove_index :biz_txn_party_role_types, :parent_id
    
    remove_index :biz_txn_acct_roots, :name => "btai_2"
    
    remove_index :biz_txn_acct_types, :parent_id
    
    remove_index :biz_txn_acct_rel_types, :parent_id
    
    remove_index :biz_txn_acct_relationships, :biz_txn_acct_rel_type_id
    remove_index :biz_txn_acct_relationships, :status_type_id
    
    remove_index :biz_txn_acct_party_roles, :biz_txn_acct_root_id
    remove_index :biz_txn_acct_party_roles, :party_id
    remove_index :biz_txn_acct_party_roles, :biz_txn_acct_pty_rtype_id
    
    remove_index :biz_txn_acct_pty_rtypes, :parent_id
    
    remove_index :biz_acct_txn_tasks, :biz_txn_task_id
    remove_index :biz_acct_txn_tasks, :biz_txn_account_id
    
    remove_index :biz_txn_agreement_role_types, :parent_id
    
    remove_index :biz_txn_agreement_roles, :agreement_id
    remove_index :biz_txn_agreement_roles, :biz_txn_agreement_role_type_id
    
    ### Conditional checks: since these columns were originally added in a later
    ### migration that may not yet have already been run,
    ### we check that the column exists before removing an index on it.
    
    if indexes(:biz_txn_party_roles).collect { |i| 
      i.name }.include?('index_biz_txn_party_roles_on_biz_txn_party_role_type_id')
      remove_index :biz_txn_party_roles, :biz_txn_party_role_type_id
    end
    
  end
end
