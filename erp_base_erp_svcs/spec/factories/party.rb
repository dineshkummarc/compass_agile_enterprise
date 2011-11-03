FactoryGirl.define do

  factory :party do |p|
    p.sequence(:description){|n| "party #{n}"}
  end

  factory :individual_party, :parent => :party do |ip|
    ip.association :business_party, :factory => :individual
  end

  factory :organization_party, :parent => :party do |op|
    op.association :business_party, :factory => :organization
  end

end

