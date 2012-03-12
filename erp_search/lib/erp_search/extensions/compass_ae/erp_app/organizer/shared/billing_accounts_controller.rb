module ErpInvoicing
  module ErpApp
    module Shared
      Shared::BillingAccountsController.class_eval do

        protected
        def find_party
          if params[:party_id]
            @party = PartySearchFact.find(params[:party_id]).party rescue nil
          end

          if @party.nil?
            @party = PartySearchFact.find(params[:id]).party rescue nil
          end            
        end

      end
    end
  end
end