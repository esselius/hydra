require 'bundler/setup'
require 'aws-sdk'

class App
  def initialize(region, queue_name)
    @region = region
    @queue_name  = queue_name
  end

  def listen
    puts "ehlo #{@region} - #{@queue_name}"
    loop do
      puts receive
      sleep 5
    end
  end

private
  def client
    @client ||= Aws::SQS::Client.new(region: @region)
  end

  def queue_url
    @queue_url ||= client.create_queue(queue_name: @queue_name)[:queue_url]
  end

  def receive
    client.receive_message(
      queue_url: queue_url
    )[:messages].first
  end
end
