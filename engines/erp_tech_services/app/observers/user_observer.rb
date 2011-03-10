class UserObserver < ActiveRecord::Observer
  def after_create(user)
    individual = Individual.create(:current_first_name => user.first_name, :current_last_name => user.last_name)
    individual.party.user = user
    individual.party.save
  end
end