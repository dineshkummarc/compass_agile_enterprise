class ErpApp::Desktop::Knitkit::InquiriesController < ErpApp::Desktop::Knitkit::BaseController
  def get
    WebsiteInquiry.include_root_in_json = false

    website = Website.find(params[:website_id])

    sort  = params[:sort] || 'created_at'
    dir   = params[:dir] || 'DESC'
    limit = params[:limit] || 10
    start = params[:start] || 0

    WebsiteInquiry.class_eval do
      def username
        user.nil? ? '' : user.login
      end
    end

    website_inquiries = website.website_inquiries.find(:all, :order => "#{sort} #{dir}", :limit => limit, :offset => start)

    wi = []
    website_inquiries.each do |i|
      wihash = i.data.dynamic_attributes_without_prefix
#      puts i.data.created_by.inspect
      wihash['id'] = i.id
      wihash['username'] = i.data.created_by.login
      wihash['created_at'] = i.data.created_at
      wi << wihash
    end
    
    render :inline => "{totalCount:#{website.website_inquiries.count}, inquiries:#{wi.to_json(:methods => [:username])}}"
  end

  def delete
    website_inquiry = WebsiteInquiry.find(params[:id])
    website_inquiry.destroy
    render :inline => {:success => true}.to_json
  end
end
