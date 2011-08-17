require 'fileutils'

Paperclip.interpolates(:file_url) { |data, style| data.instance.url  }
Paperclip.interpolates(:file_path) { |data, style| data.instance.path }

class FileAsset < ActiveRecord::Base
  if respond_to?(:class_attribute)
    class_attribute :file_type
    class_attribute :valid_extensions
  else
    class_inheritable_accessor :file_type
    class_inheritable_writer :valid_extensions
  end
  
  belongs_to :file_asset_holder, :polymorphic => true
  instantiates_with_sti

  has_attached_file :data,
    :url => ":file_url",
    :path => ":file_path",
    # FIXME fails with a weird file upload error
  # Tempfile has a name like RackMultipart20090310-22070-hu8w3m-0 which is missing the extension
  :validations => { :extension => lambda { |data, file| validate_extension(data, file) } }

  validates_presence_of :name, :directory
  validates_uniqueness_of :name, :scope => [:directory]
  validates_attachment_presence :data
  validates_attachment_size :data, :less_than => 500.kilobytes

  validates_each :directory, :name do |record, attr, value|
    record.errors.add attr, 'may not contain consequtive dots' if value =~ /\.\./
  end

  validates_format_of :name, :with => /^\w/

  class << self
    def acceptable?(directory, name)
      valid_extensions.include?(::File.extname(name))
    end

    def type_for(directory, name)
      classes = subclasses.uniq
      classes.detect{ |k| k.acceptable?(directory, name) }.try(:name)
    end

    def type_by_extension(extension)
      subclasses.detect{ |k| k.valid_extensions.include?(extension) }
    end

    def validate_extension(data, file)
      if file.name && !file.class.valid_extensions.include?(::File.extname(file.name))
        types = all_valid_extensions.map{ |type| type.gsub(/^\./, '') }.join(', ')
        "#{file.name} is not a valid file type. Valid file types are #{types}."
      end
    end

    def valid_extensions
      read_inheritable_attribute(:valid_extensions) || []
    end

    def all_valid_extensions
      subclasses.map { |k| k.valid_extensions }.flatten.uniq
    end

    def split_path(path)
      directory, name = ::File.split(path)
      directory = nil if directory == '.'
      [directory, name]
    end
  end
  
  def initialize(attributes = {})
    attributes ||= {}

    base_path = attributes.delete(:base_path)
    type, directory, name, data = attributes.values_at(:type, :directory, :name, :data)
    base_path ||= data.original_filename if data.respond_to?(:original_filename)
    
    directory, name = FileAsset.split_path(base_path) if base_path and name.blank?
    #take out RAILS_ROOT
    directory.gsub!(Rails.root.to_s,'')
    
    puts directory
    
    puts data
    
    type ||= FileAsset.type_for(directory, name) if name
    data = StringIO.new(data) if data.is_a?(String)
    
    puts data

    super attributes.merge(:type => type, :directory => directory, :name => name, :data => data)
  end

  def path
    [Rails.root, directory, name].to_path if name
  end

  def base_path
    [directory, name].to_path if name
  end

  def base_path=(base_path)
    self.directory, self.name = self.class.split_path(base_path)
  end

  def url
    #get everything past the public directory
    path = [directory, name].to_path
    split_path = path.split("/")
    "/#{split_path[(split_path.index("public") + 1)..(split_path.count-1)].join('/')}"
  end

  def base_url
    [directory.gsub(/^#{forced_directory}\/?/, ''), name].to_path if name
  end

  def basename
    data_file_name.gsub(/\.#{extname}$/, "")
  end

  def extname
    ::File.extname(data_file_name).gsub(/^\.+/, '')
  end

end

class Image < FileAsset
  self.file_type = :image
  self.valid_extensions = %w(.jpg .jpeg .gif .png .ico)
end

class TextFile < FileAsset
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
  self.valid_extensions = %w(.js)
end

class Stylesheet < TextFile
  self.file_type = :stylesheet
  self.valid_extensions = %w(.css)
end

class Template < TextFile
  self.file_type = :template
  self.valid_extensions = %w(.erb .haml .liquid)
end
