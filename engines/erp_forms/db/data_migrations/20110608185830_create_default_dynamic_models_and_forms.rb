class CreateDefaultDynamicModelsAndForms
  
  def self.up
    #insert data here
    DynamicFormModel.create(:model_name => 'DynamicFormDocument')

    fields = []

    fields << DynamicFormField.textfield({:fieldLabel => 'First Name', :name => 'first_name', :width => '200' })
    fields << DynamicFormField.textfield({:fieldLabel => 'Last Name', :name => 'last_name', :width => '200' })
    fields << DynamicFormField.email({:fieldLabel => 'Email', :name => 'email', :width => '200' })
    fields << DynamicFormField.textarea({:fieldLabel => 'Message', :name => 'message', :width => '200' })    
    
    d = DynamicForm.new
    d.description = 'Contact Form'
    d.definition = fields.to_json
    d.model_name = 'WebsiteInquiry'
    d.internal_identifier = 'contact_us'
    d.default = true
    d.dynamic_form_model = DynamicFormModel.create(:model_name => 'WebsiteInquiry')
    d.save
  end
  
  def self.down
    #remove data here
    DynamicFormModel.delete_all
    DynamicForm.delete_all
  end

end
