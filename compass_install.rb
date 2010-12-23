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

File.unlink 'public/index.html' rescue Errno::ENOENT


patch_file 'config/environment.rb',
"require File.join(File.dirname(__FILE__), 'boot')",
"require File.join(File.dirname(__FILE__), '../vendor/plugins/erp_base_erp_svcs/boot')"
  
patch_file 'config/environment.rb',
"config.time_zone = 'UTC'",
"
 #add plugins
 #dependencies for plugins are defined in thier enviroment.rb
 config.add_plugin(:erp_base_erp_svcs)
 config.add_plugin(:erp_tech_services)
 config.add_plugin(:erp_dev_svcs)
 config.add_plugin(:erp_app)

 #load the rest of the plugins
 config.add_plugin(:all)

 #disable plugin
 #config.disable_plugin(:engines)",
:patch_mode => :insert_after

patch_file 'config/environment.rb',
 "Rails::Initializer.run do |config|",
 "init = Rails::Initializer.run do |config|",
 :patch_mode => :change

patch_file 'config/environment.rb',
 "  # config.i18n.default_locale = :de
 end",
 "#uncomment after installation of compass_erp base copies all plublic assests of plugins to public root
  #plugin_assets = init.loaded_plugins.map { |plugin| File.join(plugin.directory, 'public') }.reject { |dir| not (File.directory?(dir) and File.exist?(dir)) }
  #init.configuration.middleware.use TechServices::Utils::Rack::StaticOverlay, :roots => plugin_assets",
 :patch_mode => :insert_after

git :clone => 'git://github.com/portablemind-developers/compass.git "vendor/compass/engines" # this may take a bit grab a LARGE coffee...'
 
inside('vendor/compass/engines') do
  run 'git checkout'
end    

git :clone => 'git://github.com/portablemind-developers/data_migrator.git "vendor/compass/plugins/data_migrator" # this may take a bit grab a LARGE coffee...'

inside('vendor/compass/plugins/data_migrator') do
  run 'git checkout'
end

rake 'compass:install:core -R vendor/compass/engines/erp_base_erp_svcs/lib/tasks'
rake 'compass:assets:install'
#rake 'db:migrate_data'

FileUtils.cp "vendor/plugins/erp_app/public/index.html", "public/"

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
