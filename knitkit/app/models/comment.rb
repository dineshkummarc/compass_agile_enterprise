class Comment < ActiveRecord::Base
  belongs_to :commented_record, :polymorphic => true
  belongs_to :user

  validates :comment, :presence => {:message => 'Comment cannot be blank'}

  alias :approved_by :user

  scope :in_order, order('created_at ASC')
  scope :recent, order('created_at DESC')
  scope :approved, where('approved = 1')

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
