#require_dependency 'theme/file'
require 'fileutils'

class Theme < ActiveRecord::Base
  THEME_STRUCTURE = ['stylesheets', 'javascripts', 'images', 'templates']
  BASE_LAYOUTS_VIEWS_PATH = "#{RAILS_ROOT}/vendor/plugins/knitkit/app/views"
  KNITKIT_WEBSITE_STYLESHEETS_PATH = "#{RAILS_ROOT}/vendor/plugins/knitkit/public/stylesheets/knitkit"
  KNITKIT_WEBSITE_IMAGES_PATH = "#{RAILS_ROOT}/vendor/plugins/knitkit/public/images/knitkit"

  has_file_assets

  class << self
    def root_dir
      @@root_dir ||= "#{RAILS_ROOT}/public"
    end

    def base_dir(website)
      "#{root_dir}/sites/site-#{website.id}/themes"
    end

    def import(file, website)
      name = file.original_filename.to_s.gsub(/(^.*(\\|\/))|(\.zip$)/, '').gsub(/[^\w\.\-]/, '_')
      return false unless valid_theme?(file)
      returning Theme.create(:name => name, :website => website) do |theme|
        theme.import(file)
      end
    end

    def make_tmp_dir
      random = Time.now.to_i.to_s.split('').sort_by { rand }
      returning Pathname.new(RAILS_ROOT + "/tmp/themes/tmp_#{random}/") do |dir|
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

  validates_presence_of :name
  validates_uniqueness_of :theme_id, :scope => :website_id
  
  after_create  :create_theme_files
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

  def about
    %w(name author version homepage summary).inject({}) do |result, key|
      result[key] = send(key)
      result
    end
  end
  
  def import(file)
    file_support = TechServices::FileSupport::Base.new(:storage => TechServices::FileSupport.options[:storage])
    file = returning ActionController::UploadedTempfile.new("uploaded-theme") do |f|
      f.write file.read
      f.original_path = file.original_path
      f.read # no idea why we need this here, otherwise the zip can't be opened
    end unless file.path

    theme_root = Theme.find_theme_root(file)

    Zip::ZipFile.open(file.path) do |zip|
      zip.each do |entry|
        if entry.name == 'about.yml'
          # FIXME
        else
          name = entry.name.sub(/__MACOSX\//, '')
          name = Theme.strip_path(entry.name, theme_root)
          data = ''
          entry.get_input_stream { |io| data = io.read }
          data = StringIO.new(data) if data.present?
          theme_file = self.files.find(:first, :conditions => ["name = ? and directory = ?", File.basename(name), File.join("",self.url,File.dirname(name))])
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
    file_support = TechServices::FileSupport::Base.new(:storage => TechServices::FileSupport.options[:storage])
    tmp_dir = Theme.make_tmp_dir
    returning(tmp_dir + "#{name}.zip") do |file_name|
      file_name.unlink if file_name.exist?
      Zip::ZipFile.open(file_name, Zip::ZipFile::CREATE) do |zip|
        files.each {|file|
          contents = file_support.get_contents(File.join(file_support.root,file.directory,file.name))
          relative_path = file.directory.sub("/#{url}",'')
          path = FileUtils.mkdir_p(File.join(tmp_dir,relative_path))
          full_path = File.join(path,file.name)
          File.open(full_path, 'w+') {|f| f.write(contents) }
          zip.add(File.join(relative_path[1..relative_path.length],file.name), full_path) if ::File.exists?(full_path)
        }
        ::File.open(tmp_dir + 'about.yml', 'w') { |f| f.write(about.to_yaml) }
        zip.add('about.yml', tmp_dir + 'about.yml')
      end
    end
  end

  def has_template?(directory, name)
    self.templates.find{|item| item.directory == ::File.join(path,directory).gsub(RAILS_ROOT, '') and item.name == name}
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
    file_support = TechServices::FileSupport::Base.new(:storage => TechServices::FileSupport.options[:storage])
    file_support.delete_file(File.join(file_support.root,self.url))
  end

  def create_theme_files
    file_support = TechServices::FileSupport::Base.new
    create_theme_files_for_directory_node(file_support.build_tree(BASE_LAYOUTS_VIEWS_PATH))
    create_theme_files_for_directory_node(file_support.build_tree(KNITKIT_WEBSITE_STYLESHEETS_PATH))
    create_theme_files_for_directory_node(file_support.build_tree(KNITKIT_WEBSITE_IMAGES_PATH))
  end

  private

  def create_theme_files_for_directory_node(node)
    node[:children].each do |child_node|
      child_node[:leaf] ? save_theme_file(child_node[:id]) : create_theme_files_for_directory_node(child_node)
    end
  end

  def save_theme_file(path)
    contents = IO.read(path)
    unless path.scan('style.css').empty?
      contents.gsub!("../../images/knitkit","../images")
    end

    unless path.scan('base.html.erb').empty?
      contents.gsub!("<%= stylesheet_link_tag('knitkit/extjs_4.css') %>","<%= theme_stylesheet_link_tag('#{self.theme_id}','extjs_4.css') %>")
      contents.gsub!("<%= stylesheet_link_tag('knitkit/style.css') %>","<%= theme_stylesheet_link_tag('#{self.theme_id}','style.css') %>")
    end

    if !path.scan(BASE_LAYOUTS_VIEWS_PATH).empty?
      path = path.gsub(BASE_LAYOUTS_VIEWS_PATH, "/#{self.url}/templates")
    elsif !path.scan(KNITKIT_WEBSITE_STYLESHEETS_PATH).empty?
      path = path.gsub(KNITKIT_WEBSITE_STYLESHEETS_PATH, "/#{self.url}/stylesheets")
    elsif !path.scan(KNITKIT_WEBSITE_IMAGES_PATH).empty?
      path = path.gsub(KNITKIT_WEBSITE_IMAGES_PATH, "/#{self.url}/images")
    end
    
    self.add_file(contents, path)
  end

end
