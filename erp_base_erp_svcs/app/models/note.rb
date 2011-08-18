class Note < ActiveRecord::Base
  belongs_to :note_type
  belongs_to :noted_record, :polymorphic => true
  belongs_to :created_by, :class_name =>'Party', :foreign_key => 'created_by_id'

  def note_type_desc
    self.note_type.description
  end

  def summary
    (content.length > 20) ? "#{content[0..20]}..." : content
  end

  def created_by_username
    created_by.user.username
  end

end
