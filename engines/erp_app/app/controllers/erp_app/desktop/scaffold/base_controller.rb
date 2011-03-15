require 'rails_generator/spec'
require 'rails_generator/base'
require 'rails_generator/commands'
require 'rails_generator/simple_logger'
require 'generators/active_ext/active_ext_generator'
require 'fileutils'

class ErpApp::Desktop::Scaffold::BaseController < ErpApp::Desktop::BaseController

  ERP_APP_PATH = "#{RAILS_ROOT}/vendor/plugins/erp_app/"

  def create_model
    name = params[:name].underscore

    result = create_scaffold_check(name)
    if result[:success]
      spec = Rails::Generator::Spec.new('active_ext', "#{RAILS_ROOT}/vendor/plugins/erp_app/lib/generators/active_ext", 'controller')
      generator = ActiveExtGenerator.new [name, 'desktop','scaffold'], {:spec => spec, :logger => Rails::Generator::SimpleLogger.new}
      Rails::Generator::Commands.instance('create', generator).invoke!
      load_files(name)
    end

    render :inline => result.to_json
  end

  def get_active_ext_models
    models = find_active_ext_models

    result = []

    models.each do |model|
      result << {:text => model, :id => model.underscore, :iconCls => 'icon-grid', :leaf => true}
    end

    render :inline => result.to_json
  end

  private

  def create_scaffold_check(name)
    result = {:success => true}

    klass_name = name.classify
    model_names = find_active_ext_models
    unless model_names.include?(klass_name)
      unless class_exists?(klass_name)
        result[:success] = false
        result[:msg] = "Model does not exists"
      end
    else
      result[:success] = false
      result[:msg] = "Scaffold already exists"
    end

    return result
  end

  #get all file in root app/controllers and first level plugins app/controllers
  def find_active_ext_models
    model_names = []

    Dir.glob("#{RAILS_ROOT}/vendor/plugins/erp_app/app/controllers/erp_app/desktop/scaffold/*.rb") do |filename|
      next if filename =~ /#{['svn','git'].join("|")}/
      open(filename) do |file|
        if file.grep(/active_ext/).any?
          model = File.basename(filename).gsub("_controller.rb", "").classify
          if class_exists?(model)
            model_names << model
          end
        end
      end
    end

    model_names
  end

  def class_exists?(class_name)
    klass = Module.const_get(class_name)
    if klass.is_a?(Class)
      return klass.superclass == ActiveRecord::Base
    else
      return false
    end
  rescue NameError
    return false
  end

  def load_files(name)
    #reload routes file
    load "#{ERP_APP_PATH}/config/routes.rb"

    #load controller
    controller = "ErpApp::Desktop::Scaffold::#{name.classify}Controller"
    controller.constantize unless class_exists?(controller)
    
    #make directory if it does not exists
    FileUtils.mkdir_p "#{RAILS_ROOT}/public/javascripts/erp_app/desktop/applications/scaffold/" unless File.directory?("#{RAILS_ROOT}/public/javascripts/erp_app/desktop/applications/scaffold/")
    #copy generated fild up to base public directory
    FileUtils.cp_r "#{ERP_APP_PATH}/public/javascripts/erp_app/desktop/applications/scaffold/#{name.underscore}_active_ext.js", "#{RAILS_ROOT}/public/javascripts/erp_app/desktop/applications/scaffold/"
  end
end