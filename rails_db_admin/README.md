#Rails DB Admin

Rails DB Admin is an application that sits on top of the Compass AE framework that adds database management capabilities.

![Logo](http://development.compassagile.com/sites/site-1/images/rails_db_admin.png?1323095155)

##Initializer Options

- query\_location
  - This is the location to save queries to, in respect to Rails.root.
  - Default : File.join('lib', 'rails_db_admin', 'queries')

### Override Initializer

To override these settings simple create a rails_db_admin.rb file in your initializers and override the config options you want

    Rails.application.config.rails_db_admin.configure do |config|
      config.query_location = File.join('lib', 'rails_db_admin', 'queries')
    end
    Rails.application.config.rails_db_admin.configure!

##Getting Started

There is a gem to help you get started

Install the gem

    gem install compass_ae_starter_kit

Or

clone the repository [Compass AE Starter Kit](https://github.com/portablemind/compass_ae_starter_kit)

    git clone https://github.com/portablemind/compass_ae_starter_kit
