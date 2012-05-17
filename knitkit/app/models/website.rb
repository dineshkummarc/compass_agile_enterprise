class Website < ActiveRecord::Base
  after_destroy :remove_sites_directory, :remove_website_role
  after_create  :setup_website

  has_file_assets
  has_permalink :name, :internal_identifier, :update => false

  has_many :published_websites, :dependent => :destroy
  has_many :website_hosts, :dependent => :destroy
  has_many :website_navs, :dependent => :destroy
  has_many :website_inquiries, :dependent => :destroy
  has_many :website_party_roles, :dependent => :destroy
  has_many :parties, :through => :website_party_roles do
    def owners
      where('role_type_id = ?', RoleType.website_owner)
    end
  end
  has_many :website_sections, :dependent => :destroy, :order => :lft do
    def paths
      collect{|website_section| website_section.paths}.flatten
    end

    #have to do a sort by to override what awesome nested set does for the order by (lft)
    def positioned
      where('parent_id is null').sort_by!(&:position)
    end

    def update_paths!
      all.each{|section| section.self_and_descendants.each{|_section| _section.update_path!}}
    end
  end

  alias :sections :website_sections

  has_many :online_document_sections, :dependent => :destroy, :order => :lft, :class_name => 'OnlineDocumentSection'

  has_many :themes, :dependent => :destroy do
    def active
      where('active = 1')
    end
  end

  validates_uniqueness_of :internal_identifier

  alias :sections :website_sections
  alias :hosts :website_hosts

  def to_label
    self.name
  end

  # creating method because we only want a getter, not a setter for iid
  def iid
    self.internal_identifier
  end

  def add_party_with_role(party, role_type)
    self.website_party_roles << WebsitePartyRole.create(:party => party, :role_type => role_type)
    self.save
  end

  def all_section_paths
    WebsiteSection.select(:path).where(:website_id => self.id).collect{|row| row['path']}
    #ActiveRecord::Base.connection.execute("select path from website_sections where website_id = #{self.id}").collect{|row| row['path']}
  end

  def self.find_by_host(host)
    website = nil
    website_host = WebsiteHost.find_by_host(host)
    website = website_host.website unless website_host.nil?
    website
  end

  def deactivate_themes!
    themes.each do |theme|
      theme.deactivate!
    end
  end

  def publish_element(comment, element, version, current_user)
    self.published_websites.last.publish_element(comment, element, version, current_user)
  end

  def publish(comment, current_user)
    self.published_websites.last.publish(comment, current_user)
  end

  def set_publication_version(version, current_user)
    PublishedWebsite.activate(self, version, current_user)
  end

  def active_publication
    self.published_websites.where(:active => true).first
  end

  def role
    Role.iid(website_role_iid)
  end

  def setup_website
    PublishedWebsite.create(:website => self, :version => 0, :active => true, :comment => 'New Site Created')
    Role.create(:description => "Website #{self.title}", :internal_identifier => website_role_iid)
    configuration = ::Configuration.find_template('default_website_configuration').clone(true)
    configuration.update_configuration_item(ConfigurationItemType.find_by_internal_identifier('contact_us_email_address'), self.email)
    configuration.update_configuration_item(ConfigurationItemType.find_by_internal_identifier('login_url'), '/login')
    configuration.update_configuration_item(ConfigurationItemType.find_by_internal_identifier('homepage_url'), '/home')
    self.configurations << configuration
    self.save
  end

  def remove_sites_directory
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => Rails.application.config.erp_tech_svcs.file_storage)
    begin
      file_support.delete_file(File.join(file_support.root,"sites/#{self.iid}"), :force => true)
    rescue
      #do nothing it may not exist
    end
  end

  def remove_website_role
    role.destroy if role
  end

  def setup_default_pages
    # create default sections for each widget using widget layout
    widget_classes = [
      ::Widgets::ContactUs::Base,
      ::Widgets::Search::Base,
      ::Widgets::ManageProfile::Base,
      ::Widgets::Login::Base,
      ::Widgets::Signup::Base,
      ::Widgets::ResetPassword::Base
    ]
    widget_classes.each do |widget_class|
      website_section = WebsiteSection.new
      website_section.title = widget_class.title
      website_section.in_menu = true unless ["Login", "Sign Up", "Reset Password"].include?(widget_class.title)
      website_section.layout = widget_class.base_layout
      website_section.save
      #make manage profile secured
      website_section.add_role(self.role) if widget_class.title == 'Manage Profile'
      self.website_sections << website_section
    end
    self.save
    self.website_sections.update_paths!
  end

  def export_setup
    setup_hash = {
      :name => name,
      :hosts => hosts.collect(&:host),
      :title => title,
      :subtitle => subtitle,
      :internal_identifier => internal_identifier,
      :email => email,
      :auto_activate_publication => auto_activate_publication,
      :email_inquiries => email_inquiries,
      :sections => [],
      :images => [],
      :files => [],
      :website_navs => []
    }

    setup_hash[:sections] = sections.positioned.collect do |website_section|
      website_section.build_section_hash
    end

    setup_hash[:website_navs] = website_navs.collect do |website_nav|
      {
        :name => website_nav.name,
        :items => website_nav.items.positioned.map{|website_nav_item| build_menu_item_hash(website_nav_item)}
      }
    end

    self.files.where("directory like '%/sites/#{self.iid}/images%'").all.each do |image_asset|
      setup_hash[:images] << {:path => image_asset.directory, :name => image_asset.name}
    end

    self.files.where("directory like '%/#{Rails.application.config.erp_tech_svcs.file_assets_location}/sites/#{self.iid}%'").all.each do |file_asset|
      setup_hash[:files] << {:path => file_asset.directory, :name => file_asset.name}
    end

    setup_hash
  end

  def export
    tmp_dir = Website.make_tmp_dir
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => Rails.application.config.erp_tech_svcs.file_storage)

    sections_path = Pathname.new(File.join(tmp_dir,'sections'))
    FileUtils.mkdir_p(sections_path) unless sections_path.exist?

    articles_path = Pathname.new(File.join(tmp_dir,'articles'))
    FileUtils.mkdir_p(articles_path) unless articles_path.exist?
    
    documented_contents_path = Pathname.new(File.join(tmp_dir, 'documented contents'))
    FileUtils.mkdir_p(documented_contents_path) unless documented_contents_path.exist?

    excerpts_path = Pathname.new(File.join(tmp_dir,'excerpts'))
    FileUtils.mkdir_p(excerpts_path) unless excerpts_path.exist?

    image_assets_path = Pathname.new(File.join(tmp_dir,'images'))
    FileUtils.mkdir_p(image_assets_path) unless image_assets_path.exist?

    file_assets_path = Pathname.new(File.join(tmp_dir,'files'))
    FileUtils.mkdir_p(file_assets_path) unless file_assets_path.exist?

    sections.each do |website_section|
      unless website_section.layout.blank?
        File.open(File.join(sections_path,"#{website_section.internal_identifier}.rhtml"), 'w+') {|f| f.puts(website_section.layout) }
      end
    end

    contents = sections.collect(&:contents).flatten.uniq
    contents.each do |content|
      File.open(File.join(articles_path,"#{content.internal_identifier}.html"), 'w+') {|f| f.puts(content.body_html) }
      unless content.excerpt_html.blank?
        File.open(File.join(excerpts_path,"#{content.internal_identifier}.html"), 'w+') {|f| f.puts(content.excerpt_html) }
      end
    end

    online_document_sections.each do |online_documented_section|
      File.open(File.join(documented_contents_path,"#{online_documented_section.internal_identifier}.html"), 'w+') {|f| f.puts(online_documented_section.documented_item_published_content_html(active_publication)) }
    end

    self.files.where("directory like '%/sites/#{self.iid}/images%'").all.each do |image_asset|
      contents = file_support.get_contents(File.join(file_support.root,image_asset.directory,image_asset.name))
      FileUtils.mkdir_p(File.join(image_assets_path,image_asset.directory))
      File.open(File.join(image_assets_path,image_asset.directory,image_asset.name), 'w+:ASCII-8BIT') {|f| f.puts(contents) }
    end

    self.files.where("directory like '%/#{Rails.application.config.erp_tech_svcs.file_assets_location}/sites/#{self.iid}%'").all.each do |file_asset|
      contents = file_support.get_contents(File.join(file_support.root,file_asset.directory,file_asset.name))
      FileUtils.mkdir_p(File.join(file_assets_path,file_asset.directory))
      File.open(File.join(file_assets_path,file_asset.directory,file_asset.name), 'w+:ASCII-8BIT') {|f| f.puts(contents) }
    end

    files = []
    Dir.glob("#{tmp_dir.to_s}/**/*").each do |entry|
      next if entry =~ /^\./
      path = entry
      entry = entry.gsub(Regexp.new(tmp_dir.to_s), '')
      entry = entry.gsub(Regexp.new(/^\//), '')
      files << {:path => path, :name => entry}
    end

    File.open(tmp_dir + 'setup.yml', 'w') { |f| f.puts(export_setup.to_yaml) }

    (tmp_dir + "#{name}.zip").tap do |file_name|
      file_name.unlink if file_name.exist?
      Zip::ZipFile.open(file_name, Zip::ZipFile::CREATE) do |zip|
        files.each { |file| zip.add(file[:name], file[:path]) if File.exists?(file[:path]) }
        zip.add('setup.yml', tmp_dir + 'setup.yml')
      end
    end
  end

  class << self
    def make_tmp_dir
      Pathname.new(Rails.root + "/tmp/website_export/tmp_#{Time.now.to_i.to_s}/").tap do |dir|
        FileUtils.mkdir_p(dir) unless dir.exist?
      end
    end

    def import(file, current_user)
      file_support = ErpTechSvcs::FileSupport::Base.new(:storage => Rails.application.config.erp_tech_svcs.file_storage)
      message = ''
      success = true

      file = ActionController::UploadedTempfile.new("uploaded-theme").tap do |f|
        f.puts file.read
        f.original_filename = file.original_filename
        f.read # no idea why we need this here, otherwise the zip can't be opened
      end unless file.path

      entries = []
      setup_hash = nil

      tmp_dir = Website.make_tmp_dir
      Zip::ZipFile.open(file.path) do |zip|
        zip.each do |entry|
          f_path = File.join(tmp_dir.to_s, entry.name)
          FileUtils.mkdir_p(File.dirname(f_path))
          zip.extract(entry, f_path) unless File.exist?(f_path)

          next if entry.name =~ /__MACOSX\//
          if entry.name =~ /setup.yml/
            data = ''
            entry.get_input_stream { |io| data = io.read }
            data = StringIO.new(data) if data.present?
            setup_hash = YAML.load(data)
          else
            type =  entry.name.split('/')[0]
            name = entry.name.split('/').last
            next if name.nil?

            if File.exist?(f_path) and !File.directory?(f_path)
              entry_hash = {:type => type, :name => name, :path => entry.name}
              entries << entry_hash unless name == 'sections' || name == 'articles' || name == 'excerpts' || name == 'documented contents'
              entry_hash[:data] = File.open(f_path,"rb") {|io| io.read}
            end
          end

        end
      end
      entries.uniq!
      FileUtils.rm_rf(tmp_dir.to_s)

      if Website.find_by_internal_identifier(setup_hash[:internal_identifier]).nil?
        website = Website.create(
          :name => setup_hash[:name],
          :title => setup_hash[:title],
          :subtitle => setup_hash[:subtitle],
          :internal_identifier => setup_hash[:internal_identifier],
          :email => setup_hash[:email],
          :email_inquiries => setup_hash[:email_inquiries],
          :auto_activate_publication => setup_hash[:auto_activate_publication]
        )

        #set default publication published by user
        first_publication = website.published_websites.first
        first_publication.published_by = current_user
        first_publication.save

        begin
          #handle images
          # entries.each do |entry|
          #   puts "entry type '#{entry[:type]}'"
          #   puts "entry name '#{entry[:name]}'"
          #   puts "entry path '#{entry[:path]}'"
          #   puts "entry data #{!entry[:data].blank?}"
          # end
          # puts "------------------"
          setup_hash[:images].each do |image_asset|
            filename = 'images' + image_asset[:path] + '/' + image_asset[:name]
            #puts "image_asset '#{filename}'"
            content = entries.find{|entry| entry[:type] == 'images' and entry[:path] == filename }
            unless content.nil?
              website.add_file(content[:data], File.join(file_support.root, image_asset[:path], image_asset[:name]))
            end
          end

          #handle files
          setup_hash[:files].each do |file_asset|
            filename = 'files' + file_asset[:path] + '/' + file_asset[:name]
            #puts "file_asset '#{filename}'"
            content = entries.find{|entry| entry[:type] == 'files' and entry[:path] == filename }
            unless content.nil?
              website.add_file(content[:data], File.join(file_support.root, file_asset[:path], file_asset[:name]))
            end
          end

          #handle hosts
          setup_hash[:hosts].each do |host|
            website.hosts << WebsiteHost.create(:host => host)
            website.save
          end

          #handle sections
          setup_hash[:sections].each do |section_hash|
            build_section(section_hash, entries, website, current_user)
          end
          website.website_sections.update_paths!

          #handle website_navs
          setup_hash[:website_navs].each do |website_nav_hash|
            website_nav = WebsiteNav.new(:name => website_nav_hash[:name])
            website_nav_hash[:items].each do |item|
              website_nav.website_nav_items << build_menu_item(item)
            end
            website.website_navs << website_nav
          end

          website.publish("Website Imported", current_user)

        rescue Exception=>ex
          website.destroy unless website.nil?
          raise ex
        end

        website.save
        success = true
      else
        message = 'Website already exists with that internal_identifier'
        success = false
      end
      
      return success, message
    end

    protected

    def build_menu_item(hash)
      website_item = WebsiteNavItem.new(
        :title => hash[:title],
        :url => hash[:url],
        :position => hash[:position]
      )
      unless hash[:linked_to_item_type].blank?
        website_item.linked_to_item = WebsiteSection.find_by_path(hash[:linked_to_item_path])
      end
      website_item.save
      hash[:items].each do |item|
        child_website_item = build_menu_item(item)
        child_website_item.move_to_child_of(website_item)
      end
      unless hash[:roles].empty?
        hash[:roles].each do |role|
          website_item.add_role(Role.find_by_internal_identifier(role)) rescue nil #do nothing if the role does not exist
        end
      end
      website_item
    end

    def build_section(hash, entries, website, current_user)
      klass = hash[:type].constantize
      section = klass.new(:title => hash[:name],
        :in_menu => hash[:in_menu],
        :render_base_layout => hash[:render_base_layout],
        :position => hash[:position],
        :render_base_layout => hash[:render_base_layout])
      section.internal_identifier = hash[:internal_identifier]
      section.permalink = hash[:permalink]
      section.path = hash[:path]
      content = entries.find{|entry| entry[:type] == 'sections' and entry[:name] == "#{hash[:internal_identifier]}.rhtml"}
      unless content.nil?
        section.layout = content[:data]
      end
      hash[:articles].each do |article_hash|
        article = Article.find_by_internal_identifier(article_hash[:internal_identifier])
        if article.nil?
          article = Article.new(:title => article_hash[:name], :display_title => article_hash[:display_title])
          article.created_by = current_user
          article.tag_list = article_hash[:tag_list].split(',').collect{|t| t.strip() } unless article_hash[:tag_list].blank?
          article.body_html = entries.find{|entry| entry[:type] == 'articles' and entry[:name] == "#{article_hash[:internal_identifier]}.html"}[:data]
          content = entries.find{|entry| entry[:type] == 'excerpts' and entry[:name] == "#{article_hash[:internal_identifier]}.html"}
          unless content.nil?
            article.excerpt_html = content[:data]
          end
        end
        section.contents << article
        section.save
        article.update_content_area_and_position_by_section(section, article_hash[:content_area], article_hash[:position])
      end
      website.website_sections << section
      section.save
      if hash[:sections]
        hash[:sections].each do |section_hash|
          child_section = build_section(section_hash, entries, website, current_user)
          child_section.move_to_child_of(section)
        end
      end
      if section.is_a? OnlineDocumentSection
        entry_data = entries.find{|entry| entry[:type] == 'documented contents' and entry[:name] == "#{section.internal_identifier}.html"}[:data]
        documented_content = DocumentedContent.create(:title => section.title, :body_html => entry_data)
        DocumentedItem.create(:documented_content_id => documented_content.id, :online_document_section_id => section.id)
      end
      if hash[:online_document_sections]
        hash[:online_document_sections].each do |section_hash|
          child_section = build_section(section_hash, entries, website, current_user)
          child_section.move_to_child_of(section)
          # CREATE THE DOCUMENTED CONTENT HERE
          entry_data = entries.find{|entry| entry[:type] == 'documented contents' and entry[:name] == "#{child_section.internal_identifier}.html"}[:data]
          documented_content = DocumentedContent.create(:title => child_section.title, :body_html => entry_data)
          DocumentedItem.create(:documented_content_id => documented_content.id, :online_document_section_id => child_section.id)
        end
      end
      unless hash[:roles].empty?
        hash[:roles].each do |role|
          section.add_role(Role.find_by_internal_identifier(role)) rescue nil #do nothing if the role does not exist
        end
      end
      section
    end

  end

  def website_role_iid
    "website_#{self.name.underscore.gsub("'","").gsub(",","")}_access"
  end

  private

  def build_menu_item_hash(menu_item)
    {
      :title => menu_item.title,
      :url => menu_item.url,
      :roles => menu_item.roles.collect{|role| role.internal_identifier},
      :linked_to_item_type => menu_item.linked_to_item_type,
      :linked_to_item_path => menu_item.linked_to_item.nil? ? nil : menu_item.linked_to_item.path,
      :position => menu_item.position,
      :items => menu_item.children.collect{|child| build_menu_item_hash(child)}
    }
  end

end
