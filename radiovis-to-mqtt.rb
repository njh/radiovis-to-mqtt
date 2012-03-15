#!/usr/bin/env ruby

require 'rubygems'
require "bundler"

Bundler.require(:default)

# Load the configuration file
CONFIG = YAML::load_file('config.yml')

# Make STDOUT unbuffered
STDOUT.sync = true

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
    if msg.command == "CONNECTED"
      @connected_callback.call(msg) unless @connected_callback.nil?
    elsif msg.command == "MESSAGE"
      @message_callback.call(msg) unless @message_callback.nil?
    end
  end
end


EM.run do
  mqtt = EventMachine::MQTT::ClientConnection.connect(
    CONFIG['mqtt']['host'],
    CONFIG['mqtt']['port']
  )
  stomp = EM.connect(
    CONFIG['radiovis']['host'],
    CONFIG['radiovis']['port'],
    StompClient
  )

  stomp.connected_callback do
    CONFIG['identifiers'].each do |identifier|
      stomp.subscribe "/topic/#{identifier}/image"
      stomp.subscribe "/topic/#{identifier}/text"
    end
  end

  stomp.message_callback do |msg|
    topic = msg.header['destination'].sub(%r(^/topic/), 'radiovis/')
    body = msg.body.sub(/^([A-Z]+) /, '')
    p [topic, body]
    mqtt.publish(topic, body, retain=true)
  end
end
