class Comment < ActiveRecord::Base
  belongs_to :commented_record, :polymorphic => true
  belongs_to :user

  alias :approved_by :user

  named_scope :in_order, :order => 'created_at ASC'
  named_scope :recent, :order => 'created_at DESC'
  named_scope :approved, :conditions => 'approved == 1'

  def approved?
    self.approved == 1
  end

  def approve(user)
    self.approved = 1
    self.user = user
    self.approved_at = Time.now
    self.save
  end
  
end
