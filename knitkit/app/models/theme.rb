require 'yaml'
require 'fileutils'

class Theme < ActiveRecord::Base
  THEME_STRUCTURE = ['stylesheets', 'javascripts', 'images', 'templates']
  BASE_LAYOUTS_VIEWS_PATH = "#{Knitkit::Engine.root.to_s}/app/views"
  KNITKIT_WEBSITE_STYLESHEETS_PATH = "#{Knitkit::Engine.root.to_s}/public/stylesheets/knitkit"
  KNITKIT_WEBSITE_IMAGES_PATH = "#{Knitkit::Engine.root.to_s}/public/images/knitkit"

  has_file_assets

  class << self
    def root_dir
      @@root_dir ||= "#{Rails.root}/public"
    end

    def base_dir(website)
      "#{root_dir}/sites/site-#{website.id}/themes"
    end

    def import(file, website)
      name_and_id = file.original_filename.to_s.gsub(/(^.*(\\|\/))|(\.zip$)/, '')
      theme_name = name_and_id.split('[').first
      theme_id = name_and_id.split('[').last.gsub(']','')
      return false unless valid_theme?(file)
      Theme.create(:name => theme_name, :theme_id => theme_id, :website => website).tap do |theme|
        theme.import(file)
      end
    end

    def make_tmp_dir
      random = Time.now.to_i.to_s.split('').sort_by { rand }
      Pathname.new(Rails.root.to_s + "/tmp/themes/tmp_#{random}/").tap do |dir|
        FileUtils.mkdir_p(dir) unless dir.exist?
      end
    end

    def valid_theme?(file)
      valid = false
      Zip::ZipFile.open(file.path) do |zip|
        zip.sort.each do |entry|
          entry.name.split('/').each do |file|
            valid = true if THEME_STRUCTURE.include?(file)
          end
        end
      end
      valid
    end
  end
  
  belongs_to :website

  has_permalink :name, :theme_id, :scope => :website_id,
    :only_when_blank => false, :sync_url => true

  validates :name, :presence => {:message => 'Name cannot be blank'}
  validates_uniqueness_of :theme_id, :scope => :website_id
  
  after_create   :create_theme_files
  before_destroy :delete_theme_files
  
  def path
    "#{self.class.base_dir(website)}/#{theme_id}"
  end

  def url
    "sites/site-#{website.id}/themes/#{theme_id}"
  end
  
  def activate!
    update_attributes! :active => true
  end

  def deactivate!
    update_attributes! :active => false
  end

  def themed_widgets
    widgets = []
    ErpApp::Widgets::Base.installed_widgets.each do |widget_name|
      widgets << widget_name unless self.files.where("directory like '/#{File.join(self.url, 'widgets', widget_name)}%'").empty?
    end
    widgets
  end

  def non_themed_widgets
    already_themed_widgets = self.themed_widgets
    widgets = []
    ErpApp::Widgets::Base.installed_widgets.each do |widget_name|
      widgets << widget_name unless already_themed_widgets.include?(widget_name)
    end
    widgets
  end

  def create_layouts_for_widget(widget)
    file_support = ErpTechSvcs::FileSupport::Base.new
    views_location = "::Widgets::#{widget.camelize}::Base".constantize.views_location
    create_theme_files_for_directory_node(file_support.build_tree(views_location), :widgets, :path_to_replace => views_location, :widget_name => widget)
  end

  def about
    %w(name author version homepage summary).inject({}) do |result, key|
      result[key] = send(key)
      result
    end
  end
  
  def import(file)
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => ErpTechSvcs::FileSupport.options[:storage])
    file = ActionController::UploadedTempfile.new("uploaded-theme").tap do |f|
      f.puts file.read
      f.original_filename = file.original_filename
      f.read # no idea why we need this here, otherwise the zip can't be opened
    end unless file.path

    theme_root = Theme.find_theme_root(file)

    Zip::ZipFile.open(file.path) do |zip|
      zip.each do |entry|
        if entry.name == 'about.yml'
          #TODO
          #FIXME this does not work for some reason
          data = ''
          entry.get_input_stream { |io| data = io.read }
          data = StringIO.new(data) if data.present?
          about = YAML.load(data)
          self.author = about['author'] if about['author']
          self.version = about['version'] if about['version']
          self.homepage = about['homepage'] if about['homepage']
          self.summary = about['summary'] if about['summary']
        else
          name = entry.name.sub(/__MACOSX\//, '')
          name = Theme.strip_path(entry.name, theme_root)
          data = ''
          entry.get_input_stream { |io| data = io.read }
          data = StringIO.new(data) if data.present?
          theme_file = self.files.where("name = ? and directory = ?", File.basename(name), File.join("",self.url,File.dirname(name))).first
          unless theme_file.nil?
            theme_file.data = data
            theme_file.save
          else
            self.add_file(data, File.join(file_support.root,self.url,name)) rescue next
          end
        end
      end
    end
  end

  def export
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => ErpTechSvcs::FileSupport.options[:storage])
    tmp_dir = Theme.make_tmp_dir
    (tmp_dir + "#{name}[#{theme_id}].zip").tap do |file_name|
      file_name.unlink if file_name.exist?
      Zip::ZipFile.open(file_name, Zip::ZipFile::CREATE) do |zip|
        files.each {|file|
          contents = file_support.get_contents(File.join(file_support.root,file.directory,file.name))
          relative_path = file.directory.sub("/#{url}",'')
          path = FileUtils.mkdir_p(File.join(tmp_dir,relative_path))
          full_path = File.join(path,file.name)
          File.open(full_path, 'w+') {|f| f.puts(contents) }
          zip.add(File.join(relative_path[1..relative_path.length],file.name), full_path) if ::File.exists?(full_path)
        }
        ::File.open(tmp_dir + 'about.yml', 'w') { |f| f.puts(about.to_yaml) }
        zip.add('about.yml', tmp_dir + 'about.yml')
      end
    end
  end

  def has_template?(directory, name)
    self.templates.find{|item| item.directory == File.join(path,directory).gsub(Rails.root.to_s, '') and item.name == name}
  end

  class << self
    def find_theme_root(file)
      theme_root = ''
      Zip::ZipFile.open(file.path) do |zip|
        zip.each do |entry|
          entry.name.sub!(/__MACOSX\//, '')
          if theme_root = root_in_path(entry.name)
            break
          end
        end
      end
      theme_root
    end

    def root_in_path(path)
      root_found = false
      theme_root = ''
      path.split('/').each do |piece|
        if piece == 'about.yml' || THEME_STRUCTURE.include?(piece)
          root_found = true
        else
          theme_root += piece + '/' if !piece.match('\.') && !root_found
        end
      end
      root_found ? theme_root : false
    end

    def strip_path(file_name, path)
      file_name.sub(path, '')
    end
  end

  protected

  def delete_theme_files
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => ErpTechSvcs::FileSupport.options[:storage])
    file_support.delete_file(File.join(file_support.root,self.url))
  end

  def create_theme_files
    file_support = ErpTechSvcs::FileSupport::Base.new
    create_theme_files_for_directory_node(file_support.build_tree(BASE_LAYOUTS_VIEWS_PATH), :templates, :path_to_replace => BASE_LAYOUTS_VIEWS_PATH)
    create_theme_files_for_directory_node(file_support.build_tree(KNITKIT_WEBSITE_STYLESHEETS_PATH), :stylesheets, :path_to_replace => KNITKIT_WEBSITE_STYLESHEETS_PATH)
    create_theme_files_for_directory_node(file_support.build_tree(KNITKIT_WEBSITE_IMAGES_PATH), :images, :path_to_replace => KNITKIT_WEBSITE_IMAGES_PATH)
  end

  private

  def create_theme_files_for_directory_node(node, type, options={})
    node[:children].each do |child_node|
      child_node[:leaf] ? save_theme_file(child_node[:id], type, options) : create_theme_files_for_directory_node(child_node, type, options)
    end
  end

  def save_theme_file(path, type, options)
    contents = IO.read(path)
    contents.gsub!("../../images/knitkit","../images") unless path.scan('style.css').empty?
    contents.gsub!("<%= static_stylesheet_link_tag('knitkit/style.css') %>","<%= theme_stylesheet_link_tag('#{self.theme_id}','style.css') %>") unless path.scan('base.html.erb').empty?
  
    path = case type
    when :widgets
      path.gsub(options[:path_to_replace], "/#{self.url}/widgets/#{options[:widget_name]}")
    else
      path.gsub(options[:path_to_replace], "/#{self.url}/#{type.to_s}")
    end

    self.add_file(contents, path)
  end
  
end
