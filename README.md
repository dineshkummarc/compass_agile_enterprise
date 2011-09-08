![Logo](http://github.com/portablemind/compass_agile_enterprise/raw/master/engines/erp_app/public/images/art/compass-logo-1-medium.png)

===Welcome to Compass Agile Enterprise===

Compass Agile Enterprise is a set of Rails Engines that incrementally add the functionality of an ERP and CMS to a Rails application.

It is meant to stay completely out of the directories that a Rails application developer would use, so your app and public directories and clean for you to use.

=================

Compass.rake README

 
COMPASS_INSTALLATION
====================
 
 To install Compass AE simple add the gems you want to your gem file and run bundle install:
 
 * gem 'erp_base_erp_svcs', :path => '../compass_agile_enterprise/erp_base_erp_svcs'
 * gem 'erp_dev_svcs', :path => '../compass_agile_enterprise/erp_dev_svcs'
 * gem 'erp_tech_svcs', :path => '../compass_agile_enterprise/erp_tech_svcs'
 * gem 'erp_app', :path => '../compass_agile_enterprise/erp_app'
 * gem 'knitkit', :path => '../compass_agile_enterprise/knitkit'
 * gem 'rails_db_admin', :path => '../compass_agile_enterprise/rails_db_admin'
 * gem 'erp_forms', :path => '../compass_agile_enterprise/erp_forms'
 * gem 'console', :path => '../compass_agile_enterprise/console'
 
 run 
 
     rake db:migrate
 
 and
 
     rake db:migrate_data
 
 start up your server 
 
     rails s
 
 navigate to 
 
     http://localhost:3000/erp_app/login
 
 Login To: Compass Desktop
 Username: admin
 Password: password
 
 Enjoy !
 
