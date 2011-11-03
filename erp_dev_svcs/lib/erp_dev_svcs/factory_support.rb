module ErpDevSvcs
  module FactorySupport

    def self.load_engine_factories
      Rails::Application::Railties.engines.map{|p| p.config.root.to_s}.each do |engine_dir|
        Dir.glob(File.join(engine_dir,'spec','factories','*')) {|file| require file} if File.directory? File.join(engine_dir,'spec','factories')
      end
    end

  end#FactorySupport
end#ErpDevSvcs
