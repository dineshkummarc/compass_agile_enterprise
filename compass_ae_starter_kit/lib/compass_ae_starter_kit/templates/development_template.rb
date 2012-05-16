load File.join(File.dirname(__FILE__),'../file_support.rb')

File.unlink 'public/index.html' rescue Errno::ENOENT
FileUtils.cp File.join(File.dirname(__FILE__),'../../../public','index.html'), 'public/index.html'

CompassAeStarterKit::FileSupport.patch_file 'config/initializers/session_store.rb',
"# #{app_const}.config.session_store :active_record_store",
"#{app_const}.config.session_store :active_record_store #use active_record for session storage, this is needed for knitkit",
:patch_mode => :change

CompassAeStarterKit::FileSupport.patch_file 'config/routes.rb',
"#{app_const}.routes.draw do",
"  #mount CompassAE engines
  ErpBaseErpSvcs.mount_compass_ae_engines(self)",
:patch_mode => :insert_after

CompassAeStarterKit::FileSupport.patch_file 'config/environments/production.rb',
"  config.serve_static_assets = false",
"  config.serve_static_assets = true",
:patch_mode => :change

CompassAeStarterKit::FileSupport.patch_file 'config/environments/production.rb',
"  config.assets.compile = false",
"  config.assets.compile = true",
:patch_mode => :change

git :clone => 'git://github.com/portablemind/compass_agile_enterprise.git "lib/compass_agile_enterprise"'

inside('lib/compass_agile_enterprise') do
  run 'git checkout'
end

CompassAeStarterKit::FileSupport.append_file 'Gemfile',
"
path './lib/compass_agile_enterprise' do
  gem 'erp_base_erp_svcs'
  gem 'erp_tech_svcs'
  gem 'erp_app'
  gem 'erp_forms'
  gem 'knitkit'
  gem 'rails_db_admin'
  gem 'compass_ae_console'
end
"

puts <<-end

Thanks for installing Compass AE!

We've performed the following tasks:

* Replaced the index.html page from /public with our Compass AE splash screen
* patched config/initializers/session_store.rb to use ActiveRecord for your session store
* patched config/environments/production.rb and set config.serve_static_assets = true
* patched config/environments/production.rb and set config.assets.compile = true
* Added the core Compass AE gems to your Gemfile and cloned our repository and pointed the Compass AE gems to it

Now we will bundle it up and run the migrations...

end
