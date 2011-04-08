class ErpApp::Desktop::Knitkit::BaseController < ErpApp::Desktop::BaseController
  KNIT_KIT_ROOT = "#{RAILS_ROOT}/vendor/plugins/knitkit/"

  def websites
    websites = Website.find(:all)

    tree = []

    websites.each do |website|
      website_hash = {
        :text => website.title,
        :iconCls => 'icon-globe',
        :id => "website_#{website.id}",
        :leaf => false,
        :url => "http://#{website.hosts.first}",
        :name => website.name,
        :title => website.title,
        :subtitle => website.subtitle,
        :isWebsite => true,
        :email => website.email,
        :siteName => website.title,
        :allowInquiries =>  website.allow_inquiries?,
        :emailInquiries =>  website.email_inquiries?,
        :children => []
      }

      #handle hosts
      hosts_hash = {:text => 'Hosts', :iconCls => 'icon-gear', :isHostRoot => true, :websiteId => website.id, :leaf => false, :children => []}
      website.hosts.each do |website_host|
        hosts_hash[:children] << {:text => website_host.host, :id => website_host.id, :host => website_host.host, :iconCls => 'icon-globe', :url => "http://#{website_host.host}", :isHost => true, :leaf => true, :children => []}
      end

      website_hash[:children] << hosts_hash

      #handle sections
      sections_hash = {:text => 'Sections', :isSectionRoot => true, :websiteId => website.id, :iconCls => 'icon-content', :leaf => false, :children => []}
      website.website_sections.each do |website_section|
        website_section_hash = {
          :text => website_section.title,
          :siteName => website.title,
          :siteId => website.id,
          :type => website_section.type,
          :isSecured => !website_section.roles.empty?,
          :isSection => true,
          :inMenu => website_section.in_menu,
          :hasLayout => !website_section.layout.blank?,
          :id => "section_#{website_section.id}",
          :url => "http://#{website.hosts.first}/#{website_section.permalink}"
        }

        if website_section.is_a?(Blog)
          website_section_hash[:isBlog] = true
          website_section_hash[:iconCls] = 'icon-blog'
          website_section_hash[:leaf] = true
        else
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

        
        sections_hash[:children] << website_section_hash
      end
      
      website_hash[:children] << sections_hash
      tree << website_hash
    end

    render :json => tree.to_json
  end
end