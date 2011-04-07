require "benchmark"

namespace :tenancy do

  task :setup_tenate => :environment do
    raise "Missing SCHEMA" if ENV['SCHEMA'].blank?
    raise "Missing HOST" if ENV['HOST'].blank?
    raise "Missing ROUTE" if ENV['ROUTE'].blank?

    puts '================Running schema.rb============='
    time = Benchmark.measure do
      Tenant.setup_tenant(ENV['HOST'], ENV['SCHEMA'], ENV['ROUTE'])
    end
    time_str = "(%.4fs)" % time.real
    puts "================Finished in #{time_str}======="
  end


end
