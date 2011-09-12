class AddFromAndThruDatesToPricingPlan < ActiveRecord::Migration
  def self.up
    unless columns(:pricing_plans).collect {|c| c.name}.include?('from_date')
      add_column :pricing_plans, :from_date, :date
    end
    unless columns(:pricing_plans).collect {|c| c.name}.include?('thru_date')
      add_column :pricing_plans, :thru_date, :date
    end
  end

  def self.down
    if columns(:pricing_plans).collect {|c| c.name}.include?('from_date')
      remove_column :pricing_plans, :from_date
    end
    if columns(:pricing_plans).collect {|c| c.name}.include?('thru_date')
      remove_column :pricing_plans, :thru_date
    end
  end
end
