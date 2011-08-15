class DescriptiveAsset < ActiveRecord::Base
  belongs_to :view_type
  belongs_to :described_record, :polymorphic => true
end
