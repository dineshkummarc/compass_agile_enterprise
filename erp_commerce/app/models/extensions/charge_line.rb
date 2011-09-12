ChargeLine.class_eval do
  has_one  :price_component, :as => :priced_component
end
