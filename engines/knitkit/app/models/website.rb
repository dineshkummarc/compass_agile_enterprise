class Website < ActiveRecord::Base
  after_destroy :remove_sites_directory
  after_create  :setup_website

  has_file_assets
  
  has_many :published_websites, :dependent => :destroy
  has_many :website_hosts, :dependent => :destroy
  has_many :website_navs, :dependent => :destroy
  has_many :website_inquiries, :dependent => :destroy

  alias :hosts :website_hosts

  has_many :website_sections, :dependent => :destroy, :order => :lft do
    def paths
      collect{|website_section| website_section.paths}.flatten
    end

    def positioned
      find(:all, :conditions => 'parent_id is null', :order => 'position')
    end
    
    def update_paths!
      find(:all).each{|section| section.self_and_descendants.each{|_section| _section.update_path!}}
    end
  end
  alias :sections :website_sections
  
  def top_sections
    sections.find_all_by_parent_id(nil)
  end
  
  def all_sections
    sections_array = sections
    sections_array.each do |section|
      sections_array = sections_array | section.descendants
    end
    sections_array.flatten
  end
  
  has_many :themes, :dependent => :destroy do
    def active
      find(:all, :conditions => 'active = 1')
    end
  end
  
  def all_section_paths
    ActiveRecord::Base.connection.select_all("select path from website_sections where website_id = #{self.id}").collect{|row| row['path']}
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
    self.published_websites.all.find{|item| item.active}
  end

  def role
    Role.iid(website_role_iid)
  end

  def setup_website
    PublishedWebsite.create(:website => self, :version => 0, :active => true, :comment => 'New Site Created')
    Role.create(:description => "Website #{self.title}", :internal_identifier => website_role_iid)
  end

  def remove_sites_directory
    file_support = TechServices::FileSupport::Base.new(:storage => TechServices::FileSupport.options[:storage])
    begin
      file_support.delete_file(File.join(file_support.root,"sites/site-#{self.id}"))
    rescue
      #do nothing it may not exist
    end
  end

  def export_setup
    setup_hash = {
      :name => name,
      :hosts => hosts.collect(&:host),
      :title => title,
      :subtitle => subtitle,
      :email => email,
      :auto_activate_publication => auto_activate_publication,
      :email_inquiries => email_inquiries,
      :sections => [],
      :images => [],
      :files => [],
      :website_navs => []
    }

    setup_hash[:sections] = top_sections.collect do |website_section|
      build_section_hash(website_section)
    end

    setup_hash[:website_navs] = website_navs.collect do |website_nav|
      {
        :name => website_nav.name,
        :items => website_nav.website_nav_items.map{|website_nav_item| build_menu_item_hash(website_nav_item)}
      }
    end

    self.files.find(:all, :conditions => "directory like '/sites/site-#{self.id}/images%'").each do |image_asset|
      setup_hash[:images] << {:path => image_asset.directory, :name => image_asset.name}
    end

    self.files.find(:all, :conditions => "directory like '/sites/site-#{self.id}/files%'").each do |file_asset|
      setup_hash[:files] << {:path => file_asset.directory, :name => file_asset.name}
    end

    setup_hash
  end

  def export
    tmp_dir = Website.make_tmp_dir
    file_support = TechServices::FileSupport::Base.new(:storage => TechServices::FileSupport.options[:storage])
    
    sections_path = Pathname.new(File.join(tmp_dir,'sections'))
    FileUtils.mkdir_p(sections_path) unless sections_path.exist?

    articles_path = Pathname.new(File.join(tmp_dir,'articles'))
    FileUtils.mkdir_p(articles_path) unless articles_path.exist?

    image_assets_path = Pathname.new(File.join(tmp_dir,'images'))
    FileUtils.mkdir_p(image_assets_path) unless image_assets_path.exist?

    file_assets_path = Pathname.new(File.join(tmp_dir,'files'))
    FileUtils.mkdir_p(file_assets_path) unless file_assets_path.exist?

    all_sections.each do |website_section|
      unless website_section.layout.blank?
        File.open(File.join(sections_path,"#{website_section.title}.rhtml"), 'w+') {|f| f.write(website_section.layout) }
      end
    end

    contents = all_sections.collect(&:contents).flatten.uniq
    contents.each do |content|
      File.open(File.join(articles_path,"#{content.title}.html"), 'w+') {|f| f.write(content.body_html) }
    end

    self.files.find(:all, :conditions => "directory like '/sites/site-#{self.id}/images%'").each do |image_asset|
      contents = file_support.get_contents(File.join(file_support.root,image_asset.directory,image_asset.name))
      File.open(File.join(image_assets_path,image_asset.name), 'w+') {|f| f.write(contents) }
    end

    self.files.find(:all, :conditions => "directory like '/sites/site-#{self.id}/files%'").each do |file_asset|
      contents = file_support.get_contents(File.join(file_support.root,file_asset.directory,file_asset.name))
      File.open(File.join(file_assets_path,file_asset.name), 'w+') {|f| f.write(contents) }
    end

    files = []

    Dir.entries(sections_path).each do |entry|
      next if entry =~ /^\./
      files << {:path => File.join(sections_path,entry), :name => File.join('sections/',File.basename(entry))}
    end

    Dir.entries(articles_path).each do |entry|
      next if entry =~ /^\./
      files << {:path => File.join(articles_path,entry), :name => File.join('articles/',File.basename(entry))}
    end

    Dir.entries(image_assets_path).each do |entry|
      next if entry =~ /^\./
      files << {:path => File.join(image_assets_path,entry), :name => File.join('images/',File.basename(entry))}
    end

    Dir.entries(file_assets_path).each do |entry|
      next if entry =~ /^\./
      files << {:path => File.join(file_assets_path,entry), :name => File.join('files/',File.basename(entry))}
    end

    files.uniq!

    returning(tmp_dir + "#{name}.zip") do |file_name|
      file_name.unlink if file_name.exist?
      Zip::ZipFile.open(file_name, Zip::ZipFile::CREATE) do |zip|
        files.each { |file| zip.add(file[:name], file[:path]) if File.exists?(file[:path]) }
        File.open(tmp_dir + 'setup.yml', 'w') { |f| f.write(export_setup.to_yaml) }
        zip.add('setup.yml', tmp_dir + 'setup.yml')
      end
    end
  end

  class << self
    def make_tmp_dir
      random = Time.now.to_i.to_s.split('').sort_by { rand }
      returning Pathname.new(RAILS_ROOT + "/tmp/website_export/tmp_#{random}/") do |dir|
        FileUtils.mkdir_p(dir) unless dir.exist?
      end
    end

    def import(file, current_user)
      file_support = TechServices::FileSupport::Base.new(:storage => TechServices::FileSupport.options[:storage])
      message = ''
      success = true

      file = returning ActionController::UploadedTempfile.new("uploaded-theme") do |f|
        f.write file.read
        f.original_path = file.original_path
        f.read # no idea why we need this here, otherwise the zip can't be opened
      end unless file.path
      
      entries = []
      setup_hash = nil

      Zip::ZipFile.open(file.path) do |zip|
        zip.each do |entry|
          next if entry.name =~ /__MACOSX\//
          if entry.name =~ /setup.yml/
            data = ''
            entry.get_input_stream { |io| data = io.read }
            data = StringIO.new(data) if data.present?
            setup_hash = YAML.load(data)
          else
            type =  entry.name.split('/')[(entry.name.split('/').count - 2)]
            name = entry.name.split('/').last
            next if name.nil?
            data = ''
            entry_hash = {:type => type, :name => name}
            entries << entry_hash unless name == 'sections' || name == 'articles'
            entries.uniq!
            data = entry.get_input_stream.read
            entry_hash[:data] = data
          end
        end
      end

      if Website.find_by_name(setup_hash[:name]).nil?
        website = Website.create(
          :name => setup_hash[:name],
          :title => setup_hash[:title],
          :subtitle => setup_hash[:subtitle],
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
          setup_hash[:images].each do |image_asset|
            content = entries.find{|entry| entry[:type] == 'images' and entry[:name] == image_asset[:name]}[:data]
            website.add_file(content, File.join(file_support.root, image_asset[:path].sub(/site-[0-9][0-9]*/, "site-#{website.id}"), image_asset[:name]))
          end

          #handle files
          setup_hash[:files].each do |file_asset|
            content = entries.find{|entry| entry[:type] == 'files' and entry[:name] == file_asset[:name]}[:data]
            website.add_file(content, File.join(file_support.root, file_asset[:path].sub(/site-[0-9][0-9]*/, "site-#{website.id}"), file_asset[:name]))
          end

          #handle hosts
          setup_hash[:hosts].each do |host|
            website.hosts << WebsiteHost.create(:host => host)
            website.save
          end

          #handle sections
          setup_hash[:sections].each do |section_hash|
            website.website_sections << build_section(section_hash, entries, website.id)
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
        message = 'Website already exists with that name'
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
      website_item
    end

    def build_section(hash, entries, website_id)
      klass = hash[:type].constantize
      section = klass.new(:title => hash[:name], :in_menu => hash[:in_menu], :position => hash[:position], :website_id => website_id)
      unless entries.find{|entry| entry[:type] == 'sections' and entry[:name] == "#{hash[:name]}.rhtml"}.nil?
        section.layout = entries.find{|entry| entry[:type] == 'sections' and entry[:name] == "#{hash[:name]}.rhtml"}[:data]
      end
      hash[:articles].each do |article_hash|
        article = Article.find_by_title(article_hash[:name])
        if article.nil?
          article = Article.new(:title => article_hash[:name])
          article.body_html = entries.find{|entry| entry[:type] == 'articles' and entry[:name] == "#{article_hash[:name]}.html"}[:data]
        end
        section.contents << article
        section.save
        article.update_content_area_and_position_by_section(section, article_hash[:content_area], article_hash[:position])
      end
      section.save
      hash[:sections].each do |section_hash|
        child_section = build_section(section_hash, entries, website_id)
        child_section.move_to_child_of(section)
      end
      section
    end
  end

  private
  
  def website_role_iid
    "website_#{self.name.underscore.gsub("'","").gsub(",","")}_access"
  end

  def build_section_hash(section)
    section_hash = {
      :name => section.title,
      :has_layout => !section.layout.blank?,
      :type => section.class.to_s,
      :in_menu => section.in_menu,
      :articles => [],
      :path => section.path,
      :permalink => section.permalink,
      :internal_identifier => section.internal_identifier,
      :position => section.position,
      :sections => section.children.each.map{|child| build_section_hash(child)}
    }

    section.contents.each do |content|
      content_area = content.content_area_by_website_section(section)
      position = content.position_by_website_section(section)
      section_hash[:articles] << {:name => content.title, :content_area => content_area, :position => position, :internal_identifier => content.internal_identifier}
    end

    section_hash
  end

  def build_menu_item_hash(menu_item)
    {
      :title => menu_item.title,
      :url => menu_item.url,
      :linked_to_item_type => menu_item.linked_to_item_type,
      :linked_to_item_path => menu_item.linked_to_item.nil? ? nil : menu_item.linked_to_item.path,
      :position => menu_item.position,
      :items => menu_item.children.collect{|child| build_menu_item_hash(child)}
    }
  end

end
