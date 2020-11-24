source 'https://supermarket.chef.io'

metadata

# Pinned to enforce Oracle JDK compatibility
cookbook 'java', '= 7.0.0'

group :development  do
  cookbook 'cq610', path: 'test/cookbooks/cq610'
  cookbook 'cq620', path: 'test/cookbooks/cq620'
  cookbook 'cq630', path: 'test/cookbooks/cq630'
  cookbook 'cq640', path: 'test/cookbooks/cq640'
end
