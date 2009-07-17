#!/usr/bin/ruby

require 'rubygems'
require 'tinder'
require 'Hal'

class Halfire

  def initialize
    @campfire = Tinder::Campfire.new ENV['HALFIRE_DOMAIN']
  end

  def get_room
    @campfire.login ENV['HALFIRE_USER'], ENV['HALFIRE_PASSWORD']
    @campfire.find_room_by_name ENV['HALFIRE_ROOM']
  end

  def run
    hal = Hal.new
    hal.initbrain

    count = 0
    begin
      room = get_room
      room.listen do |m|
        body = m[:message].to_s.gsub(/^[Hh]al[,:] /, '')
        hal.learn body

        if body.length != m[:message].length
          room.speak(hal.doreply(body))
        end

        count += 1
        if count%10 == 0
          hal.cleanup
        end
      end
    rescue
      puts "Something bad happened: #{$!}"
      retry
    end

    @campfire.logout
  end
end

hf = Halfire.new
hf.run
