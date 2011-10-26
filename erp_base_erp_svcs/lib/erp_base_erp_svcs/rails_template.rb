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
"# ActionController::Base.session_store = :active_record_store",
"  ActionController::Base.session_store = :active_record_store",
:patch_mode => :change

patch_file 'config/routes.rb',
"# match ':controller(/:action(/:id(.:format)))'cd",
" mount ErpApp::Engine => '/erp_app'
 mount RailsDbAdmin::Engine => '/rails_db_admin'
 mount Knitkit::Engine => '/knitkit'
 mount ErpTechSvcs::Engine => '/erp_tech_svcs'
 mount Console::Engine => '/console'",
:patch_mode => :insert_after

patch_file 'config/environments/production.rb',
"  config.serve_static_assets = false",
"  config.serve_static_assets = true",
:patch_mode => :change

append_file 'config/environment.rb',
"
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => '127.0.0.1',
  :port => 25
}"

append_file 'GemFile',
"
gem 'erp_base_erp_svcs', :path => '../compass_agile_enterprise/erp_base_erp_svcs'
gem 'erp_dev_svcs', :path => '../compass_agile_enterprise/erp_dev_svcs'
gem 'erp_tech_svcs', :path => '../compass_agile_enterprise/erp_tech_svcs'
gem 'erp_app', :path => '../compass_agile_enterprise/erp_app'
gem 'erp_forms', :path => '../compass_agile_enterprise/erp_forms'
gem 'knitkit', :path => '../compass_agile_enterprise/knitkit'
gem 'rails_db_admin', :path => '../compass_agile_enterprise/rails_db_admin'
gem 'console', :path => '../compass_agile_enterprise/console'
"

puts <<-end

Thanks for installing Compass AE!

We've performed the following tasks:

* created a fresh Rails app
* patched config/environment.rb
* patched config/initializers/session_store.rb
* added core Compass AE gems to GemFile

You can now do:

rails s
open http://localhost:3000/erp_app/desktop/

You should see compass Single Sign On screen.
username: admin
passwrod: password
enjoy!

end
