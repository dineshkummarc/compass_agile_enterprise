class ExtExtensionGenerator < Rails::Generator::NamedBase
  def initialize(runtime_args, runtime_options = {})
    super
    unless runtime_args[1].nil?
      raise "Must Include Directory To Which You Want The File Arg[1]" if runtime_args[1].blank?
      raise "Must Include Javascript Class Name Arg[2]" if runtime_args[2].blank?
      raise "Must Include Ext Class You Are Extending Arg[3]" if runtime_args[3].blank?
      @file_dir = runtime_args[1]
      @javascript_class_name = runtime_args[2]
      @ext_extension_class = runtime_args[3]
    end
  end

  def manifest
    record do |m|

      #Route
      m.template "public/extension_template.js.erb", "#{@file_dir}#{file_name}.js"

      #Readme
      m.readme "INSTALL"
    end
  end

  def javascript_class_name
    @javascript_class_name
  end

  def ext_extension_class
    @ext_extension_class
  end
end
