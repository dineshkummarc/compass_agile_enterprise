class CreatePartyAndRoleTypeForCommunicationEvents < ActiveRecord::Migration
  def up
    role_type = RoleType.find_or_create_by_description_and_internal_identifier('Application', 'application')
    party = Party.find_or_create_by_description('Compass AE')
    party.role_type << role_type
  end

  def down
  end
end
