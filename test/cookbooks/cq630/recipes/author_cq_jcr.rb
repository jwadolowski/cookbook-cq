agent_path = "/etc/replication/agents.author/publish100"
agent_conf_path = agent_path + '/jcr:content'
domain = "publish100.local"
port = node['cq']['publish']['port']
transport_uri =
  "http://#{domain}:#{port}/bin/receive?sling:authRequestLogin=1"

cq_jcr "Author: #{agent_path}" do
  path agent_path
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'jcr:primaryType' => 'cq:Page'
  )

  action :create
end

cq_jcr "Author: #{agent_conf_path}" do
  path agent_conf_path
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'jcr:primaryType' => 'nt:unstructured',
    'jcr:title' => 'Replication agent',
    'enabled' => 'true',
    'transportUri' => transport_uri,
    'transportUser' => 'admin',
    'transportPassword' => node['cq']['publish']['credentials']['password'],
    'cq:template' => '/libs/cq/replication/templates/agent',
    'serializationType' => 'durbo',
    'retryDelay' => '60000',
    'jcr:description' => "Agent that replicates to #{domain}",
    'sling:resourceType' => 'cq/replication/components/agent',
    'logLevel' => 'info',
    'queueBatchMode' => 'true',
    'queueBatchWaitTime' => '10'
  )
  encrypted_fields %w(transportPassword)
  append false

  action :create
end
