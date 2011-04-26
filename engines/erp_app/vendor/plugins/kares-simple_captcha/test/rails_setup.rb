# enable testing with different version of rails via argv :

version =
  if ARGV.find { |opt| /RAILS_VERSION=([\d\.]+)/ =~ opt }
    $~[1]
  else
    ENV['RAILS_VERSION'] # rake test RAILS_VERSION=2.3.5
  end

if version
  RAILS_VERSION = version
  gem 'activesupport', "= #{RAILS_VERSION}"
  gem 'activerecord', "= #{RAILS_VERSION}"
  gem 'actionpack', "= #{RAILS_VERSION}"
  gem 'actionmailer', "= #{RAILS_VERSION}"
  gem 'rails', "= #{RAILS_VERSION}"
else
  gem 'activesupport'
  gem 'activerecord'
  gem 'actionpack'
  gem 'actionmailer'
  gem 'rails'
end

require 'rails/version'
puts "emulating Rails.version = #{version = Rails::VERSION::STRING}"

require 'active_support'
require 'active_record'

require 'action_view'
require 'action_controller'

if version >= '3.0.0'

  require 'rails'
  require 'rails/all'

  module SimpleCaptcha
    class Application < Rails::Application
      config.active_support.deprecation = :stderr
      paths.config.database File.expand_path('config/database.yml', File.dirname(__FILE__))
    end
  end

else

  require 'jdbc_adapter' if defined?(JRUBY_VERSION)

  ActiveRecord::Base.configurations = { 'test' => {
    'adapter' => 'sqlite3', 'database' => ':memory:'
  }}

end

module Rails
  class << self

    def initialized?
      @initialized || false
    end

    def initialized=(initialized)
      @initialized ||= initialized
    end

    def backtrace_cleaner
      @@backtrace_cleaner ||= begin
        require 'rails/gem_dependency' # backtrace_cleaner depends on this !
        require 'rails/backtrace_cleaner'
        Rails::BacktraceCleaner.new
      end
    end

    def root
      Pathname.new(RAILS_ROOT) if defined?(RAILS_ROOT)
    end

    def env
      @_env ||= begin
        ActiveSupport::StringInquirer.new(RAILS_ENV)
      end
    end

    def cache
      RAILS_CACHE
    end

    def version
      VERSION::STRING
    end

    def public_path
      @@public_path ||= self.root ? File.join(self.root, "public") : "public"
    end

    def public_path=(path)
      @@public_path = path
    end

  end
end

# Make double-sure the RAILS_ENV is set to test :
silence_warnings { RAILS_ENV = "test" }
Rails.env = 'test' if Rails.respond_to?(:env=)
FileUtils.mkdir_p("#{File.dirname(__FILE__)}/public")
silence_warnings { RAILS_ROOT = File.join(File.dirname(__FILE__)) }

module Rails # make sure we can set the logger
  class << self
    attr_accessor :logger
  end
end

require 'logger'
File.open(File.join(File.dirname(__FILE__), 'test.log'), 'w') do |file|
  Rails.logger = Logger.new(file.path)
  silence_warnings { RAILS_DEFAULT_LOGGER = Rails.logger }
end

require 'active_support/dependencies'

# setup auto loading as would happen in Rails :
autoload_paths =
  if ActiveSupport::Dependencies.respond_to?(:load_paths)
    ActiveSupport::Dependencies.load_paths
  else
    ActiveSupport::Dependencies.autoload_paths # 3.0+
  end
autoload_paths << File.join(File.dirname(__FILE__), '../lib')
#autoload_paths << File.join(File.dirname(__FILE__), '../app/controllers')
#autoload_paths << File.join(File.dirname(__FILE__), '../app/models')

if Rails.version >= '2.3.0'
  # Rails 2.3+ does this automatically for _plugins_ :
  $LOAD_PATH << File.expand_path('../app/controllers', File.dirname(__FILE__))
  $LOAD_PATH << File.expand_path('../app/models', File.dirname(__FILE__))
end

# Initialize the rails application
SimpleCaptcha::Application.initialize! if Rails.version >= '3.0.0'
