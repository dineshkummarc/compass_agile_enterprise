require 'spec_helper'

describe Agreement do
  it "can be instantiated" do
    Agreement.new.should be_an_instance_of(Agreement)
  end

  it "can be saved successfully" do
    Agreement.create().should be_persisted
  end
  
  it "can use agreement items as methods" do
    agreement_item_type = AgreementItemType.create(:internal_identifier => 'reference_number')
    agreement_item = AgreementItem.create(:agreement_item_type => agreement_item_type, :agreement_item_value => '1234ABCD')
    agreement = Agreement.create
    agreement.description = 'My Agreement'
    agreement.items << agreement_item
    agreement.save!
    agreement.description.should == 'My Agreement'
    agreement.reference_number.should == '1234ABCD'
  end
  
end