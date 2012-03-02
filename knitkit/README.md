#Knitkit CMS

Knitkit is an application that sits on top of the Compass AE framework that adds a fully functional CMS to Compass AE.  It integrates with Amazon S3 and has extensions for our <a href="https://github.com/portablemind/Erp-Modules">Erp Modules</a>.

![Logo](http://development.compassagile.com/sites/site-1/images/knitkit.png?1323038265)

##Initializer Options

- unauthorized\_url
  - Url to redirect to when user attempts to navigate to a page they are not authorized to view.
  - Default : '/unauthorized'
- ignored\_prefix\_paths
  - Array of paths for Knitkit to ignore.
  - Default : []
- file\_assets\_location
  - Location, in respect to Rails.root, that you want files to upload to and created in within knikit.
  - Default : 'knitkit_assets'

### Override Initializer

To override these settings simple create a knikit.rb file in your initializers and override the config options you want

    Rails.application.config.knitkit.configure do |config|
      config.unauthorized_url     = '/unauthorized'
      config.ignored_prefix_paths = []
      config.file_assets_location = 'knitkit_assets'
    end
    Rails.application.config.knitkit.configure!
