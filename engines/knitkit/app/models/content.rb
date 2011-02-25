class Content < ActiveRecord::Base
  has_many :section_contents
  has_many :sections, :through => :section_contents
    
  validates_presence_of :type
    
  def self.find_by_section_id( section_id )
    Content.find(:all, 
      :joins => "INNER JOIN section_contents ON section_contents.content_id = contents.id",
      :conditions => "section_id = #{section_id} ")
  end
  
  def find_sections_by_site_id( site_id )
    self.sections.find(:all, :conditions => "site_id = #{site_id}")
  end

  def position( section_id )
    position = self.section_contents.find_by_section_id(section_id).position
    position
  end
end
