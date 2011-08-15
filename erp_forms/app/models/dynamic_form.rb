class DynamicForm < ActiveRecord::Base
  belongs_to :dynamic_form_model

  validates_uniqueness_of :internal_identifier, :scope => :model_name
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
  
  # parse JSON definition into a ruby object 
  # returns an array of hashes
  def definition_object
    d = self.definition

    # remove preceding comma
    validateOnBlur = '"validateOnBlur": true,'
    d = d.gsub(validateOnBlur,'"validateOnBlur": true')         

    # remove validator, not JSON compliant
    validator = '\"validator\": function\(v\)\{(.+)\}\},'   
    regex = Regexp.new(validator, Regexp::MULTILINE)
    d = d.gsub(regex,'},')         
    
    JSON.parse(d)
  end
  
  # check field against form definition to see if field still exists
  # returns true if field does not exist
  def deprecated_field?(field_name)
    definition_object.each do |field|
      return false if field['name'] == field_name.to_s
    end
    
    return true
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

    #NOTE: The random nbsp; forces IE to eval this javascript!
    javascript = "&nbsp<script type=\"text/javascript\">
      Ext.onReady(function(){
          Ext.QuickTips.init();

          var dynamic_form = Ext.create('Ext.form.Panel',{
              id: 'dynamic_form_panel',
              url:'#{options[:url]}',
              title: '#{self.description}',
              width: #{options[:width]},
              frame: true,
              bodyStyle:'padding: 5px 5px 0;',
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
                                  Ext.get('#{options[:widget_result_id]}').dom.innerHTML = action.response.responseText;
                                  var scriptTags = Ext.get('#{options[:widget_result_id]}').dom.getElementsByTagName('script');
                                  Ext.each(scriptTags, function(scriptTag){
                                        eval(scriptTag.text);
                                  });
                              },
                              failure:function(form, action){
                                Ext.get('#{options[:widget_result_id]}').dom.innerHTML = action.response.responseText;
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
      #puts javascript
    javascript
  end
  
end