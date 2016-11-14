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
    sh 'berks upload'
  end
end

# -----------------------------------------------------------------------------
# Git
# -----------------------------------------------------------------------------
namespace 'git' do
  desc 'Create new Git tag'
  task :tag do
    sh "git tag -a v#{cookbook_version} -m \"v#{cookbook_version} release\""
  end

  desc 'Push new tag to Git repository'
  task :push do
    sh "git push origin v#{cookbook_version}"
  end

  desc 'Create new tag and push it to Git repository'
  task :release => [:tag, :push]
end

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
desc 'Release new cookbook version'
task :release => ['berkshelf:update', 'git:release', 'berkshelf:upload']

task default: :release
