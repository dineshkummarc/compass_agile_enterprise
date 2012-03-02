class ErpForms::ErpApp::Desktop::DynamicForms::ModelsController < ErpForms::ErpApp::Desktop::DynamicForms::BaseController
  
  # get dynamic form models
  # used in dynamic forms widget combo box
  def index
    models = []
    dynamic_form_models = DynamicFormModel.where("model_name != 'DynamicFormDocument'").order('model_name ASC')
    dynamic_form_models.each do |m|
      model_hash = {
        :id => m.id,
        :model_name => m.model_name,      
      }
      
      models << model_hash
    end
    
    render :json => models
  end

  # set default form for this model
  def set_default_form
    myDynamicObject = DynamicFormModel.get_constant(params[:model_name])    
    myDynamicObject.set_default(params[:id])
	
    render :json => {success => true}
  end

  # delete a dynamic form model
  def delete
    DynamicFormModel.destroy(params[:id])
	
    render :json => {:success => true}
  end
  
  # create a dynamic form model
  def create
    model_name = params[:model_name]
    DynamicFormModel.create({
      :model_name => model_name
    })
	
    render :json => {:success => true}
  end
  
end
