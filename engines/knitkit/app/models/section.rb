class Section < ActiveRecord::Base
  KNIT_KIT_ROOT = "#{RAILS_ROOT}/vendor/plugins/knitkit/"

  @@types = ['Page']
  cattr_reader :types
  
  acts_as_nested_set :scope => :site_id
  
  belongs_to :site
  has_many :section_contents
  has_many :contents, :through => :section_contents
  
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

  def template_path
    path = nil
    path = File.join(KNIT_KIT_ROOT,"app/views/sections/#{self.template}.html.erb") unless self.template.nil?
    path
  end

  def create_template(template_name)
    result = true

    if File.exists?(File.join(KNIT_KIT_ROOT,"app/views/sections/#{template_name}.html.erb"))
      result = "Name already used for layout"
    else
      FileUtils.cp File.join(KNIT_KIT_ROOT,"app/views/sections/index.html.erb"), File.join(KNIT_KIT_ROOT,"app/views/sections/#{template_name}.html.erb")
    end

    result
  end
end


