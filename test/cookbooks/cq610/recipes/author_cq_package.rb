# General Service Pack/hotfix deployment
# -----------------------------------------------------------------------------
cq_package 'SP2' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem61']['sp2']
  recursive_install true
  rescue_mode true
  same_state_barrier 12
  error_state_barrier 12
  max_attempts 36

  action :deploy

  notifies :restart, 'service[cq61-author]', :immediately
end

# Upload & install (recursive) + reboot
# -----------------------------------------------------------------------------
cq_package 'SP2 CFP3 (upload)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem61']['sp2_cfp3']

  action :upload
end

cq_package 'SP2 CFP3 (install)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem61']['sp2_cfp3']
  recursive_install true

  action :install

  notifies :restart, 'service[cq61-author]', :immediately
end

# Upload new packages
# -----------------------------------------------------------------------------
cq_package 'Slice (upload)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://oss.sonatype.org/content/groups/public/com/cognifide/slice/'\
    'slice-assembly/4.3.1/slice-assembly-4.3.1-cq.zip'

  action :upload
end

cq_package 'Slice Extension for AEM6 (upload)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://oss.sonatype.org/content/groups/public/com/cognifide/'\
    'slice-addon/slice-aem60-assembly/1.2.0/slice-aem60-assembly-1.2.0-aem.zip'

  action :upload
end

# Install new packages (non-recursive)
# -----------------------------------------------------------------------------
cq_package 'Slice (install)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://oss.sonatype.org/content/groups/public/com/cognifide/slice/'\
    'slice-assembly/4.3.1/slice-assembly-4.3.1-cq.zip'

  action :install
end

cq_package 'Slice Extension for AEM6 (install)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://oss.sonatype.org/content/groups/public/com/cognifide/'\
    'slice-addon/slice-aem60-assembly/1.2.0/slice-aem60-assembly-1.2.0-aem.zip'

  action :install
end

# Upload already uploaded package
# -----------------------------------------------------------------------------
cq_package 'com.adobe.granite.httpcache.content (upload)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source "http://localhost:#{node['cq']['author']['port']}"\
    '/etc/packages/Adobe/granite/com.adobe.granite.httpcache.content-1.0.2.zip'
  http_user node['cq']['author']['credentials']['login']
  http_pass node['cq']['author']['credentials']['password']

  action :upload
end

# Install already installed package
# -----------------------------------------------------------------------------
cq_package 'cq-chart-content (install)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source "http://localhost:#{node['cq']['author']['port']}"\
    '/etc/packages/day/cq60/product/cq-chart-content-1.0.2.zip'
  http_user node['cq']['author']['credentials']['login']
  http_pass node['cq']['author']['credentials']['password']

  action :install
end

# Install not yet uploaded package
# -----------------------------------------------------------------------------
cq_package 'AEM Dash (install)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://github.com/Cognifide/AEM-Dash/releases/download/'\
    'dash-1.2.0/dash-1.2.0-tool.zip'

  action :install
end

# Upload 3 versions of the same package, but install 2 oldest version only
# -----------------------------------------------------------------------------
cq_package 'ACS AEM Commons 2.9.0' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://github.com/Adobe-Consulting-Services/acs-aem-commons/'\
    'releases/download/acs-aem-commons-2.9.0/acs-aem-commons-content-2.9.0.zip'

  action :upload
end

cq_package 'ACS AEM Commons 2.8.2' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://github.com/Adobe-Consulting-Services/acs-aem-commons/'\
    'releases/download/acs-aem-commons-2.8.2/acs-aem-commons-content-2.8.2.zip'

  action [:upload, :install]
end

cq_package 'ACS AEM Commons 2.8.0' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://github.com/Adobe-Consulting-Services/acs-aem-commons/'\
    'releases/download/acs-aem-commons-2.8.0/acs-aem-commons-content-2.8.0.zip'

  action [:upload, :install]
end

# Uninstall Geometrixx package
# -----------------------------------------------------------------------------
cq_package 'Geometrixx All' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source "http://localhost:#{node['cq']['author']['port']}"\
    '/etc/packages/day/cq60/product/cq-geometrixx-all-pkg-5.8.392.zip'
  http_user node['cq']['author']['credentials']['login']
  http_pass node['cq']['author']['credentials']['password']

  action :uninstall
end

# Delete a package
# -----------------------------------------------------------------------------
cq_package 'cq-screens-content' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source "http://localhost:#{node['cq']['author']['port']}"\
    '/etc/packages/day/cq61/product/cq-screens-content-0.1.6.zip'
  http_user node['cq']['author']['credentials']['login']
  http_pass node['cq']['author']['credentials']['password']

  action :delete
end
