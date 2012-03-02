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
