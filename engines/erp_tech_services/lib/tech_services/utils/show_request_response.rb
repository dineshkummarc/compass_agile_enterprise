# Log the HTTP Request and Response

# NOTE: To enable this add, or uncomment, this in the environment.rb
# or one of the environments in config/environments/*
#   config.middleware.use "ShowRequestResponse", true

class ShowRequestResponse

  def initialize(app, enable_logging = false)
    @app = app
    @log_enabled = true
  end

  def call(env)
    @req = Rack::Request.new(env)
    @status, @headers, @response = @app.call(env)
    
    # set headers here
    # @headers = { "Content-Type" => "application/pdf"}
    log "HTTP Response @status = #{@status.inspect}"
    log "HTTP Response @headers = #{@headers.inspect}" 
    [@status, @headers, @response]
  end

  def log(message)
    puts "ShowRequestResponse Middleware:: #{message}" if @log_enabled
  end

end
