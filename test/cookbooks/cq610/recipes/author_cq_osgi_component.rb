# Enable
# -----------------------------------------------------------------------------

# Disabled component
cq_osgi_component 'Author: com.day.cq.dam.core.impl.TagsFileExporter' do
  pid 'com.day.cq.dam.core.impl.TagsFileExporter'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :enable
end

# Enabled component
cq_osgi_component 'Author: com.day.cq.wcm.msm.impl.commands.RolloutCommand' do
  pid 'com.day.cq.wcm.msm.impl.commands.RolloutCommand'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :enable
end

# Disable
# -----------------------------------------------------------------------------

# Disabled component
cq_osgi_component 'Author: com.day.cq.security.HomeACLSetupService' do
  pid 'com.day.cq.security.HomeACLSetupService'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :disable
end

# Enabled component
cq_osgi_component 'Author: com.day.cq.dam.video.servlet.VideoTestServlet' do
  pid 'com.day.cq.dam.video.servlet.VideoTestServlet'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :disable
end
