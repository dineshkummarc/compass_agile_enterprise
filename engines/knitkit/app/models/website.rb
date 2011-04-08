class Website < ActiveRecord::Base
  has_many :published_websites, :dependent => :destroy
  has_many :website_inquiries, :dependent => :destroy
  has_many :website_hosts, :dependent => :destroy

  alias :hosts :website_hosts

  has_many :website_sections, :dependent => :destroy, :order => :lft do
    def root
      WebsiteSection.root(:website_id => proxy_owner.id)
    end

    def roots
      WebsiteSection.roots(:website_id => proxy_owner.id)
    end

    def paths
      map(&:path)
    end

    def permalinks
      map(&:permalink)
    end
    
    # FIXME can this be on the nested_set?
    def update_paths!
      paths = Hash[*roots.map { |r|
          r.self_and_descendants.map { |n| [n.id, { 'path' => n.send(:build_path) }] } }.flatten]
      update paths.keys, paths.values
    end
  end
  
  has_many :themes, :dependent => :destroy do
    def active
      find(:all,:conditions => 'active = 1')
    end
  end

  def self.find_by_host(host)
    WebsiteHost.find_by_host(host).website
  end

  def deactivate_themes!
    themes.each do |theme|
      theme.deactivate!
    end
  end

  def publish_element(comment, element, version)
    self.published_websites.last.publish_element(comment, element, version)
  end

  def publish(comment)
    self.published_websites.last.publish(comment)
  end

  def set_publication_version(version)
    PublishedWebsite.activate(self, version)
  end

  def active_publication
    self.published_websites.all.find{|item| item.active}
  end

  def role
    Role.iid(website_role_iid)
  end

  def after_create
    PublishedWebsite.create(:website => self, :version => 0, :active => true, :comment => 'New Site Created')
    Role.create(:description => "Website #{self.title}", :internal_identifier => website_role_iid)
  end

  def export_setup
    setup_hash = {
      :name => name,
      :hosts => hosts.collect(&:host),
      :title => title,
      :subtitle => subtitle,
      :email => email,
      :allow_inquiries => allow_inquiries,
      :email_inquiries => email_inquiries,
      :sections => []}
    website_sections.each do |website_section|
      section_hash = {
        :name => website_section.title,
        :has_layout => !website_section.layout.blank?,
        :type => website_section.class.to_s,
        :articles => []
      }

      website_section.contents.each do |content|
        section_hash[:articles] << {:name => content.title, :content_area => content.content_area}
      end

      setup_hash[:sections] << section_hash
    end

    setup_hash
  end

  def export
    tmp_dir = Website.make_tmp_dir

    sections_path = Pathname.new(File.join(tmp_dir,'sections'))
    FileUtils.mkdir_p(sections_path) unless sections_path.exist?

    articles_path = Pathname.new(File.join(tmp_dir,'articles'))
    FileUtils.mkdir_p(articles_path) unless articles_path.exist?

    website_sections.each do |website_section|
      unless website_section.layout.blank?
        File.open(File.join(sections_path,"#{website_section.title}.rhtml"), 'w+') {|f| f.write(website_section.layout) }
      end
    end

    contents = website_sections.collect(&:contents).flatten.uniq
    contents.each do |content|
      File.open(File.join(articles_path,"#{content.title}.html"), 'w+') {|f| f.write(content.body_html) }
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

    returning(tmp_dir + "#{name}.zip") do |file_name|
      file_name.unlink if file_name.exist?
      Zip::ZipFile.open(file_name, Zip::ZipFile::CREATE) do |zip|
        files.each { |file| zip.add(file[:name], file[:path]) if ::File.exists?(file[:path]) }
        ::File.open(tmp_dir + 'setup.yml', 'w') { |f| f.write(export_setup.to_yaml) }
        zip.add('setup.yml', tmp_dir + 'setup.yml')
      end
    end
  end

  class << self
    def make_tmp_dir
      random = Time.now.to_i.to_s.split('').sort_by { rand }
      returning Pathname.new(Rails.root + "/tmp/website_export/tmp_#{random}/") do |dir|
        FileUtils.mkdir_p(dir) unless dir.exist?
      end
    end

    def import(file)
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
          if entry.name =~ /setup.yml/
            data = ''
            entry.get_input_stream { |io| data = io.read }
            data = StringIO.new(data) if data.present?
            setup_hash = YAML.load(data)
          else
            #ignore macs metadata
            next if entry.name =~/._|__MACOSX\//
            type =  entry.name.split('/')[(entry.name.split('/').count - 2)]
            name = entry.name.split('/').last
            next if name.nil?
            name = name.sub(/._/, '')
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
        website = Website.new(
          :name => setup_hash[:name],
          :title => setup_hash[:title],
          :subtitle => setup_hash[:subtitle],
          :email => setup_hash[:email],
          :allow_inquiries => setup_hash[:allow_inquiries],
          :email_inquiries => setup_hash[:email_inquiries]
        )

        setup_hash[:hosts].each do |host|
          website.hosts << WebsiteHost.create(:host => host)
          website.save
        end

        setup_hash[:sections].each do |section_hash|
          klass = section_hash[:type].constantize
          section = klass.new(:title => section_hash[:name])
          unless entries.find{|entry| entry[:type] == 'sections' and entry[:name] == "#{section_hash[:name]}.rhtml"}.nil?
            section.layout = entries.find{|entry| entry[:type] == 'sections' and entry[:name] == "#{section_hash[:name]}.rhtml"}[:data]
          end
          section_hash[:articles].each do |article_hash|
            article = Article.find_by_title(article_hash[:name])
            if article.nil?
              article = Article.new(:title => article_hash[:name], :content_area => article_hash[:content_area])
              article.body_html = entries.find{|entry| entry[:type] == 'articles' and entry[:name] == "#{article_hash[:name]}.html"}[:data]
            end
            section.contents << article
          end
          section.save
          website.website_sections << section
        end

        website.save
        success = true
      else
        message = 'Website already exists with that name'
        success = false
      end

      return success, message
    end
  end

  private
  
  def website_role_iid
    "website_#{self.name.underscore}_access"
  end

end
