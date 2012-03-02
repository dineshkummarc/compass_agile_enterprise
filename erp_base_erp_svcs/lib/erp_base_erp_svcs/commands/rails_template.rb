def patch_file(path, current, insert, options = {})
  options = {
    :patch_mode => :insert_after
  }.merge(options)

  old_text = current
  new_text = patch_string(current, insert, options[:patch_mode])

  content = File.open(path) { |f| f.read }
  content.gsub!(old_text, new_text) unless content =~ /#{Regexp.escape(insert)}/mi
  File.open(path, 'w') { |f| f.puts(content) }
end

def append_file(path, content)
  File.open(path, 'a') { |f| f.puts(content) }
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

patch_file 'config/initializers/session_store.rb',
"# #{app_const}::Application.config.session_store :active_record_store",
"#{app_const}::Application.config.session_store :active_record_store",
:patch_mode => :change

patch_file 'config/routes.rb',
"#{app_const}::Application.routes.draw do",
" mount ErpApp::Engine => '/erp_app'
 mount RailsDbAdmin::Engine => '/rails_db_admin'
 mount Knitkit::Engine => '/knitkit'
 mount ErpTechSvcs::Engine => '/erp_tech_svcs'
 mount CompassAeConsole::Engine => '/compass_ae_console'",
:patch_mode => :insert_after

patch_file 'config/environments/production.rb',
"  config.serve_static_assets = false",
"  config.serve_static_assets = true",
:patch_mode => :change

patch_file 'config/environments/production.rb',
"  config.assets.compile = false",
"  config.assets.compile = true",
:patch_mode => :change

append_file 'Gemfile',
"
gem 'erp_base_erp_svcs'
gem 'erp_dev_svcs'
gem 'erp_tech_svcs'
gem 'erp_app'
gem 'erp_forms'
gem 'knitkit'
gem 'rails_db_admin'
gem 'compass_ae_console'
"

puts <<-end

Thanks for installing Compass AE!

We've performed the following tasks:

* Replaced the index.html page from /public with our Compass AE splash screen
* patched config/initializers/session_store.rb to use ActiveRecord for your session store
* patched config/environments/production.rb and set config.serve_static_assets = true
* patched config/environments/production.rb and set config.assets.compile = true
* Added the core Compass AE gems to your Gemfile

Now we will bundle it up and run the migrations...

end
