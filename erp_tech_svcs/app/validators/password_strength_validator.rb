class PasswordStrengthValidator < ActiveModel::EachValidator
  # implement the method where the validation logic must reside
  def validate_each(record, attribute, value)
    password_validation_hash = record.password_validator || {:error_message => 'must be at least 8 characters long and start and end with a letter', :regex => '^[A-Za-z]\w{6,}[A-Za-z]$'}
    record.errors[attribute] << password_validation_hash[:error_message] unless Regexp.new(password_validation_hash[:regex]) =~ value
  end
end
        
