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
        :children => []
      }
      
      #handle sections
      site.sections.each do |section|
        section_hash = {
          :text => section.title,
          :siteName => site.title,
          :type => section.type,
          :isSection => true,
          :id => "section_#{section.id}",
          :url => "http://#{site.host}/#{section.permalink}",
          :templatePath => section.template_path.blank? ? nil : section.template_path
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
            section_hash[:iconCls] = 'icon-document'
          end
        end

        
        site_hash[:children] << section_hash
      end
      tree << site_hash
    end

    render :json => tree.to_json
  end
end