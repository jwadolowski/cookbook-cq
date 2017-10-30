cq_user 'test1' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :nothing
end

cq_user 'Update admin user' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  id 'admin'
  email 'superman@mailinator.com'
  first_name 'Clark'
  last_name 'Kent'
  job_title 'Global Implementation Coordinator'
  street '42 Wall Street'
  city 'New York'
  postal_code '10001'
  country 'United States'
  state 'New York'
  phone_number '+1 999 999 999'
  mobile '+1 111 111 111'
  gender 'male'
  about 'Superman!'
  old_password node['cq']['author']['credentials']['old_password']

  action :modify
end

cq_user 'author' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  email 'author@mailinator.com'
  first_name 'John'
  last_name 'Doe'
  job_title 'Legacy Intranet Technician'
  street '42 One Way Rd.'
  city 'London'
  postal_code 'P0ST4L C0D3'
  country 'United Kingdom'
  state 'State X'
  phone_number '+00 123 45 67'
  mobile '+00 111 222 333'
  gender 'male'
  about 'The most awesome AEM author on the planet!'
  enabled false
  user_password 's3cret'

  action :modify
end

cq_user 'random1' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  first_name 'Random'
  last_name 'One'
  about 'Totally random, not existing user'
  user_password 'rand0m'

  action :modify
end
