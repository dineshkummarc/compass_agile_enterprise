Compass AE Starter Kit
======================

Want to get started using the Compass AE framework but think its too complicated, well below are 4 easy steps to get you started.

##prerequisites

* [Rails]       -- (~> 3.1.1)
* [bundler]     --  (1.0.21 ruby)
* [wkhtmltopdf] --  (used by pdfkit https://github.com/jdpace/PDFKit)
* [ImageMagick] --  (used by quick_magick http://quickmagick.rubyforge.org/quick_magick/)
* [Solr]        --  (used by sunspot http://outoftime.github.com/sunspot/ only needed if erp_search module is installed)


##Installation (Gems Only)

When the compass_ae gem is installed you will get a command line utility

    compass_ae new my_compass_ae_app
    
this will create a new rails application setup to run our Compass AE engines.

### Development

If you want the source from our GIT repositories and not just the gems you can use this command

    compass_ae dev my_dev_compass_ae_app

This will clone our GIT repositories and point your Gemfile.rb to them