class ErpApp::Desktop::DynamicForms::FormsController < ErpApp::Desktop::DynamicForms::BaseController
  
  # get tree of dynamic models and forms
  def get_tree
    if params[:node] == "root"    
      models = DynamicFormModel.all(:order => :model_name)
    else
      id = params[:node].gsub("form_model_", '').to_i
      models = DynamicFormModel.find_all_by_id(id)
    end
    
    tree = []

    models.each do |form_model|
      # DynamicFormDocument only exists for the purpose of Extending
      next if form_model.model_name == 'DynamicFormDocument'
      
      model_hash = {
        :text => form_model.model_name,
        :iconCls => 'icon-data',
        :id => "form_model_#{form_model.id}",
        :modelId => form_model.id,
        :isModel => true, 
        :isForm => false, 
        :leaf => false,
        :children => []
      }

      #handle sections
      form_model.dynamic_forms.each do |form|
        form_hash = {
          :text => form.description, 
          :iconCls => (form.default ? 'icon-document_ok' : 'icon-document'), 
          :id => "form_#{form.id}",
          :formId => form.id, 
          :isModel => false, 
          :isDefault => form.default,
          :modelName => form_model.model_name,
          :isForm => true, 
          :leaf => true 
        }

        model_hash[:children] << form_hash
      end
            
      #added website to main tree
      tree << model_hash
    end

    render :json => tree.to_json
  end

  # get a single form definition
  def get_definition
    form = DynamicForm.get_form(params[:model_name], params[:internal_identifier])

    render :json => form.definition
  end

  # get a single form
  def get    
    form = DynamicForm.get_form(params[:model_name], params[:internal_identifier]).to_extjs_formpanel(
                { :url => "/erp_app/desktop/dynamic_forms/data/#{params[:form_action]}",
                  :record_id => params[:id]
                })

    render :inline => form
  end

  # delete dynamic form
  def delete
    
  end

  # update dynamic form
  def update
    
  end
  
  # create dynamic form
  def create
    
  end
  
end
