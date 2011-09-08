module Knitkit
  module ErpApp
    module Desktop
class InquiriesController < Knitkit::ErpApp::Desktop::AppController

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
    
    definition << DynamicFormField.textfield({ :fieldLabel => "Username", :name => 'username' })
    definition << DynamicFormField.datefield({ :fieldLabel => "Created At", :name => 'created_at' })
    definition << DynamicFormField.hidden({ :fieldLabel => "ID", :name => 'id' })
    
    result = "{
      \"success\": true,
      \"model\": \"WebsiteInquiry\",
      \"validations\": \"[]\",
      \"columns\": [#{columns.join(',')}],
      \"fields\": #{definition.to_json}
    }"    
    
    render :inline => result
  end

  def get
    WebsiteInquiry.include_root_in_json = false

    website = Website.find(params[:website_id])
    sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
    sort = sort_hash[:property] || 'created_at'
    dir  = sort_hash[:direction] || 'DESC'

    website_inquiries = website.website_inquiries.paginate(:page => page, :per_page => per_page, :order => "#{sort} #{dir}")

    wi = []
    website_inquiries.each do |i|
      wihash = i.data.dynamic_attributes_without_prefix

      wihash[:id] = i.id
      wihash[:username] = i.data.created_by.nil? ? '' : i.data.created_by.username
      wihash[:created_at] = i.data.created_at
      wi << wihash
    end
    
    render :inline => "{ total:#{website_inquiries.total_entries}, data:#{wi.to_json} }"
  end

  def delete
    website_inquiry = WebsiteInquiry.find(params[:id])
    website_inquiry.destroy
    render :json => {:success => true}
  end
end
end
end
end
