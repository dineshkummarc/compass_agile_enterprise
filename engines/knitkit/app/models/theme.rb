#require_dependency 'theme/file'
require 'fileutils'

class Theme < ActiveRecord::Base
  THEME_STRUCTURE = ['stylesheets', 'javascripts', 'images', 'templates']
  BASE_LAYOUTS_VIEWS_PATH = "#{RAILS_ROOT}/vendor/plugins/knitkit/app/views"

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
      returning Pathname.new(Rails.root + "/tmp/themes/tmp_#{random}/") do |dir|
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
  
  after_create  :create_theme_dir
  after_destroy :delete_theme_dir
  
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

  def copy(options={})
    raise 'not implemented'
    #    clone = nil
    #    begin
    #      clone = self.clone
    #      clone.theme_id = options[:theme_id]
    #      clone.name = options[:name]
    #      clone.active = false
    #      clone.id = nil
    #      clone.files = []
    #      clone_path = self.path.sub(self.theme_id, options[:theme_id])
    #      FileUtils.cp_r(self.path, clone_path)
    #      clone.save
    #      self.files.each do |file|
    #        clone_file = file.clone
    #        clone_file.id = nil
    #        clone_file.name = file.name
    #        clone_file.file_asset_holder = clone
    #        clone_file.save
    #      end
    #    rescue Exception=>ex
    #      unless clone.nil?
    #        clone.destroy
    #      end
    #      if File.exists(clone_path)
    #        File.delete(clone_path)
    #      end
    #    end
    #    clone
  end
  
  def import(file)
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
          theme_file = self.files.find(:first, :conditions => ["name = ?", ::File.basename(name)])
          unless theme_file.nil?
            theme_file.data = data
            theme_file.save
          else
            self.add_file(name, data) rescue next
          end
        end
      end
    end
  end

  def export
    tmp_dir = Theme.make_tmp_dir
    returning(tmp_dir + "#{name}.zip") do |file_name|
      file_name.unlink if file_name.exist?
      Zip::ZipFile.open(file_name, Zip::ZipFile::CREATE) do |zip|
        theme_path = self.path.gsub(RAILS_ROOT, '')
        files.each {|file|
          name = file.base_path.gsub(theme_path + '/','')
          zip.add(name, file.path) if ::File.exists?(file.path)
        }
        ::File.open(tmp_dir + 'about.yml', 'w') { |f| f.write(about.to_yaml) }
        zip.add('about.yml', tmp_dir + 'about.yml')
      end
    end
  end

  def has_template?(directory, name)
    self.templates.find{|item| item.directory == directory and item.name == name}
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

  def create_theme_dir
    #copy all layouts over to the theme
    FileUtils.mkdir_p(path)
    FileUtils.cp_r(BASE_LAYOUTS_VIEWS_PATH, path)
    #rename views to templates
    ::File.rename(::File.join(path,'views'), ::File.join(path,'templates'))

    #create FileAssets for all the files
    Dir.glob(::File.join(path,'/*/*/*')).each do |file|
      next if file =~ /^\./
      unless ::File.directory? file
        self.add_file(file, IO.read(file))
      end
    end
  end

  def delete_theme_dir
    FileUtils.rm_rf(path)
  end
end
