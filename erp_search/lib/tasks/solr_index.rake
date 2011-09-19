require 'action_controller'
require 'sunspot/rails/tasks'

namespace :sunspot do
  task :reindex_party_search_facts, [:batch_size, :batch_commit] => :environment do |t,args|
    default_batch_commit = true
    default_batch_size = 1000

    batch_size = (args.batch_size || default_batch_size).to_i
    batch_commit = (args.batch_commit || default_batch_commit)
    start_time = Time.now

    puts "Starting Indexing with batch size of #{batch_size} at #{start_time} ..." 
    puts "Batch commit is set to #{batch_commit}"
    puts "There are #{PartySearchFact.count} parties to index"
    puts "This takes roughly 30 minutes per 500,000 parties"
    PartySearchFact.solr_reindex(:batch_size => batch_size, :batch_commit => batch_commit)
    end_time = Time.now
    puts "Done. Finished at: #{end_time}"
    puts "Elapsed time: #{(end_time - start_time)/60} minutes"
  end

  task :delete_party_search_facts => :environment do
    puts "Removing Indexes ..."
    PartySearchFact.solr_remove_all_from_index!
    puts "Done."
  end

  task :reindex_content => :environment do
    puts "Indexing ..."
    Content.solr_reindex
    puts "Done."
  end

  task :delete_content => :environment do
    puts "Removing Indexes ..."
    Content.solr_remove_all_from_index!
    puts "Done."
  end

  namespace :tenants do
    def get_all_tenants
      # get all tenants
      tenants = Tenant.all
      
      # add public schema if it is in list
      public_schema = Tenant.new
      public_schema.id = 0
      public_schema.schema = 'public'      
      schemas = tenants.collect{|t| t.schema }
      tenants << public_schema unless schemas.include?('public')
      tenants
    end
        
    task :reindex_content => :environment do
      # loop thru tenants
      get_all_tenants.each do |t|
        puts "Indexing #{t.schema} ..."
        
        set_current_schema(t.schema)
        
        remove_tenant_indexes(Content, t.id)
        
        # reindex content for tenant
        Content.solr_index
        Sunspot.commit
      end
      
      puts "Done."
    end
    
    task :delete_content => :environment do      
      puts "Removing Indexes for All Tenants! ..."
      Content.solr_remove_all_from_index!
      puts "Done."
    end
  end
  
  def get_tenant_id_by_schema(schema)
    tenant_id = Tenant.find_by_schema(schema).id rescue 0
    puts "tenant id is zero which means public schema!" if tenant_id == 0    
    return tenant_id
  end
  
  def set_current_schema(schema)
    # set current tenant_id in Thread
    if schema == 'public'
      Thread.current[:tenant_id] = 0
    else
      Thread.current[:tenant_id] = get_tenant_id_by_schema(schema)
    end      

    #set schema
    Tenancy::SchemaUtil.set_search_path(schema)  
  end
  
  def remove_tenant_indexes(object, tenant_id)
    # remove by query
    Sunspot.remove(object) do
      with(:tenant_id).equal_to(tenant_id)
    end      
    Sunspot.commit
  end
    
  namespace :tenant do
    task :reindex_content, [:schema] => :environment do |t,args|
      puts "Indexing #{args.schema} ..."
      
      set_current_schema(args.schema)
            
      remove_tenant_indexes(Content, get_tenant_id_by_schema(args.schema))
      
      Content.solr_index     
      Sunspot.commit
      puts "Done."
    end

    task :delete_content, [:schema] => :environment do |t,args|
      puts "Removing Indexes ..."
      
      set_current_schema(args.schema)
            
      remove_tenant_indexes(Content, get_tenant_id_by_schema(args.schema))      
      puts "Done."
    end
  end
end

