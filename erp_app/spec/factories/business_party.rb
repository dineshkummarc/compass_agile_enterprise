FactoryGirl.define do

  factory :individual do |i|
    i.current_last_name "Doe"
    i.current_first_name "John"
    i.current_middle_name "Will"
    i.current_suffix "Jr"
    i.current_nickname "Billy"
    i.gender "m"
    i.height "6ft"
    i.weight "180 lbs"
    i.mothers_maiden_name "Smith"
  end


  factory :organization do |o|
    o.sequence(:description){|n| "Organization #{n}"}
    o.sequence(:tax_id_number) {|n| "#{n}"}
  end

end
