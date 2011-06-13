class AgreementObserver < ActiveRecord::Observer
  def after_save(agreement)
    begin
      #Rescued because callbacks on postal address create has a contact but
      #may not have a party yet
      agreement.agreement_party_roles.each do |agreement_party_role|
        PartySearchFact.update_search_fact(agreement_party_role.party)
      end
    rescue
    end
  end

  def after_detroy(agreement)
    begin
      #Rescued because callbacks on postal address create has a contact but
      #may not have a party yet
      agreement.agreement_party_roles.each do |agreement_party_role|
        party = Party.find(agreement_party_role.party.id)
        PartySearchFact.update_search_fact(party)
      end
    rescue
    end
  end
end