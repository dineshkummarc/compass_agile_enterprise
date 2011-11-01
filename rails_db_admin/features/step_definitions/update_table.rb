
@selenium
Given /^a (.*) table with a row where these (.*) equal this (.*)$/ do |table, columns, data|

  `rake app:db:migrate_data RAILS_ENV=cucumber`
  columns = columns.split(",")
  data = data.split(",")
  data_hsh = {}

  columns.each do |col|
    data.each do |val|
      data_hsh[col] = val
    end
  end

  @roles_model  = Factory.create(table.to_sym, data_hsh)

  visit('/erp_app/login')
  page.execute_script("Ext.getCmp('loginTo').setValue('/erp_app/desktop/'); Ext.getCmp('loginTo').fireEvent('select');")
  fill_in('login', :with => 'admin')
  fill_in('password', :with => 'password')
  click_button('Submit')
  #visit('/erp_app/desktop/')
  click_button('Start')
end

