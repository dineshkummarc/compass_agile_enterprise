require 'rubygems'
require 'rake'
require 'net/http'
require 'active_record'
include GC

namespace :solr do

  desc 'Starts Solr. Options accepted: RAILS_ENV=your_env, PORT=XX. Defaults to development if none.'
  task :start do
    require "#{File.dirname(__FILE__)}/../../config/solr_environment.rb"
    begin
      n = Net::HTTP.new('127.0.0.1', SOLR_PORT)
      #n.request_head('/').value
      raise Errno::ECONNREFUSED
    rescue Net::HTTPServerException #responding
      puts "Port #{SOLR_PORT} in use" and return

    rescue Errno::ECONNREFUSED #not responding
      Dir.chdir(SOLR_PATH) do
        exec "java #{SOLR_JVM_OPTIONS} -Dsolr.data.dir=#{SOLR_DATA_PATH} -Djetty.logs=#{SOLR_LOGS_PATH} -Djetty.port=#{SOLR_PORT} -jar start.jar"
      end
    end
  end

  desc 'Starts Solr. on windows . Options accepted: RAILS_ENV=your_env, PORT=XX. Defaults to development if none.'
  task :start_win do
  	require "#{File.dirname(__FILE__)}/../../config/solr_environment.rb"
    begin
    	
      n = Net::HTTP.new('localhost', SOLR_PORT)

      #this rake task relies on this call failing in a predictable way, however, the manner in
      #which it fails has change on the version of ruby and windows with which I'm working, so
      #I performed some surgery on the rescue operations below
      n.request_head('/').value

    rescue Net::HTTPServerException #responding
      puts "Port #{SOLR_PORT} in use" and return

      #For now (Windows is only used in dev), we'll simply rescue ALL failures and attempt to start a new
      #SOLR server. Here is the existing line and the new line.
      #Previous implementation only looks for bad file descriptor to indicate that the server is not
      #responding
      #rescue Errno::EBADF #not responding
      #
      #The newest hack (in this string of hacks), just takes any failure and tries to execute the SOLR
      #startup process.
      #TODO - the actual error is "the host actively refused the connection" - perhaps checking for that
      #would be slightly more predictable - at least it would be the same level of hack that the previous
      #implementation was.
      #
    rescue
      Dir.chdir(SOLR_PATH) do
      	puts "java -Dsolr.data.dir=solr/data/#{ENV['RAILS_ENV']} -Djetty.port=#{SOLR_PORT} -jar start.jar"
        exec "java -Dsolr.data.dir=solr/data/#{ENV['RAILS_ENV']} -Djetty.port=#{SOLR_PORT} -jar start.jar"
        sleep(5)
        puts "#{ENV['RAILS_ENV']} Solr started sucessfuly on #{SOLR_PORT}, pid: #{pid}."
      end
    end
  end  

  desc 'Stops Solr. Specify the environment by using: RAILS_ENV=your_env. Defaults to development if none.'
  task :stop do
    require "#{File.dirname(__FILE__)}/../../config/solr_environment.rb"
    fork do
      file_path = "#{SOLR_PIDS_PATH}/#{ENV['RAILS_ENV']}_pid"
      if File.exists?(file_path)
        File.open(file_path, "r") do |f| 
          pid = f.readline
          Process.kill('TERM', pid.to_i)
        end
        File.unlink(file_path)
        Rake::Task["solr:destroy_index"].invoke if ENV['RAILS_ENV'] == 'test'
        puts "Solr shutdown successfully."
      else
        puts "PID file not found at #{file_path}. Either Solr is not running or no PID file was written."
      end
    end
  end

  desc 'Remove Solr index'
  task :destroy_index do
    require "#{File.dirname(__FILE__)}/../../config/solr_environment.rb"
    raise "In production mode.  I'm not going to delete the index, sorry." if ENV['RAILS_ENV'] == "production"
    if File.exists?("#{SOLR_DATA_PATH}")
      Dir["#{SOLR_DATA_PATH}/index/*"].each{|f| File.unlink(f)}
      Dir.rmdir("#{SOLR_DATA_PATH}/index")
      puts "Index files removed under " + ENV['RAILS_ENV'] + " environment"
    end
  end
  # this task is by Henrik Nyh
  # http://henrik.nyh.se/2007/06/rake-task-to-reindex-models-for-acts_as_solr
  desc %{Reindexes data for all acts_as_solr models. Clears index first to get rid of orphaned records and optimizes index afterwards. RAILS_ENV=your_env to set environment. ONLY=book,person,magazine to only reindex those models; EXCEPT=book,magazine to exclude those models. START_SERVER=true to solr:start before and solr:stop after. BATCH=123 to post/commit in batches of that size: default is 300. CLEAR=false to not clear the index first; OPTIMIZE=false to not optimize the index afterwards.}
  task :reindex => :environment do
    require "#{File.dirname(__FILE__)}/../../config/solr_environment.rb"

    includes = env_array_to_constants('ONLY')
    if includes.empty?
      includes = Dir.glob("#{RAILS_ROOT}/app/models/*.rb").map { |path| File.basename(path, ".rb").camelize.constantize }
    end
    excludes = env_array_to_constants('EXCEPT')
    includes -= excludes
    
    optimize            = env_to_bool('OPTIMIZE',     true)
    start_server        = env_to_bool('START_SERVER', false)
    clear_first         = env_to_bool('CLEAR',       true)
    batch_size          = ENV['BATCH'].to_i.nonzero? || 25
    debug_output        = env_to_bool("DEBUG", false)

    RAILS_DEFAULT_LOGGER.level = ActiveSupport::BufferedLogger::INFO unless debug_output

    if start_server
      puts "Starting Solr server..."
      Rake::Task["solr:start"].invoke 
    end
    
    # Disable solr_optimize
    module ActsAsSolr::CommonMethods
      def blank() end
      alias_method :deferred_solr_optimize, :solr_optimize
      alias_method :solr_optimize, :blank
    end
    
    models = includes.select { |m| m.respond_to?(:rebuild_solr_index) }    
    models.each do |model|
      if clear_first
        puts "Clearing index for #{model}..."
        ActsAsSolr::Post.execute(Solr::Request::Delete.new(:query => "#{model.solr_configuration[:type_field]}:#{model}")) 
        ActsAsSolr::Post.execute(Solr::Request::Commit.new)
      end
    end

    puts "loading special parties"
    parties = Party.find_by_sql("select distinct * from parties where id in (select distinct party_id from users)")
    parties.each do |party|
      Party.solr_add(party.to_solr_doc)
      Party.solr_commit
    end

    models.each do |model|
      puts "Rebuilding index for #{model}..."
      model.rebuild_solr_index(batch_size) unless model == Party
    end

    parties_count = Party.count(:all)
    count_index = 0
    limit = 100
    party_start_id = 0

    while count_index < parties_count
      parties = Party.find(:all, :limit => limit, :conditions => ["id > ?", party_start_id])
      count_index = parties_count if parties.blank?
      parties.each do |party|
        Party.solr_add(party.to_solr_doc)
        Party.solr_commit
        party_start_id = party.id
        count_index += 1
      end

      parties = nil
      garbage_collect
    end

    if models.empty?
      puts "There were no models to reindex."
    elsif optimize
      puts "Optimizing..."
      models.last.deferred_solr_optimize
    end

    if start_server
      puts "Shutting down Solr server..."
      Rake::Task["solr:stop"].invoke 
    end
    
  end

  desc %{Reindexes data for all acts_as_solr models. RAILS_ENV=your_env to set environment. ONLY=book,person,magazine to only reindex those models; EXCEPT=book,magazine to exclude those models. START_SERVER=true to solr:start before and solr:stop after. BATCH=123 to post/commit in batches of that size: default is 300. CLEAR=false to not clear the index first; OPTIMIZE=false to not optimize the index afterwards.}
  task :index => :environment do
    require "#{File.dirname(__FILE__)}/../../config/solr_environment.rb"

    includes = env_array_to_constants('ONLY')
    if includes.empty?
      includes = Dir.glob("#{RAILS_ROOT}/app/models/*.rb").map { |path| File.basename(path, ".rb").camelize.constantize }
    end
    excludes = env_array_to_constants('EXCEPT')
    includes -= excludes

    optimize            = env_to_bool('OPTIMIZE',     true)
    start_server        = env_to_bool('START_SERVER', false)
    batch_size          = ENV['BATCH'].to_i.nonzero? || 1
    debug_output        = env_to_bool("DEBUG", false)

    RAILS_DEFAULT_LOGGER.level = ActiveSupport::BufferedLogger::INFO unless debug_output

    if start_server
      puts "Starting Solr server..."
      Rake::Task["solr:start"].invoke
    end

    # Disable solr_optimize
    module ActsAsSolr::CommonMethods
      def blank() end
      alias_method :deferred_solr_optimize, :solr_optimize
      alias_method :solr_optimize, :blank
    end

    puts "loading special parties"
    parties = Party.find_by_sql("select distinct * from parties where id in (select distinct party_id from users)")
    parties.each do |party|
      Party.solr_add(party.to_solr_doc)
      Party.solr_commit
    end

    models = includes.select { |m| m.respond_to?(:rebuild_solr_index) }
    models.each do |model|
      puts "Rebuilding index for #{model}..."
      model.rebuild_solr_index(batch_size) unless model == Party
    end

    parties_count = Party.count(:all)
    count_index = 0
    limit = 100
    party_start_id = 0

    while count_index < parties_count
      parties = Party.find(:all, :limit => limit, :conditions => ["id > ?", party_start_id])
      count_index = parties_count if parties.blank?
      parties.each do |party|
        Party.solr_add(party.to_solr_doc)
        Party.solr_commit
        party_start_id = party.id
        count_index += 1
      end

      parties = nil
      garbage_collect
    end

    if models.empty?
      puts "There were no models to reindex."
    elsif optimize
      puts "Optimizing..."
      models.last.deferred_solr_optimize
    end

    if start_server
      puts "Shutting down Solr server..."
      Rake::Task["solr:stop"].invoke
    end

  end

  task :cron_update => :environment do
    require "#{File.dirname(__FILE__)}/../../config/solr_environment.rb"

    includes = env_array_to_constants('ONLY')
    if includes.empty?
      includes = Dir.glob("#{RAILS_ROOT}/app/models/*.rb").map { |path| File.basename(path, ".rb").camelize.constantize }
    end
    excludes = env_array_to_constants('EXCEPT')
    includes -= excludes

    optimize            = env_to_bool('OPTIMIZE',     true)
    start_server        = env_to_bool('START_SERVER', false)
    batch_size          = ENV['BATCH'].to_i.nonzero? || 1
    debug_output        = env_to_bool("DEBUG", false)

    RAILS_DEFAULT_LOGGER.level = ActiveSupport::BufferedLogger::INFO unless debug_output

    if start_server
      puts "Starting Solr server..."
      Rake::Task["solr:start"].invoke
    end

    # Disable solr_optimize
    module ActsAsSolr::CommonMethods
      def blank() end
      alias_method :deferred_solr_optimize, :solr_optimize
      alias_method :solr_optimize, :blank
    end

    #postal_address
    postal_addresses = PostalAddress.find(:all, :conditions => ["updated_at > ?", 10.minutes.ago])
    postal_addresses.each do |postal_address|
      PostalAddress.solr_add(postal_address.to_solr_doc)
      PostalAddress.solr_commit
    end

    #page
    pages = Page.find(:all, :conditions => ["updated_at > ?", 10.minutes.ago])
    pages.each do |page|
      Page.solr_add(page.to_solr_doc)
      Page.solr_commit
    end

    #kb_article
    articles = KbArticle.find(:all, :conditions => ["updated_at > ?", 10.minutes.ago])
    articles.each do |article|
      KbArticle.solr_add(article.to_solr_doc)
      KbArticle.solr_commit
    end

    #party
    parties = Party.find(:all, :conditions => ["updated_at > ?", 10.minutes.ago])
    parties.each do |party|
      party.solr_save
    end

    users = User.find(:all, :conditions => ["lock_count > 5 or lock_count is null"])
    users.each do |user|
      user.lock_count = 0
      user.save(false)
    end
  end

  desc %{Reindexes data for all acts_as_solr models. RAILS_ENV=your_env to set environment. ONLY=book,person,magazine to only reindex those models; EXCEPT=book,magazine to exclude those models. START_SERVER=true to solr:start before and solr:stop after. BATCH=123 to post/commit in batches of that size: default is 300. CLEAR=false to not clear the index first; OPTIMIZE=false to not optimize the index afterwards.}
  task :resume => :environment do
    require "#{File.dirname(__FILE__)}/../../config/solr_environment.rb"

    includes = env_array_to_constants('ONLY')
    if includes.empty?
      includes = Dir.glob("#{RAILS_ROOT}/app/models/*.rb").map { |path| File.basename(path, ".rb").camelize.constantize }
    end
    excludes = env_array_to_constants('EXCEPT')
    includes -= excludes

    optimize            = env_to_bool('OPTIMIZE',     true)
    start_server        = env_to_bool('START_SERVER', false)
    batch_size          = ENV['BATCH'].to_i.nonzero? || 1
    debug_output        = env_to_bool("DEBUG", false)

    RAILS_DEFAULT_LOGGER.level = ActiveSupport::BufferedLogger::INFO unless debug_output

    if start_server
      puts "Starting Solr server..."
      Rake::Task["solr:start"].invoke
    end

    # Disable solr_optimize
    module ActsAsSolr::CommonMethods
      def blank() end
      alias_method :deferred_solr_optimize, :solr_optimize
      alias_method :solr_optimize, :blank
    end

    ignore_ids = []

    puts "loading special parties"
    parties = Party.find_by_sql("select distinct * from parties where id in (select distinct party_id from users)")
    parties.each do |party|
      ignore_ids << party.id
      party.solr_save
      puts "Indexed party id: #{party.id}"
    end

    puts "Resuming where party left of"
    
    parties_count = Party.count(:all)
    count_index = 0
    limit = 100
    party_start_id = 0
    
    while count_index < parties_count
      parties = Party.find(:all, :limit => limit, :conditions => ["id > ?", party_start_id])
      count_index = parties_count if parties.blank?
      parties.each do |party|
        unless ignore_ids.include?(party.id)
          if party.username_for_solr.blank?
            ignore_ids << party.id
            party.solr_save
            puts "Indexed party id: #{party.id}"
          end
        end
        party_start_id = party.id
        count_index += 1
      end
      
      parties = nil
      garbage_collect
    end

    models = includes.select { |m| m.respond_to?(:rebuild_solr_index) }
    models.each do |model|
      puts "Rebuilding index for #{model}..."
      model.rebuild_solr_index(batch_size) unless model == Party
    end
    
    parties_count = Party.count(:all)
    count_index = 0
    limit = 100
    party_start_id = 0

    while count_index < parties_count
      parties = Party.find(:all, :limit => limit, :conditions => ["id > ?", party_start_id])
      count_index = parties_count if parties.blank?
      parties.each do |party|
        unless ignore_ids.include?(party.id)
          party.solr_save
        end
        party_start_id = party.id
        count_index += 1
      end

      parties = nil
      garbage_collect
    end

    if models.empty?
      puts "There were no models to reindex."
    elsif optimize
      puts "Optimizing..."
      models.last.deferred_solr_optimize
    end

    if start_server
      puts "Shutting down Solr server..."
      Rake::Task["solr:stop"].invoke
    end

  end

