class CreateDefaultDynamicModelsAndForms
  
  def self.up
    #insert data here
    DynamicFormModel.create(:model_name => 'DynamicFormDocument')
    DynamicFormModel.create(:model_name => 'WebsiteInquiry')

    fields = []

    fields << DynamicFormField.textfield({:fieldLabel => 'First Name', :name => 'first_name', :width => '200' })
    fields << DynamicFormField.textfield({:fieldLabel => 'Last Name', :name => 'last_name', :width => '200' })
    fields << DynamicFormField.email({:fieldLabel => 'Email', :name => 'email', :width => '200' })
    fields << DynamicFormField.textarea({:fieldLabel => 'Message', :name => 'message', :width => '200' })    
    
    definition = DynamicForm.concat_fields_to_build_definition(fields)
    
    d = DynamicForm.new
    d.description = 'Contact Form'
    d.definition = definition
    d.model_name = 'WebsiteInquiry'
    d.internal_identifier = 'contact_us'
    d.default = true
    d.dynamic_form_model_id = DynamicFormModel.find_by_model_name('WebsiteInquiry')
    d.save
  end
  
  def self.down
    #remove data here
    DynamicFormModel.delete_all
    DynamicForm.delete_all
  end

end
