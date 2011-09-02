class Individual < ActiveRecord::Base
  require 'attr_encrypted'
  
  after_create  :create_party
  after_save    :save_party
  after_destroy :destroy_party

  has_one :party, :as => :business_party

  attr_encrypted :encrypted_ssn, :key => 'a secret key', :marshall => true
  alias_attribute :unencypted_ssn, :social_security_number

  def after_initialize
    self.salt ||= Digest::SHA256.hexdigest((Time.now.to_i * rand(5)).to_s)
  end

  def social_security_number=(ssn)
    self.ssn_last_four = ssn[-4..-1]
    self.encrypted_ssn = Individual.encrypt_encrypted_ssn(ssn)
    self.save
  end

  def social_security_number
    Individual.decrypt_encrypted_ssn(self.encrypted_ssn)
  end

  alias_method :ssn, :social_security_number

  def formatted_ssn_label
    (self.ssn_last_four.blank?) ? "" : "XXX-XX-#{self.ssn_last_four}"
  end

  def self.from_registered_user( a_user )
    ind = Individual.new
    ind.current_first_name = a_user.first_name
    ind.current_last_name = a_user.last_name
  end

  def self.from_registered_user( a_user )
    ind = Individual.new
    ind.current_first_name = a_user.first_name
    ind.current_last_name = a_user.last_name

    #this is necessary because this is where the callback creates the party instance.
    ind.save

    a_user.party = ind.party
    a_user.save
    ind.save
    #this is necessary because save returns a boolean, not the saved object
    return ind
  end

  def create_party
    pty = Party.new
    pty.description = [current_personal_title,current_first_name,current_last_name].join(' ').strip
    pty.business_party = self
    pty.save
    self.save
  end

  def save_party
    party.description = [current_personal_title,current_first_name,current_last_name].join(' ').strip
    party.save
  end

  def destroy_party
    if self.party
      self.party.destroy
    end
  end

  def to_label
    "#{current_first_name} #{current_last_name}"
  end
end
