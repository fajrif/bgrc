# Create Default Administrator
#
Role.delete_all
puts "create roles"
adm1 = Role.create(:name => "admin", :description => "System Administrator granted access to all resources")

Admin.delete_all
puts "create administrator"
Admin.create(:full_name => "Administrator", :email => "admin@baligolfandracketclub.com", :password => "Secret1234!", :password_confirmation => "Secret1234!", role: adm1)
