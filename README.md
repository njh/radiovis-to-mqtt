radiovis-to-mqtt.rb
===================

This script looks up various [RadioVis] services, listed in the configuration file, using [RadioDNS] and relays the text and images to the [MQTT] server of your choice.

**Gem Dependencies**
- [radiodns-ruby] by [Chris Lowis]
- [EventMachine]
- [em-mqtt]
- [bundler]

The script is running live on [test.mosquitto.org]. If you download [mosquitto], you can subscribe to these messages using the command:

    mosquitto_sub -h test.mosquitto.org -t 'radiovis/#' -v

Comments to [@njh].


[RadioDNS]:           http://radiodns.org/
[RadioVis]:           http://en.wikipedia.org/wiki/RadioVIS
[radiodns-ruby]:      http://github.com/bbcrd/radiodns-ruby
[EventMachine]:       http://rubyeventmachine.com/
[Chris Lowis]:        http://twitter.com/chrislowis
[MQTT]:               http://mqtt.org/
[em-mqtt]:            http://github.com/njh/ruby-em-mqtt
[bundler]:            http://gembundler.com/
[test.mosquitto.org]: http://test.mosquitto.org/
[mosquitto]:          http://mosquitto.org/
[@njh]:               http://twitter.com/njh
