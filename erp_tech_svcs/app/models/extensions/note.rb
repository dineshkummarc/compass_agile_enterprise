Note.class_eval do
  def created_by_username
    party = Party.find(created_by.id)
    party.user.username
  end
end
