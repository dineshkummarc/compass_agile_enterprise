class DynamicForm < ActiveRecord::Base
  belongs_to :dynamic_form_model

  validates_uniqueness_of :internal_identifier, :scope => :model_name
  
  def self.class_exists?(class_name)
	result = nil
	begin
	  klass = Module.const_get(class_name)
      result = klass.is_a?(Class) ? ((klass.superclass == ActiveRecord::Base or klass.superclass == DynamicModel) ? true : nil) : nil
	rescue NameError
	  result = nil
	end
	result
  end
  
  def self.get_form(klass_name, internal_identifier='')
    result = nil
	if internal_identifier and internal_identifier != ''
	  result = DynamicForm.find_by_model_name_and_internal_identifier(klass_name, internal_identifier)
	else
	  result = DynamicForm.find_by_model_name_and_default(klass_name, true)
	end
	result
  end
  
  # parse JSON definition into a ruby object 
  # returns an array of hashes
  def definition_object
    o = JSON.parse(self.definition)
    o.map! do |i|
      i = i.symbolize_keys
    end
    
    o
  end
  
  def definition_with_validation
    def_object = add_validation(self.definition_object)
    definition_with_validation = post_json_strip_validator_quotes(def_object.to_json)
  end
  
  def add_validation(def_object)
    def_object.each do |item|      
      if item[:validator_function] and item[:validator_function] != ""
        item[:validator] = "function(v){ regex = this.initialConfig.validation_regex; return #{item[:validator_function]}; }"
      elsif item[:validation_regex]  and item[:validation_regex] != ""
        item[:validator] = "function(v){ return validate_regex(v, this.initialConfig.validation_regex); }"
      end
    end
    
    def_object
  end
  
  # we must convert the validator function value from a string to a function
  def post_json_strip_validator_quotes(json)
    # remove quotes from validator
    regex = Regexp.new('\"validator\":\"(.+)\(v\)\{(.+)\}\"')
    json = json.gsub(regex){ |match|
      r = Regexp.new(':\"')
      match.gsub!(r,':')
      r = Regexp.new('\"$')
      match.gsub!(r,'')
    }
    json
  end
  
  # check field against form definition to see if field still exists
  # returns true if field does not exist
  def deprecated_field?(field_name)
    result = true
	definition_object.each do |field|
      result = false if field[:name] == field_name.to_s
    end
    
    result
  end
  
  def self.concat_fields_to_build_definition(array_of_fields)
    array_of_fields.to_json
  end
  
  def to_extjs_formpanel(options={})    
    javascript = "{
              \"xtype\": \"form\",
              \"id\": \"dynamic_form_panel\",
              \"url\":\"#{options[:url]}\",
              \"title\": \"#{self.description}\","

    javascript += "\"width\": #{options[:width]}," if options[:width]

    javascript += "\"frame\": true,
              \"bodyStyle\":\"padding: 5px 5px 0;\",
              \"baseParams\": {"
                
    javascript += "  \"id\": #{options[:record_id]}," if options[:record_id]
              
    javascript += "  \"dynamic_form_id\": #{self.id},
                \"dynamic_form_model_id\": #{self.dynamic_form_model_id},
                \"model_name\": \"#{self.model_name}\"
              },
              \"items\": #{definition_with_validation},
              \"listeners\": {
                  \"afterrender\": function(form) {
                      Ext.getCmp('dynamic_form_panel').getComponent(0).focus(false);
                  }
              },
              \"buttons\": [{
                  \"text\": \"Submit\",
                  \"listeners\":{
                      \"click\":function(button){
                          var formPanel = Ext.getCmp('dynamic_form_panel');
                          formPanel.getForm().submit({
                              reset:true,
                              success:function(form, action){
                                  Ext.getCmp('dynamic_form_panel').findParentByType('window').close();
                                  if (Ext.getCmp('DynamicFormDataGridPanel')){
                                      Ext.getCmp('DynamicFormDataGridPanel').query('shared_dynamiceditablegrid')[0].store.load();                                                                      
                                  }
                              },
                              failure:function(form, action){
                                Ext.Msg.alert(action.response.responseText);                                
                              }
                          });
                      }
                  }
                  
              },{
                  \"text\": \"Cancel\",
                  \"listeners\":{
                      \"click\":function(button){
                          Ext.getCmp('dynamic_form_panel').findParentByType('window').close();
                      }
                  }
              }]
          }"
#      logger.info javascript
    javascript    
  end
  
  # convert form definition to ExtJS form
  # definition is essentially the formpanel items
  #
  # options hash:
  # :url => pass in URL for form to post to
  # :widget_result_id => 
  # :width =>
  def to_extjs_widget(options={})
    options[:width] = "'auto'" if options[:width].nil?

    #NOTE: The random nbsp; forces IE to eval this javascript!
    javascript = "&nbsp<script type=\"text/javascript\">
      Ext.onReady(function(){
          Ext.QuickTips.init();

          var dynamic_form = Ext.create('Ext.form.Panel',{
              id: 'dynamic_form_panel',
              url:'#{options[:url]}',
              title: '#{self.description}',"

    javascript += "\"width\": #{options[:width]}," if options[:width]

    javascript += "frame: true,
              bodyStyle:'padding: 5px 5px 0;',
              renderTo: 'dynamic_form_target',
              baseParams: {
                dynamic_form_id: #{self.id},
                dynamic_form_model_id: #{self.dynamic_form_model_id},
                model_name: '#{self.model_name}'
              },
              items: #{definition_with_validation},
              listeners: {
                  afterrender: function(form) {
                      Ext.getCmp('dynamic_form_panel').getComponent(0).focus(false);
                  }
              },
              buttons: [{
                  text: 'Submit',
                  listeners:{
                      'click':function(button){

                          var formPanel = Ext.getCmp('dynamic_form_panel');
                          formPanel.getForm().submit({
                              reset:true,
                              success:function(form, action){
                                  json_hash = Ext.decode(action.response.responseText);
                                  Ext.get('#{options[:widget_result_id]}').dom.innerHTML = json_hash.response;
                                  var scriptTags = Ext.get('#{options[:widget_result_id]}').dom.getElementsByTagName('script');
                                  Ext.each(scriptTags, function(scriptTag){
                                        eval(scriptTag.text);
                                  });
                              },
                              failure:function(form, action){
                                if (action.response){
                                  json_hash = Ext.decode(action.response.responseText);
                                  Ext.get('#{options[:widget_result_id]}').dom.innerHTML = json_hash.response;
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
      #logger.info javascript
    javascript
  end
  
end