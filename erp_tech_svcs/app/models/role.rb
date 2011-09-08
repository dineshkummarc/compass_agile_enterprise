class Role < ActiveRecord::Base
  validates_presence_of     :internal_identifier
  validates_presence_of     :description
  validates_length_of       :internal_identifier,    :within => 3..100
  validates_uniqueness_of   :internal_identifier,    :case_sensitive => false

  acts_as_erp_type

  has_and_belongs_to_many :users
  has_and_belongs_to_many :secured_models

	def to_xml(options = {})
		default_only = []
  	options[:only] = (options[:only] || []) + default_only
  	super(options)
  end

end
