class ErpForms::ErpApp::Desktop::DynamicForms::DataController < ErpForms::ErpApp::Desktop::DynamicForms::BaseController

    # setup dynamic data grid
    def setup
      form = DynamicForm.get_form(params[:model_name])    
      definition = form.definition_object

      columns = []
      definition.each do |field_hash|
        field_hash[:width] = 120
        columns << DynamicGridColumn.build_column(field_hash)
      end

      columns << DynamicGridColumn.build_column({ :fieldLabel => "Updated By", :name => 'updated_username', :xtype => 'textfield' })
      columns << DynamicGridColumn.build_column({ :fieldLabel => "Created By", :name => 'created_username', :xtype => 'textfield' })
      columns << DynamicGridColumn.build_column({ :fieldLabel => "Created At", :name => 'created_at', :xtype => 'datefield', :width => 75 })
      columns << DynamicGridColumn.build_column({ :fieldLabel => "Updated At", :name => 'updated_at', :xtype => 'datefield', :width => 75 })
      columns << DynamicGridColumn.build_edit_column("Ext.getCmp('DynamicFormDataGridPanel').editRecord(rec,'#{params[:model_name]}');")
      columns << DynamicGridColumn.build_delete_column("Ext.getCmp('DynamicFormDataGridPanel').deleteRecord(rec,'#{params[:model_name]}');")

      definition << DynamicFormField.textfield({ :fieldLabel => "Updated By", :name => 'updated_username' })
      definition << DynamicFormField.textfield({ :fieldLabel => "Created By", :name => 'created_username' })
      definition << DynamicFormField.datefield({ :fieldLabel => "Created At", :name => 'created_at' })
      definition << DynamicFormField.datefield({ :fieldLabel => "Updated At", :name => 'updated_at' })
      definition << DynamicFormField.hidden({ :fieldLabel => "ID", :name => 'id' })

      result = "{
        \"success\": true,
        \"columns\": [#{columns.join(',')}],
        \"fields\": #{definition.to_json}
      }"    

      render :inline => result
    end

    # get dynamic data records
    def index
      sort  = params[:sort] || 'created_at'
      dir   = params[:dir] || 'DESC'

      myDynamicObject = DynamicFormModel.get_constant(params[:model_name])
      
      dynamic_records = myDynamicObject.paginate(:page => page, :per_page => per_page, :order => "#{sort} #{dir}")

      wi = []
      dynamic_records.each do |i|
        wihash = i.data.dynamic_attributes_without_prefix
  #      puts i.data.created_by.inspect
        wihash[:id] = i.id
        wihash[:created_username] = i.data.created_by.nil? ? '' : i.data.created_by.username
        wihash[:updated_username] = i.data.updated_by.nil? ? '' : i.data.updated_by.username
        wihash[:created_at] = i.data.created_at
        wihash[:updated_at] = i.data.updated_at
        wi << wihash
      end

      render :inline => "{ totalCount:#{dynamic_records.total_entries}, data:#{wi.to_json} }"
    end

    # create a dynamic data record
    def create
      @myDynamicObject = DynamicFormModel.get_instance(params[:model_name])
      puts current_user.inspect
      params[:created_by] = current_user unless current_user.nil?
      params[:created_with_form_id] = params[:dynamic_form_id] if params[:dynamic_form_id]
      @myDynamicObject = DynamicFormModel.save_all_attributes(@myDynamicObject, params, ErpForms::ErpApp::Desktop::DynamicForms::BaseController::IGNORED_PARAMS)
      
      if @myDynamicObject
        render :inline => {:success => true}.to_json
      else
        render :inline => {:success => false}.to_json        
      end      
    end

    # update a dynamic data record
    def update
      @myDynamicObject = DynamicFormModel.get_constant(params[:model_name]).find(params[:id])

      params[:updated_by] = current_user unless current_user.nil?
      params[:updated_with_form_id] = params[:dynamic_form_id] if params[:dynamic_form_id]      
      @myDynamicObject = DynamicFormModel.save_all_attributes(@myDynamicObject, params, ErpForms::ErpApp::Desktop::DynamicForms::BaseController::IGNORED_PARAMS)
            
      if @myDynamicObject
        render :inline => {:success => true}.to_json
      else
        render :inline => {:success => false}.to_json        
      end      
    end

    # delete a dynamic data record
    def delete
      @myDynamicObject = DynamicFormModel.get_constant(params[:model_name])
      @myDynamicObject.destroy(params[:id])
      render :inline => {:success => true}.to_json
    end
      
end
