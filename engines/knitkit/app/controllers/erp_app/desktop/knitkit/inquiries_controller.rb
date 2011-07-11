class ErpApp::Desktop::Knitkit::InquiriesController < ErpApp::Desktop::Knitkit::BaseController

  def setup
    form = DynamicForm.get_form('WebsiteInquiry')    
    definition = form.definition_object
    
    columns = []
    definition.each do |field_hash|
      field_hash['width'] = 120
      columns << DynamicGridColumn.build_column(field_hash)
    end
    
    columns << DynamicGridColumn.build_column({ :fieldLabel => "Username", :name => 'username', :xtype => 'textfield' })
    columns << DynamicGridColumn.build_column({ :fieldLabel => "Created At", :name => 'created_at', :xtype => 'datefield', :width => 75 })
    columns << DynamicGridColumn.build_view_column("Ext.getCmp('knitkitCenterRegion').showComment(rec.get('message'));")
    columns << DynamicGridColumn.build_delete_column("Ext.getCmp('InquiriesGridPanel').deleteInquiry(rec);")
    
    definition << JSON(DynamicFormField.textfield({ :fieldLabel => "Username", :name => 'username' }))
    definition << JSON(DynamicFormField.datefield({ :fieldLabel => "Created At", :name => 'created_at' }))
    definition << JSON(DynamicFormField.hidden({ :fieldLabel => "ID", :name => 'id' }))
    
    result = "{
      \"success\": true,
      \"columns\": [#{columns.join(',')}],
      \"fields\": #{definition.to_json}
    }"    
    
    render :inline => result
  end

  def get
    WebsiteInquiry.include_root_in_json = false

    website = Website.find(params[:website_id])

    sort  = params[:sort] || 'created_at'
    dir   = params[:dir] || 'DESC'

    WebsiteInquiry.class_eval do
      def username
        data.created_by.nil? ? '' : data.created_by.login
      end
    end

    website_inquiries = website.website_inquiries.paginate(:page => page, :per_page => per_page, :order => "#{sort} #{dir}")

    wi = []
    website_inquiries.each do |i|
      wihash = i.data.dynamic_attributes_without_prefix
#      puts i.data.created_by.inspect
      wihash['id'] = i.id
      wihash['username'] = i.username
      wihash['created_at'] = i.data.created_at
      wi << wihash
    end
    
    render :inline => "{ totalCount:#{website_inquiries.total_entries}, data:#{wi.to_json} }"
  end

  def delete
    website_inquiry = WebsiteInquiry.find(params[:id])
    website_inquiry.destroy
    render :inline => {:success => true}.to_json
  end
end
