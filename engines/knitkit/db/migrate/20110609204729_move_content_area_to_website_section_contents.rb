class MoveContentAreaToWebsiteSectionContents < ActiveRecord::Migration
  def self.up
    
    if columns(:contents).collect {|c| c.name}.include?('content_area')
      add_column :website_section_contents, :content_area, :string

      # move 
      Content.all.each do |content|
        #content.website_section_contents.each do |wsc|
        #  wsc.content_area = content.content_area
        #  wsc.save
        #end
        
        WebsiteSectionContent.update_all("content_area = '#{content.content_area}'", "content_id = #{content.id}")        
      end
      
      remove_column :contents, :content_area
    end
    
  end

  def self.down
    if columns(:website_section_contents).collect {|c| c.name}.include?('content_area')
      add_column :contents, :content_area, :string

      # move 
      Content.all.each do |content|
        content.content_area = content.website_section_contents.first.content_area
        content.save
      end
      
      remove_column :website_section_contents, :content_area
    end
  end
end
