#ErpTechSvcs

This engine is implemented with the premise that services like logging, tracing and encryption would likely already exist in many organizations, so they are factored here so they can easily be re-implemented. There are default implementations here, and we track several excellent Rails projects as potential implementations of services like security and content/digital asset mgt.

##Initializer Options

- installation\_domain
  - The domain that your Compass AE instance is installed at.
  - Default : 'localhost:3000'
- login\_url
  - Path to the login page.
  - Default : '/erp_app/login'
- email\_notifications\_from
  - From address for email notifications.
  - Default : 'notifications@noreply.com'
- max\_file\_size\_in\_mb
  - Max allowed file upload size in mega bytes.
  - Default : 5
- file\_assets\_location
  - Where you want file_assets to be saved to.
  - Default : file_assets
- file\_storage
  - File storage to use either s3 or filesystem.
  - Default : :filesystem

### Override Initializer

To override these settings simple create a erp_tech_svcs.rb file in your initializers and override the config options you want

    Rails.application.config.erp_tech_svcs.configure do |config|
      config.installation_domain = 'localhost:3000'
      config.login_url = '/erp_app/login'
      config.email_notifications_from = 'notifications@noreply.com'
      config.max_file_size_in_mb = 5
      config.file_assets_location = 'file_assets'
      config.file_storage = :filesystem
    end
    Rails.application.config.erp_tech_svcs.configure!

##Notes

We use [pdfkit](https://github.com/jdpace/PDFKit) and there is an initializer in erp\_tech\_svcs to set it up with some defaults.  You will need to create your
own initializer to overwrite this if you have wkhtmltopdf in another location

    # config/initializers/pdfkit.rb
    PDFKit.configure do |config|
      if RUBY_PLATFORM =~ /(:?mswin|mingw)/
        # set path to wkhtmltopdf on windows here
        config.wkhtmltopdf = '/opt/local/bin/wkhtmltopdf'
      else
        config.wkhtmltopdf = '/opt/local/bin/wkhtmltopdf'
      end

      config.default_options = {
        :page_size => 'Letter',
        :print_media_type => true,
        :disable_smart_shrinking => true,
        :dpi => 300,
        :no_background => true
    #    :use_xserver => true
      }
    end
