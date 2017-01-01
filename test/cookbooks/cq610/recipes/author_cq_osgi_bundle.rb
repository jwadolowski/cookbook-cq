cq_osgi_bundle 'Author: org.apache.sling.jcr.webdav' do
  symbolic_name 'org.apache.sling.jcr.webdav'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  same_state_barrier 3
  sleep_time 5

  action :stop
end

cq_osgi_bundle 'org.apache.sling.jcr.davex' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :stop
end

cq_osgi_bundle 'slice-persistence' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :start
end
