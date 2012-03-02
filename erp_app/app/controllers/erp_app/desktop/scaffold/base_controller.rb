require 'rails/generators'
require 'fileutils'

module ErpApp
	module Desktop
		module Scaffold
			class BaseController < ErpApp::Desktop::BaseController

			  def create_model
          name = params[:name].underscore

          result = create_scaffold_check(name)
          if result[:success]
            Rails::Generators.invoke('active_ext', [name, 'desktop','scaffold'])
            load_files(name)
          end

          render :json => result
			  end

			  def get_active_ext_models
          render :json => find_active_ext_models.map{|model| {:text => model, :model => model.underscore, :iconCls => 'icon-grid', :leaf => true}}
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

          dirs = [Rails.root]
          dirs = dirs | Rails::Application::Railties.engines.map{|p| p.config.root.to_s}

          dirs.each do |dir|
            if File.exists? File.join(dir,"/app/controllers/erp_app/desktop/scaffold/")
              Dir.glob("#{dir}/app/controllers/erp_app/desktop/scaffold/*.rb") do |filename|
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
            end
          end
          
          model_names
			  end

			  def class_exists?(class_name)
          klass = Module.const_get(class_name)
          return klass.is_a?(Class) ? klass.superclass == ActiveRecord::Base : false
			  rescue NameError
          return false
			  end

			  def load_files(name)
          #reload routes file
          load "#{Rails.root}/config/routes.rb"

          #load controller
          controller = "ErpApp::Desktop::Scaffold::#{name.classify}Controller"
          controller.constantize unless class_exists?(controller)
			  end
			end
		end
	end
end