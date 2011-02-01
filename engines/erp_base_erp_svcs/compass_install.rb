# compass installer
# copyright 2010 portableminds.com/tnsolutionsinc.com

# modify the specified file at the designated location using the given string of character
# based on the specified options

# path    - path to file to patch
# current - target string 
# insert  - replacement string
# options - declare patch mode
def patch_file(path, current, insert, options = {})
  options = {
    :patch_mode => :insert_after
  }.merge(options)

  old_text = current
  new_text = patch_string(current, insert, options[:patch_mode])

  content = File.open(path) { |f| f.read }
  content.gsub!(old_text, new_text) unless content =~ /#{Regexp.escape(insert)}/mi
  File.open(path, 'w') { |f| f.write(content) }
end


# modify the supplied string with the specified string using the selected mode

# current - the string being operated on
# insert  - the string to prepend,append or replace the current string
# mode    - :change, :insert_after, :insert_before

def patch_string(current, insert, mode = :insert_after)
  case mode
  when :change
    "#{insert}"
  when :insert_after
    "#{current}\n#{insert}"
  when :insert_before
    "#{insert}\n#{current}"
  else
    patch_string(current, insert, :insert_after)
  end
end
puts "\n--Using Compass Template--\n\n"

# remove the index.html file
File.unlink 'public/index.html' rescue Errno::ENOENT

# add the 'erp_base_erp_svcs/boot' file to the Rails bootstrap
patch_file 'config/environment.rb',
"require File.join(File.dirname(__FILE__), 'boot')",
"require File.join(File.dirname(__FILE__), '../vendor/compass/engines/erp_base_erp_svcs/boot')"
  

# add the plugin dependencies to the Rails Initializer 
patch_file 'config/environment.rb',
"config.time_zone = 'UTC'",
"
 #add plugins
 #dependencies for plugins are defined in their enviroment.rb
 config.add_plugin(:erp_base_erp_svcs)
 config.add_plugin(:erp_tech_services)
 config.add_plugin(:erp_dev_svcs)
 config.add_plugin(:erp_app)

 #load the rest of the plugins
 config.add_plugin(:all)

 #disable plugin
 #config.disable_plugin(:engines)",
:patch_mode => :insert_after

# replace the standard Rails::Initializer syntax with 
# the assignment to the 'init' value
patch_file 'config/environment.rb',
 "Rails::Initializer.run do |config|",
 "init = Rails::Initializer.run do |config|",
 :patch_mode => :change

# add the plugin assets loader after the internationalization configuration
patch_file 'config/environment.rb',
 "  # config.i18n.default_locale = :de
 end",
 "#uncomment after installation of compass_erp base copies all plublic assests of plugins to public root
  #plugin_assets = init.loaded_plugins.map { |plugin| File.join(plugin.directory, 'public') }.reject { |dir| not (File.directory?(dir) and File.exist?(dir)) }
  #init.configuration.middleware.use TechServices::Utils::Rack::StaticOverlay, :roots => plugin_assets",
 :patch_mode => :insert_after

puts "Getting latest Compass components. You might want to grab a LARGE coffee...\n\n"
 
# retrieve the target engines from the SVN repo 

#create an array of all plugins to move
svn_path="http://www.portablemind.com/svn_compass_erp/branches/look_and_book_2/vendor/plugins"
allPlugins = %w(after_commit 
                erp_base_erp_svcs
                erp_tech_services
                erp_app 
                erp_dev_svcs 
                data_migrator
                data_orchestrator 
                erp_agreements 
                erp_commerce 
                erp_communication_events 
                erp_inventory 
                erp_orders 
                erp_products 
                erp_rules 
                erp_search 
                erp_txns_and_accts 
                ext_scaffold 
                master_data_management
                timeshare)
 
inside('vendor/compass/engines') do
	 
	# loop over plugins
	allPlugins.each do |plugin|
    	puts "\nRetrieving Compass Plugin: #{plugin}\n\n"
     	# retrieve from SVN repo
     	run "svn export #{svn_path}/#{plugin}"
	end
end    

puts "getting latest compass framework plugins..."

# retrieve the data migrator plugin
inside('vendor/compass/plugins') do
  run 'svn export http://www.portablemind.com/svn_compass_erp/branches/house_keeping/vendor/plugins/data_migrator'
end

# install the core engines (erp_base_erp_svcs, erp_tech_services, erp_dev_svcs, erp_app)
rake 'compass:install:core -R vendor/compass/engines/erp_base_erp_svcs/lib/tasks'
# perform symbolic link plulgins for assets on *nix 
# or copy plugins for windows
rake 'compass:assets:install'
#rake 'db:migrate_data'

# execute compass bootstrap data load
# rake 'compass:bootstrap:data'


#copy the compass index page
FileUtils.cp "vendor/plugins/erp_app/public/index.html", "public/"

# display the installer summary
puts <<-end

Thanks for installing Compass!

We've performed the following tasks:

* created a fresh Rails app
* copied compass to vendor/compass
* patched config/environment.rb
* installed compass core engines to vendor/plugins

You can now do:

cd #{File.basename(@root)}
ruby script/server
open http://localhost:3000

You should see compass installation screen.
enjoy!

end
