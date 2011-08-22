class UpdateContactFormValidation
  
  def self.up
    fields = []

    fields << DynamicFormField.textfield({:fieldLabel => 'First Name', :name => 'first_name', :width => '200' })
    fields << DynamicFormField.textfield({:fieldLabel => 'Last Name', :name => 'last_name', :width => '200' })
    fields << DynamicFormField.email({:fieldLabel => 'Email', :name => 'email', :width => '200' })
    fields << DynamicFormField.textarea({:fieldLabel => 'Message', :name => 'message', :width => '200' })    
    
    definition = DynamicForm.concat_fields_to_build_definition(fields)
    
    d = DynamicForm.find_by_internal_identifier('contact_us')
    unless d.nil?
      d.definition = definition
      d.save    
    end    
  end
  
  def self.down
    # do nothing
  end

end
