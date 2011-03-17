class ErpApp::Desktop::Knitkit::BaseController < ErpApp::Desktop::BaseController
  KNIT_KIT_ROOT = "#{RAILS_ROOT}/vendor/plugins/knitkit/"

  def websites
    websites = Website.find(:all)

    tree = []

    websites.each do |website|
      website_hash = {
        :text => website.title,
        :canAddSections => true,
        :iconCls => 'icon-globe',
        :id => "website_#{website.id}",
        :leaf => false,
        :url => "http://#{website.host}",
        :name => website.name,
        :host => website.host,
        :title => website.title,
        :subtitle => website.subtitle,
        :email => website.email,
        :siteName => website.title,
        :allowInquiries =>  website.allow_inquiries?,
        :emailInquiries =>  website.email_inquiries?,
        :children => []
      }
      
      #handle sections
      website.website_sections.each do |website_section|
        website_section_hash = {
          :text => website_section.title,
          :siteName => website.title,
          :siteId => website.id,
          :type => website_section.type,
          :isSecured => !website_section.roles.empty?,
          :isSection => true,
          :hasLayout => !website_section.layout.blank?,
          :id => "section_#{website_section.id}",
          :url => "http://#{website.host}/#{website_section.permalink}"
        }

        if website_section.is_a?(Blog)
          website_section_hash[:isBlog] = true
          website_section_hash[:iconCls] = 'icon-blog'
          website_section_hash[:leaf] = true
          website_section_hash[:canAddSections] = false
        else
          website_section_hash[:canAddSections] = false
          unless website_section.children.empty?
            website_section_hash[:leaf] = false
            website_section_hash[:children] = []
          else
            website_section_hash[:leaf] = true
            if website_section_hash[:isSecured]
              website_section_hash[:iconCls] = 'icon-document_lock'
            else
              website_section_hash[:iconCls] = 'icon-document'
            end
          end
        end

        
        website_hash[:children] << website_section_hash
      end
      tree << website_hash
    end

    render :json => tree.to_json
  end
end