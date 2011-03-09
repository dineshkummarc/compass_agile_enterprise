class CreateCommEvtStatusValues < ActiveRecord::Migration
  def self.up
    create_comm_evt_status 'new', 'Created, not processed' if (CommEvtStatus.find_by_internal_identifier('new').nil?)
    create_comm_evt_status 'transaction_started', 'Transaction in progress' if (CommEvtStatus.find_by_internal_identifier('transaction_started').nil?)
    create_comm_evt_status 'transaction_complete', 'Transaction completed successfully' if (CommEvtStatus.find_by_internal_identifier('transaction_complete').nil?)
    create_comm_evt_status 'transaction_error', 'Error occured in transaction' if (CommEvtStatus.find_by_internal_identifier('validation_error').nil?)
    create_comm_evt_status 'validation_error', 'Error occured durring validation' if (CommEvtStatus.find_by_internal_identifier('validation_error').nil?)
  end

  def self.create_comm_evt_status (identifier, description)
    status_rec = CommEvtStatus.new
    status_rec.internal_identifier = identifier
    status_rec.description = description
    status_rec.save
  end

  def self.down
    CommEvtStatus.find_by_internal_identifier('validation_error').destroy rescue puts "Error deleting validation_error"
    CommEvtStatus.find_by_internal_identifier('transaction_error').destroy rescue puts "Error deleting transaction_error"
    CommEvtStatus.find_by_internal_identifier('transaction_complete').destroy rescue puts "Error deleting transaction_complete"
    CommEvtStatus.find_by_internal_identifier('transaction_started').destroy rescue puts "Error deleting transaction_started"
    CommEvtStatus.find_by_internal_identifier('new').destroy rescue puts "Error deleting new"
  end
end
