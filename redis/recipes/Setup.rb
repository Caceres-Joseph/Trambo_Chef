
# install the mongo ruby gem at compile time to make it globally available
gem_package 'aws-sdk' do
  action :install
end

Chef::Log.warn("Installing AWS SDK")


# Include apt recipe to add redis repository
include_recipe 'apt'

# Add redis repository
apt_repository 'redis-server' do
  uri          'ppa:chris-lea/redis-server'
  distribution node['lsb']['codename']
end

# Install redis_server
package 'redis-server'


# Configure master node template
template "#{node[:redis][:conf_dir]}/redis.conf" do
  source        "redis.conf.erb"
  owner         "root"
  group         "root"
  mode          "0644"
  variables     :redis => node[:redis], :redis_server => node[:redis][:server]
end