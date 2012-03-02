require 'rubygems'

module Bundler
  class RubygemsIntegration
    def replace_entrypoints(specs)
      ErpTechSvcs::ApplicationInstaller.compass_gem_specs.each do |spec|
        specs << spec
      end rescue nil
      reverse_rubygems_kernel_mixin

      replace_gem(specs)

      stub_rubygems(specs)

      replace_bin_path(specs)
      replace_refresh

      Gem.clear_paths
    end
  end
end

module Bundler
  def self.setup(reload=false, *groups)
    # Just return if all groups are already loaded
    return @setup if (defined?(@setup) && !reload)

    if groups.empty?
      # Load all groups, but only once
      @setup = load(reload).setup
    else
      @completed_groups ||= []
      # Figure out which groups haven't been loaded yet
      unloaded = groups - @completed_groups
      # Record groups that are now loaded
      @completed_groups = groups
      unloaded.any? ? load(reload).setup(*groups) : load
    end
  end

  def self.load(reload=false)
    reload ? (@load = Runtime.new(root, definition(true))) : (@load ||= Runtime.new(root, definition))
  end
end

module ErpTechSvcs
  class ApplicationInstaller
    class << self

      cattr_accessor :compass_gem_specs

      def setup_compass_applications
       # Bundler.rubygems.gem_path.push File.join(Rails.root, "vendor/compass_applications")
      end

      def install_application(application_name)
        unless application_installed?(application_name)
          ErpTechSvcs::ApplicationInstaller.compass_gem_specs = ErpTechSvcs::ApplicationInstaller.compass_gem_specs.nil? ? [] : ErpTechSvcs::ApplicationInstaller.compass_gem_specs

          #install_gem(application_name)
          #ErpTechSvcs::FileManipulator.append_file('Gemfile',"gem '#{application_name}'")
          #spec = Bundler.rubygems.spec_from_gem(File.join(Rails.root,'vendor','compass_applications','tenancy','tenancy-0.0.1.gem'))
          #ErpTechSvcs::ApplicationInstaller.compass_gem_specs << spec
          Bundler.setup true
          #Bundler.require :default
          #require "tenancy"
        end
      end

      def include_application(application)
        path = File.join(Rails.root, "vendor/compass_applications", application[:description], 'lib', "#{application[:name]}.rb")
        puts path
        require path
      end

      def application_installed?(application_name)
        installed_engines = Rails::Application::Railties.engines.collect{|e| e.railtie_name.camelize}
        installed_engines.include?(application_name.camelize)
      end

      def install_gem(application_name)
        out, _ = sh_with_code("gem install '#{application_name}'")
        puts out
        raise "Couldn't install gem, run `gem install #{application_name}' for more detailed output" unless out[/Successfully installed/]
      end

      def sh_with_code(cmd, &block)
        cmd << " 2>&1"
        outbuf = ''
        puts (Rails.root)
        Dir.chdir(Rails.root) {
          outbuf = `#{cmd}`
          if $? == 0
            block.call(outbuf) if block
          end
        }
        [outbuf, $?]
      end

    end
  end
end