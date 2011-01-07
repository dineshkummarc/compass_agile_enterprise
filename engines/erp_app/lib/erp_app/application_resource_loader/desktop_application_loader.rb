# To change this template, choose Tools | Templates
# and open the template in the editor.

class ErpApp::ApplicationResourceLoader::DesktopApplicationLoader < ErpApp::ApplicationResourceLoader::FileSystemLoader
  def initialize(application)
    @javascripts_folder = '/vendor/plugins/erp_app/public/javascripts/erp_app/desktop/applications'
    @stylesheets_folder = '/vendor/plugins/erp_app/public/stylesheets/erp_app/desktop/applications'
    super(application)
  end
end
