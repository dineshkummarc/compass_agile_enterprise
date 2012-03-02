class UpdateContactForm
  
  def self.up
    fields = []

    fields << DynamicFormField.textfield({:fieldLabel => 'First Name', :name => 'first_name', :width => 250, :allowblank => false })
    fields << DynamicFormField.textfield({:fieldLabel => 'Last Name', :name => 'last_name', :width => 250, :allowblank => false })
    fields << DynamicFormField.email({:fieldLabel => 'Email', :name => 'email', :width => 250, :allowblank => false })
    fields << DynamicFormField.textarea({:fieldLabel => 'Message', :name => 'message', :width => 400, :height => 200, :allowblank => false })    
    
    d = DynamicForm.find_by_internal_identifier('contact_us')
    unless d.nil?
      puts "updating form"
      d.definition = fields.to_json
      d.save    
    end    
  end
  
  def self.down
    # do nothing
  end

end
