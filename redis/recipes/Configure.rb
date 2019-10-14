
require 'aws-sdk-dynamodb'  # v2: require 'aws-sdk'

# Create dynamodb client in us-west-2 region
dynamodb = Aws::DynamoDB::Client.new(region: 'us-west-2')

begin
  
  result = dynamodb.get_item({
    key: {
      "role" =>  "master"
    }, 
    table_name: "chef-joseph" 
  })

  if result.item == nil
    resp = dynamodb.put_item({
      item: {
        "role" => "master",
        "ip" => node['ipaddress'], 
        "host" => node['hostname'] 
      },  
      table_name: "chef-joseph" 
    }) 
    puts 'Insert the master in layer'  
  else


    #If this instance is master
    if result.item['ip'] == node['ipaddress'] 
      
      execute 'redis-server' do
        command "redis-server /etc/redis/redis.conf"
        user 'root'
      end

      puts 'Restart de master node'  

    #This is slave
    else 

      
      puts result.item['ip'] 
      template "#{node[:redis][:conf_dir]}/redis.conf" do
        source        "slave.conf.erb"
        owner         "root"
        group         "root"
        mode          "0644"
        variables     :ip => result.item['ip']
      end
      

 
      execute 'redis-slave' do
        command "redis-server /etc/redis/redis.conf"
        user 'root'
      end

      execute 'reiniciando servidor' do
        command 'service redis-server restart'
        user 'root'
      end


      puts 'Adding slave'
    end
  end
rescue  Aws::DynamoDB::Errors::ServiceError => error
  puts 'Unable to add ip:'
  puts error.message
end