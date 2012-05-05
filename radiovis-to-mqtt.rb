#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'pp'

Bundler.require(:default)

# Load the configuration file
CONFIG = YAML::load_file('config.yml')

# Make STDOUT unbuffered
STDOUT.sync = true

# First, resolve the services using RadioDNS
services = {}
CONFIG['radiovis'].each do |topic|
  dns = topic.split('/').reverse.join('.') + '.radiodns.org'
  begin
    radiovis = RadioDNS::Resolver.resolve(dns).radiovis
    services[radiovis.host] ||= {}
    services[radiovis.host]['port'] = radiovis.port
    services[radiovis.host]['topics'] ||= []
    services[radiovis.host]['topics'] << "/topic/#{topic}/image"
    services[radiovis.host]['topics'] << "/topic/#{topic}/text"
  rescue Resolv::ResolvError
    puts "No RadioVis service found for #{dns}"
  end
end

pp services

module StompClient
  include EM::Protocols::Stomp

  def connection_completed
    connect
  end

  def message_callback(&block)
    @message_callback = block
  end

  def connected_callback(&block)
    @connected_callback = block
  end

  def receive_msg msg
    if msg.command == 'CONNECTED'
      @connected_callback.call(msg) unless @connected_callback.nil?
    elsif msg.command == 'MESSAGE'
      @message_callback.call(msg) unless @message_callback.nil?
    end
  end
end


EM.run do
  mqtt = EventMachine::MQTT::ClientConnection.connect(
    CONFIG['mqtt']['host'],
    CONFIG['mqtt']['port']
  )

  services.each_pair do |host,args|
    stomp = EM.connect(
      host, args['port'], StompClient
    )

    stomp.connected_callback do
      args['topics'].each do |topic|
        stomp.subscribe topic
      end
    end

    stomp.message_callback do |msg|
      topic = msg.header['destination'].sub(%r(^/topic/), 'radiovis/')
      body = msg.body.sub(/^([A-Z]+) /, '')
      mqtt.publish(topic, body, retain=true)
    end
  end
end
