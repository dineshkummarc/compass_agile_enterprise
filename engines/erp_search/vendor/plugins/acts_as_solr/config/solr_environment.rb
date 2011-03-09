ENV['RAILS_ENV']  = (ENV['RAILS_ENV'] || 'development').dup
# RAILS_ROOT isn't defined yet, so figure it out.
#TODO: since pluign was moved into another plugin this had to be updated
#rails_root_dir = "#{File.dirname(File.expand_path(__FILE__))}/../../../../"
rails_root_dir = "#{File.dirname(File.expand_path(__FILE__))}/../../../../../../../"
SOLR_PATH = "#{File.dirname(File.expand_path(__FILE__))}/../solr" unless defined? SOLR_PATH
if RUBY_PLATFORM =~ /(:?mswin|mingw|darwin)/
  SOLR_LOGS_PATH = "#{rails_root_dir}/log" unless defined? SOLR_LOGS_PATH
else
  SOLR_LOGS_PATH = "/var/log/rails" unless defined? SOLR_LOGS_PATH
end

unless defined? SOLR_PORT
  #TODO: since pluign was moved into another plugin I moved the config files to its parent config folder
  config = YAML::load_file(File.dirname(File.expand_path(__FILE__))+'/../../../../config/solr.yml')
  SOLR_PORT = ENV['PORT'] || URI.parse(config[ENV['RAILS_ENV']]['url']).port
end

SOLR_JVM_OPTIONS = config[ENV['RAILS_ENV']]['jvm_options'] unless defined? SOLR_JVM_OPTIONS
SOLR_PIDS_PATH = "#{rails_root_dir}/tmp/pids"
SOLR_DATA_PATH = "#{rails_root_dir}/solr/#{ENV['RAILS_ENV']}" unless defined? SOLR_DATA_PATH

if ENV['RAILS_ENV'] == 'test'
  DB = (ENV['DB'] ? ENV['DB'] : 'mysql') unless defined?(DB)
  MYSQL_USER = (ENV['MYSQL_USER'].nil? ? 'root' : ENV['MYSQL_USER']) unless defined? MYSQL_USER
  require File.join(File.dirname(File.expand_path(__FILE__)), '..', 'test', 'db', 'connections', DB, 'connection.rb')
end
