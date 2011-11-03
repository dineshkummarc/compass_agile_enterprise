FactoryGirl.define do

  factory :preference_option do |pu|
    pu.description "portablemind_desktop_background"
    pu.internal_identifier "protablemind_desktop_background"
    pu.value "portablemind.png"
  end

  factory :preference_type do 
    description "Desktop Background"
    internal_identifier "desktop_background"
  end
end
