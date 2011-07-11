namespace :erp_rules do

  task :start_axiom do
    load "#{File.dirname(__FILE__)}/../../vendor/plugins/axiom/lib/tasks/axiom.rake"

    Rake::Task["axiom:start"].invoke
  end

end
