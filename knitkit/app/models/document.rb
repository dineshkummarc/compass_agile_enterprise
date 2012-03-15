class Document < ActiveRecord::Base
  has_relational_dynamic_attributes
  has_file_assets

  belongs_to :document_record, :polymorphic => true
  belongs_to :document_type
  
end
