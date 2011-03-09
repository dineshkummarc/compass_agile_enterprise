task :solr_proxy, :solr_task do |t, args|
  solr_task = args[:solr_task]

  load "#{File.dirname(__FILE__)}/../../vendor/plugins/acts_as_solr/lib/tasks/solr.rake"

  Rake::Task[solr_task].invoke

end