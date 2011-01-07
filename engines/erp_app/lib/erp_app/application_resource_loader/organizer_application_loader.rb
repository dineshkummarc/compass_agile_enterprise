# To change this template, choose Tools | Templates
# and open the template in the editor.

class ErpApp::ApplicationResourceLoader::OrganizerApplicationLoader < ErpApp::ApplicationResourceLoader::FileSystemLoader
  def initialize(application)
    @javascripts_folder = '/vendor/plugins/erp_app/public/javascripts/erp_app/organizer/applications'
    @stylesheets_folder = '/vendor/plugins/erp_app/public/stylesheets/erp_app/organizer/applications'
    super(application)
  end
end
