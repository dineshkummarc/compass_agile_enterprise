class DynamicFormModel < ActiveRecord::Base
  has_many :dynamic_form_documents
  has_many :dynamic_forms, :dependent => :destroy

end