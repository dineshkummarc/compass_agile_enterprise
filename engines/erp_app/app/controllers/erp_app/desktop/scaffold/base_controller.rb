class ErpApp::Desktop::Scaffold::BaseController < ErpApp::Desktop::BaseController

  def get_active_ext_models
    models = find_active_ext_models

    result = []

    models.each do |model|
      result << {:text => model, :id => model.downcase, :iconCls => 'icon-grid', :leaf => true}
    end

    render :inline => result.to_json
  end

  private

  #get all file in root app/controllers and first level plugins app/controllers
  def find_active_ext_models
    model_names = []

    (Dir.glob("#{RAILS_ROOT}/vendor/plugins/*/app/controllers/**/*.rb") | Dir.glob("#{RAILS_ROOT}/app/controllers/**/*.rb")).each do |filename|
      next if filename =~ /#{['svn', 'CVS', 'bzr'].join("|")}/
      open(filename) do |file|
        if file.grep(/active_ext/).any?
          model = File.basename(filename).split("_").first.classify
          if model_exists?(model)
            model_names << model
          end
        end
      end
    end

    model_names
  end

  def model_exists?(class_name)
    klass = Module.const_get(class_name)
    if klass.is_a?(Class)
      return klass.superclass == ActiveRecord::Base
    else
      return false
    end
  rescue NameError
    return false
  end
end