![Logo](http://github.com/portablemind/compass_agile_enterprise/raw/master/engines/erp_app/public/images/art/compass-logo-1-medium.png)

===Welcome to Compass Agile Enterprise===

Compass Agile Enterprise is a set of Rails Engines that incrementally add the functionality of an ERP and CMS to a Rails application.

It is meant to stay completely out of the directories that a Rails application developer would use, so your app and public directories and clean for you to use.

=================

Compass.rake README

TASK DESCRIPTIONS
=================

compass:install:core - installs the core compass plugins

compass:install:default - installs the core compass plugin and the default (eCommerce) plugins

compass:bootstrap:data - This rake task sets up some default data such as an Administrative user account and desktop applications for Iris.
 
If you run the installer below the following is executed

compass:install:core 

compass:bootstrap:data

 
 COMPASS_INSTALLATION
 ====================
 
 Compass installation follows the following simple four step process:
 
 (Step 1) Create a new Rails application using the compass installer template
     
 rails [myappname] -m http://www.portablemind.com/file_assets/compass_install.rb
