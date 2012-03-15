#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'em-mqtt'

STOMP_HOST = 'vis.musicradio.com'
MQTT_HOST = 'test.mosquitto.org'

module StompClient
  include EM::Protocols::Stomp

  def connection_completed
    connect
  end
  
  def message_callback(&block)
    @message_callback = block
  end

  def receive_msg msg
    if msg.command == "CONNECTED"
      subscribe '/topic/fm/ce1/c479/09580/image' # Capital FM
      subscribe '/topic/fm/ce1/c479/09580/text' # Capital FM
    elsif msg.command == "MESSAGE"
      @message_callback.call(msg) unless @message_callback.nil?
    end
  end
end

EM.run do
  mqtt = EventMachine::MQTT::ClientConnection.connect(MQTT_HOST)
  stomp = EM.connect(STOMP_HOST, 61613, StompClient)
  
  stomp.message_callback do |msg|
    topic = msg.header['destination'].sub(%r(^/topic/), 'radiovis/')
    body = msg.body.sub(/^([A-Z]+) /, '')
    p [topic, body]
    mqtt.publish(topic, body, retain=true)
  end  
end
