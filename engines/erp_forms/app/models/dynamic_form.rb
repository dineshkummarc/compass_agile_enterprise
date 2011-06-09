class DynamicForm < ActiveRecord::Base
  belongs_to :dynamic_form_model

  validates_uniqueness_of :internal_identifier, :scope => :model_name

  #get all file in root app/models, first level plugins app/models & extensions
  def self.models_with_dynamic_forms
    model_names = []
    base_models = Dir.glob("#{RAILS_ROOT}/app/models/*.rb")
    plugin_models = Dir.glob("#{RAILS_ROOT}/vendor/plugins/*/app/models/*.rb")
    extensions = Dir.glob("#{RAILS_ROOT}/vendor/plugins/*/app/models/extensions/*.rb")
    widget_models = Dir.glob("#{RAILS_ROOT}/vendor/plugins/*/lib/erp_app/widgets/*/models/*.rb")
    files = base_models + plugin_models + extensions + widget_models
    
    files.each do |filename|
      next if filename =~ /#{['svn','git'].join("|")}/
      open(filename) do |file|
        if file.grep(/has_dynamic_forms/).any?
          model = File.basename(filename).gsub(".rb", "").camelize
          if DynamicForm.class_exists?(model)
            model_names << model
          end
        end
      end
    end
    
    model_names.delete('DynamicForm')
    model_names.delete('DynamicFormDocument')

    model_names
  end
  
  def self.class_exists?(class_name)
    klass = Module.const_get(class_name)
    if klass.is_a?(Class)
      if klass.superclass == ActiveRecord::Base or klass.superclass == DynamicModel
        return true
      else
        return false
      end
    else
      return false
    end
  rescue NameError
    return false
  end
  
  def self.get_form(klass_name, internal_identifier='')
    if internal_identifier and internal_identifier != ''
	    return DynamicForm.find_by_model_name_and_internal_identifier(klass_name, internal_identifier)
	  else
	    return DynamicForm.find_by_model_name_and_default(klass_name, true)
	  end
  end
  
  # check field against form definition to see if field still exists
  def deprecated_field?(field_name)
    
  end
  
  def self.concat_fields_to_build_definition(array_of_fields)
    '[' + array_of_fields.join(',') + ']'
  end
  
  # convert form definition to ExtJS form
  # definition is essentially the formpanel items
  #
  # options hash:
  # :url => pass in URL for form to post to
  # :widget_result_id => 
  # :width =>
  def to_extjs(options={})
    options[:width] = "'auto'" if options[:width].nil?

    javascript = "<script type=\"text/javascript\">
      Ext.onReady(function(){
          Ext.QuickTips.init();

          var dynamic_form = new Ext.FormPanel({
              id: 'dynamic_form_panel',
              url:'#{options[:url]}',
              title: '#{self.description}',
              width: #{options[:width]},
              frame: true,
              bodyStyle:'padding: 5px 5px 0',
              renderTo: 'dynamic_form_target',
              baseParams: {
                dynamic_form_id: #{self.id},
                dynamic_form_model_id: #{self.dynamic_form_model_id},
                model_name: '#{self.model_name}'
              },
              items: #{self.definition},

              buttons: [{
                  text: 'Submit',
                  listeners:{
                      'click':function(button){

                          var formPanel = Ext.getCmp('dynamic_form_panel');
                          formPanel.getForm().submit({
                              reset:true,
                              success:function(form, action){
                                  var obj =  Ext.util.JSON.decode(action.response.responseText);
                                  if(obj.success){
                                    Ext.get('#{options[:widget_result_id]}').dom.innerHTML = action.response.responseText;
                                    var scriptTags = Ext.get('#{options[:widget_result_id]}').dom.getElementsByTagName('script');
                                    Ext.each(scriptTags, function(scriptTag){
                                         eval(scriptTag.text);
                                    });
                                    
                                  }else{
                                      Ext.Msg.alert('Error', obj.msg);
                                  }
                              },
                              failure:function(form, action){
                                if (!Compass.ErpApp.Utility.isBlank(action.response)){
                                  var obj =  Ext.util.JSON.decode(response.responseText);
                                  Ext.Msg.alert('Error', obj.msg);                                  
                                }
                              }
                          });
                      }
                  }
                  
              },{
                  text: 'Cancel'
              }]
          });        
      });        

       </script>"
      puts javascript
    javascript
  end
  
end