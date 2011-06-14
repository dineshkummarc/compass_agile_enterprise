require 'logger'

class CompassLogger
  include Singleton

  @@writers = {}

  def CompassLogger.debug(msg)
    if defined?(logger)
      logger.debug(msg)
    else
      CompassLogger.app_logger()
      @@writers["app_logger"].debug(msg)
    end
  end
  
  def CompassLogger.info(msg)
    if defined?(logger)
      logger.info(msg)
    else
      CompassLogger.app_logger()
      @@writers["app_logger"].info(msg)
    end
  end

  def CompassLogger.warn(msg)
    if defined?(logger)
      logger.warn(msg)
    else
      CompassLogger.app_logger()
      @@writers["app_logger"].warn(msg)
    end
  end

  def CompassLogger.error(msg)
    if defined?(logger)
      logger.error(msg)
    else
      CompassLogger.app_logger()
      @@writers["app_logger"].error(msg)
    end
  end

  def CompassLogger.fatal(msg)
    if defined?(logger)
      logger.fatal(msg)
    else
      CompassLogger.app_logger()
      @@writers["app_logger"].fatal(msg)
    end
  end

  def CompassLogger.stdout(msg)
    if CompassLogger.log_level() == 0
      puts msg
    end
  end
  
  def CompassLogger.method_missing(method, *args, &block)
    unless @@writers.has_key?(method)
      logger = Logger.new(CompassLogger.log_path(method))
      logger.level = CompassLogger.log_level()
      @@writers[method] = logger
    end
    @@writers[method]
  end

  def CompassLogger.app_logger()
    path = "#{RAILS_ROOT}/log/#{RAILS_ENV rescue 'rake'}.log"
    unless RUBY_PLATFORM =~ /(:?mswin|mingw|darwin)/
      path = "/var/log/rails/#{RAILS_ENV rescue 'rake'}.log"
    end
    unless @@writers.has_key?("app_logger")
      logger = Logger.new(path)
      logger.level = CompassLogger.log_level()
      @@writers["app_logger"] = logger
    end
  end

  def CompassLogger.log_level()
    ActiveRecord::Base.logger.level rescue Logger::DEBUG
  end

  def CompassLogger.log_path(method)
    if RUBY_PLATFORM =~ /(:?mswin|mingw|darwin)/
     return "#{RAILS_ROOT}/log/#{RAILS_ENV rescue ''}_#{method}.log"
   else
     return "/var/log/rails/#{RAILS_ENV rescue ''}_#{method}.log"
   end
  end
end