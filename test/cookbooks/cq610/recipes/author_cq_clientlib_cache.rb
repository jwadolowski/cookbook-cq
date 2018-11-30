cq_clientlib_cache 'invalidation' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :invalidate
end

cq_clientlib_cache 'rebuild' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :rebuild
end
