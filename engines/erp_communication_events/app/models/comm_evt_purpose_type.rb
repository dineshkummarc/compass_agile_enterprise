class CommEvtPurposeType < ActiveRecord::Base

  has_and_belongs_to_many :communication_events,
    :join_table => 'comm_evt_purposes'

  def to_label
    "#{description}"
  end

  def to_s
    "#{description}"
  end

end
