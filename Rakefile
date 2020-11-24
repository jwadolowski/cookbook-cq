# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
def cookbook_version
  require 'chef/cookbook/metadata'

  metadata = Chef::Cookbook::Metadata.new
  metadata.from_file('metadata.rb')
  metadata.version
end

# -----------------------------------------------------------------------------
# Berkshelf
# -----------------------------------------------------------------------------
namespace 'berkshelf' do
  desc 'Update cookbook dependencies'
  task :update do
    sh 'berks update || berks install'
  end

  desc 'Upload cookbook to Chef Server'
  task :upload do
    sh 'berks upload --except development'
  end
end

# -----------------------------------------------------------------------------
# Git
# -----------------------------------------------------------------------------
namespace 'git' do
  desc 'Create new Git tag'
  task tag: ['lint'] do
    sh "git tag -a v#{cookbook_version} -m \"v#{cookbook_version} release\""
  end

  desc 'Push new tag to Git repository'
  task :push do
    sh "git push origin v#{cookbook_version}"
  end

  desc 'Create new tag and push it to Git repository'
  task release: [:tag, :push]
end

# -----------------------------------------------------------------------------
# Style
# -----------------------------------------------------------------------------
namespace 'style' do
  require 'cookstyle'
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:cookstyle)
end

# -----------------------------------------------------------------------------
# Stove
# -----------------------------------------------------------------------------
namespace 'stove' do
  require 'stove/rake_task'

  # Credentials are stored in ~/.stove
  Stove::RakeTask.new do |t|
    t.stove_opts = ['--no-git']
  end
end

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
desc 'Run linters'
task lint: ['style:cookstyle']

desc 'Release new cookbook version'
task release: [
  'berkshelf:update', 'git:release', 'berkshelf:upload', 'stove:publish'
]

desc 'Upload released cookbook to Chef Server'
task upload: ['berkshelf:update', 'berkshelf:upload']

task default: :release
