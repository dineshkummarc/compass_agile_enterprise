require 'fileutils'

Paperclip.interpolates(:file_path){|data, style|
  case Rails.application.config.erp_tech_svcs.file_storage
  when :filesystem
    file_support = ErpTechSvcs::FileSupport::Base.new
    File.join(file_support.root,data.instance.directory,data.instance.name)
  when :s3
    File.join(data.instance.directory,data.instance.name)
  end
}

Paperclip.interpolates(:file_url){|data, style|
  url = File.join(data.instance.directory, data.instance.name)
  case Rails.application.config.erp_tech_svcs.file_storage
  when :filesystem
    #if public is at the front of this path and we are using file_system remove it
    dir_pieces = url.split('/')
    unless dir_pieces[1] == 'public'
      "/download/#{data.instance.name}?path=#{dir_pieces.delete_if{|name| name == data.instance.name}.join('/')}"
    else
      dir_pieces.delete_at(1) if dir_pieces[1] == 'public'
      dir_pieces.join('/')
    end
  when :s3
    url
  end
}

class FileAsset < ActiveRecord::Base
  if respond_to?(:class_attribute)
    class_attribute :file_type
    class_attribute :valid_extensions
    class_attribute :content_type
  else
    class_inheritable_accessor :file_type
    class_inheritable_accessor :content_type
    class_inheritable_writer :valid_extensions
  end

  after_create :set_sti
  after_save   :set_data_file_name

  belongs_to :file_asset_holder, :polymorphic => true
  instantiates_with_sti

  has_capabilities

  #paperclip
  has_attached_file :data,
    :storage => Rails.application.config.erp_tech_svcs.file_storage,
    :s3_protocol => Rails.application.config.erp_tech_svcs.s3_protocol,
    :s3_permissions => :public_read,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path => ":file_path",
    :url => ":file_url",
    :validations => { :extension => lambda { |data, file| validate_extension(data, file) } }

  before_post_process :set_content_type

  validates_attachment_presence :data
  validates_attachment_size :data, :less_than => Rails.application.config.erp_tech_svcs.max_file_size_in_mb.megabytes

  validates :name, :presence => {:message => 'Name can not be blank'}
  validates_uniqueness_of :name, :scope => [:directory]
  validates_each :directory, :name do |record, attr, value|
    record.errors.add attr, 'may not contain consequtive dots' if value =~ /\.\./
  end
  validates_format_of :name, :with => /^\w/

  class << self
    def acceptable?(name)
      valid_extensions.include?(File.extname(name))
    end

    def type_for(name)
      classes = all_subclasses.uniq
      classes.detect{ |k| k.acceptable?(name) }.try(:name)
    end

    def type_by_extension(extension)
      klass = all_subclasses.detect{ |k| k.valid_extensions.include?(extension) }
      klass = TextFile if klass.nil?
      klass
    end

    def validate_extension(data, file)
      if file.name && !file.class.valid_extensions.include?(File.extname(file.name))
        types = all_valid_extensions.map{ |type| type.gsub(/^\./, '') }.join(', ')
        "#{file.name} is not a valid file type. Valid file types are #{types}."
      end
    end

    def valid_extensions
      read_inheritable_attribute(:valid_extensions) || []
    end

    def all_valid_extensions
      all_subclasses.map { |k| k.valid_extensions }.flatten.uniq
    end

    def split_path(path)
      directory, name = ::File.split(path)
      directory = nil if directory == '.'
      [directory, name]
    end
  end

  def initialize(attributes = {}, options)
    attributes ||= {}

    base_path = attributes.delete(:base_path)
    @type, directory, name, data = attributes.values_at(:type, :directory, :name, :data)
    base_path ||= data.original_filename if data.respond_to?(:original_filename)

    directory, name = FileAsset.split_path(base_path) if base_path and name.blank?
    directory.gsub!(Rails.root.to_s,'')

    @type ||= FileAsset.type_for(name) if name
    @type = "TextFile" if @type.nil?
    @name = name

    data = StringIO.new(data) if data.is_a?(String)

    super attributes.merge(:directory => directory, :name => name, :data => data)
  end

  def basename
    data_file_name.gsub(/\.#{extname}$/, "")
  end

  def extname
    File.extname(self.data_file_name).gsub(/^\.+/, '')
  end

  def set_sti
    update_attribute :type, @type
  end

  def set_content_type
    unless @type.nil?
      klass = @type.constantize
      content_type = klass == Image ? "image/#{File.extname(@name).gsub(/^\.+/, '')}" : klass.content_type
      self.data.instance_write(:content_type, content_type)
    end
  end

  def set_data_file_name
    update_attribute :data_file_name, name if data_file_name != name
  end

  def get_contents
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => Rails.application.config.erp_tech_svcs.file_storage)
    file_support.get_contents(File.join(self.directory,self.data_file_name))
  end

  def move(new_parent_path)
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => Rails.application.config.erp_tech_svcs.file_storage)
    result, message = file_support.save_move(File.join(self.directory, self.name), new_parent_path)
    if result
      self.directory = new_parent_path.gsub(Regexp.new(Rails.root.to_s), '') # strip rails root from new_parent_path, we want relative path
      self.save
    end

    return result, message
  end

end

class Image < FileAsset
  self.file_type = :image
  self.valid_extensions = %w(.jpg .jpeg .gif .png .ico .PNG .JPEG .JPG)
end

class TextFile < FileAsset
  self.file_type = :textfile
  self.content_type = 'text/plain'
  self.valid_extensions = %w(.txt .text)

  def data=(data)
    data = StringIO.new(data) if data.is_a?(String)
    super
  end

  def text
    @text ||= ::File.read(path) rescue ''
  end
end

class Javascript < TextFile
  self.file_type = :javascript
  self.content_type = 'text/javascript'
  self.valid_extensions = %w(.js)
end

class Stylesheet < TextFile
  self.file_type = :stylesheet
  self.content_type = 'text/css'
  self.valid_extensions = %w(.css)
end

class Template < TextFile
  self.file_type = :template
  self.content_type = 'text/plain'
  self.valid_extensions = %w(.erb .haml .liquid .builder)
end

class HtmlFile < TextFile
  self.file_type = :html
  self.content_type = 'text/html'
  self.valid_extensions = %w(.html)
end

class Pdf < TextFile
  self.file_type = :pdf
  self.content_type = 'application/pdf'
  self.valid_extensions = %w(.pdf)
end

class Swf < TextFile
  self.file_type = :swf
  self.content_type = 'application/x-shockwave-flash'
  self.valid_extensions = %w(.swf)
end