# added by CW
#  rake solr:reindex_model[<klass_name>, <start_id>, <end_id | LAST >, <batch_size>, <verbose>]
#  where:
# <klass_name> is the name of the model you want to index
# <start_id> is the starting id of the model to be index
# <end_id> is the ending id of the model to be indexed. If LAST is supplied the last id of the specified <klass_name> model will be supplied
# <batch_size> defines limits the number of <klass_name> models that are retrieved at a time. If no <batch_size> is supplied the default is 200
# <verbose> controls what is echoed to the console. If verbose is not supplied a minimum level of information is displayed. If verbose==true more details is provided
#
# Examples
#
# rake solr:reindex_model[Party,1,LAST,100,true] will reindex Party starting at id #1 and going to the last id with a batch size of 100 and verbose logging on
#
# rake solr:reindex_model[Party,5020,LAST] will reindex Party starting at id#5020 and going to the last id with the default batch size of 200 and verbose logging off
#
# NOTE should call rake solr:destroy_index when starting at the first record
  desc %{Reindexes model data for range of id's . call solr:destroy_index to clear all before a clean reindex}
  task :reindex_model, [:model_type, :startx, :endx,:batch_size, :verbose] => :environment  do | t, args|
    puts "Reindex started at:#{Time.now}"
    start_time=Time.now.to_i
    if(args.model_type==nil)
      return
    end
  
    klass = Kernel.const_get args.model_type
    
    puts "reindexing #{klass} for id range[ #{args.startx}, #{args.endx} ] batch_size=#{args.batch_size}"
    
    avg=0
    avg_counter=0

    first_klass=args.startx.to_i
    last_klass=args.endx.to_i
    batch_size=200
    if(args.endx=="LAST")
      last_klass_instance=klass.find(:last)
      last_klass=last_klass_instance.id

      puts "LAST #{klass}=#{last_klass.id}"

    end
    if(first_klass>last_klass)
      puts "Invalid range : #{args.startx}>#{args.endx}"
    end
    if((args.batch_size ==nil) || (args.batch_size.to_i<1))
      
      puts "Using default batch size=#{batch_size}"
    else
      batch_size=args.batch_size.to_i
    end
    if((last_klass-first_klass)>batch_size)
      tstart=first_klass
      tend=first_klass+batch_size
      batch_loop_count=(tend-tstart)/batch_size
      #puts "will require (#{batch_loop_count}) batch cycles"
      #requires batching
      
      while(tend<last_klass)
        batch_avg=reindex_klass(klass,tstart,tend,args.verbose)
        
        if(args.verbose="true")
          puts ("Current REINDEX estimated time left = #{(last_klass-tend)*batch_avg} secs")
        end
        tend+=batch_size
        tstart+=batch_size
        avg+=batch_avg
        avg_counter+=1

      end
     
     
      
    else
      #no matching required
      reindex_klass(klass,first_klass,last_klass,args.verbose)
    end

    end_time=Time.now.to_i

    puts "total REINDEX time=#{(end_time-start_time)} secs - avg index time #{(avg/avg_counter)} secs/#{klass}"
    puts "REINDEX ended at #{Time.now}"
   
  end
  def reindex_klass(klass,startx,endx,verbose)

    reindex_time=0
    total_reindex_time=0
    if(verbose=="true")
      puts "reindexing #{klass} [#{startx},#{endx}]"
    end
    k=klass.find(:all, :conditions=>"id >= #{startx} and id <= #{endx}")
    k.each do |target_klass|
      if(verbose=="true")
        puts "reindexing #{klass}.id=#{target_klass.id}"
      end
      time_start=Time.now.to_i
      puts "Indexing: #{target_klass.id}"
      target_klass.solr_save_without_commit  # this is where the index magic happens

      end_time=Time.now.to_i
      #puts "calc reindex time"
      reindex_time=(end_time-time_start)
      if(verbose=="true")
        puts " Last #{klass}.id= #{target_klass.id} REINDEXED in #{reindex_time} secs"
      end
      total_reindex_time+=reindex_time
     

    end
    klass.solr_commit
    avg=total_reindex_time/k.size
    
    puts " reindexed #{klass}[#{startx},#{endx}] in #{total_reindex_time} secs - avg= #{avg} secs/party"
    
    return total_reindex_time
  end
  def env_array_to_constants(env)
    env = ENV[env] || ''
    env.split(/\s*,\s*/).map { |m| m.singularize.camelize.constantize }.uniq
  end
  
  def env_to_bool(env, default)
    env = ENV[env] || ''
    case env
    when /^true$/i then true
    when /^false$/i then false
    else default
    end
  end
end