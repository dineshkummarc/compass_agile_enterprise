class MobileApplication < Application
  def locate_resources(resource_type)
    resource_loader = ErpApp::ApplicationResourceLoader::MobileLoader.new(self)
    resource_loader.locate_resources(resource_type)
  end
end
