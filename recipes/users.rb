include_recipe 'ipmi'

node['ipmi']['users'].each_pair do |id,user|
  ipmi_user id do
    username user['username']
    level user['level']
    password user['password']
    if user['enable']
      action [ :modify, :enable ]
    else
      action [ :modify, :disable ]
    end
  end
end
