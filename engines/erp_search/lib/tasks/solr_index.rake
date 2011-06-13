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

  task :reindex_roles => :environment do
    puts "Indexing ..."
    Role.solr_reindex
    puts "Done."
  end

  task :delete_roles => :environment do
    puts "Removing Indexes ..."
    Role.solr_remove_all_from_index!
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

end

