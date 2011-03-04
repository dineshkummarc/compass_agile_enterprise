class Section < ActiveRecord::Base
  #acts_as_versioned
  can_be_published
  
  KNIT_KIT_ROOT = "#{RAILS_ROOT}/vendor/plugins/knitkit/"
  SECTIONS_TEMP_LAYOUT_PATH = "#{RAILS_ROOT}/vendor/plugins/knitkit/app/views/sections/"
  
  @@types = ['Page']
  cattr_reader :types
  
  acts_as_nested_set :scope => :site_id if ActiveRecord::Base.connection.tables.include?('sections') #better nested set tries to use this before the table is there...
  
  belongs_to :site
  has_many :section_contents, :dependent => :destroy
  has_many :contents, :through => :section_contents

  validates_uniqueness_of :title
  has_permalink :title
  
  def articles 
    articles = Article.find_by_section_id(self.id)
    articles
  end
  
  class << self
    def register_type(type)
      @@types << type
      @@types.uniq!
    end
  end
  
  def type
    read_attribute(:type) || 'Page'
  end

  def create_layout
    self.layout = IO.read(File.join(KNIT_KIT_ROOT,"app/views/sections/index.html.erb"))
    self.save
  end

  #callbacks
  def after_save
    unless self.layout.blank?
      File.open(File.join(SECTIONS_TEMP_LAYOUT_PATH,"#{self.title.underscore}_#{self.id}.html.erb"), 'w+') {|f| f.write(self.layout) }
    end
  end
end


