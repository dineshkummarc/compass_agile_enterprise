Rails.application.routes.draw do
  mount ErpCommunicationEvents::Engine => "/erp_communication_events"
end
