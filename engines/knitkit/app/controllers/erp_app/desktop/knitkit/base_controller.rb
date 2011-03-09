class ErpApp::Desktop::Knitkit::BaseController < ErpApp::Desktop::BaseController
  KNIT_KIT_ROOT = "#{RAILS_ROOT}/vendor/plugins/knitkit/"

  def websites
    @sites = Site.find(:all)

    tree = []

    @sites.each do |site|
      site_hash = {
        :text => site.title,
        :canAddSections => true,
        :iconCls => 'icon-globe',
        :id => "site_#{site.id}",
        :leaf => false,
        :url => "http://#{site.host}",
        :name => site.name,
        :host => site.host,
        :title => site.title,
        :subtitle => site.subtitle,
        :email => site.email,
        :siteName => site.title,
        :children => []
      }
      
      #handle sections
      site.sections.each do |section|
        section_hash = {
          :text => section.title,
          :siteName => site.title,
          :siteId => site.id,
          :type => section.type,
          :isSecured => !section.roles.empty?,
          :isSection => true,
          :hasLayout => !section.layout.blank?,
          :id => "section_#{section.id}",
          :url => "http://#{site.host}/#{section.permalink}"
        }

        if section.is_a?(Blog)
          section_hash[:isBlog] = true
          section_hash[:iconCls] = 'icon-blog'
          section_hash[:leaf] = true
          section_hash[:canAddSections] = false
        else
          section_hash[:canAddSections] = true
          unless section.children.empty?
            section_hash[:leaf] = false
            section_hash[:children] = []
          else
            section_hash[:leaf] = true
            if section_hash[:isSecured]
              section_hash[:iconCls] = 'icon-document_lock'
            else
              section_hash[:iconCls] = 'icon-document'
            end
          end
        end

        
        site_hash[:children] << section_hash
      end
      tree << site_hash
    end

    render :json => tree.to_json
  end
end