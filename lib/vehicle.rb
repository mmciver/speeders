# frozen_string_literal: true

module Speeders
  class Vehicle
    attr_reader :enabled, :max_speed, :acceleration_rate, :max_exceed_recommended,
        :deceleration_rate, :deceleration_time_factor, :risk_yellow_factor, :reaction_time,
        :light, :deceleration_square_divsor, :road, :name
    attr_accessor :speed, :location, :completion_time

    def initialize(driver_config, road)
      driver_config.each do |key, value|
        instance_variable_set("@#{key}",value)
      end
      @road = road
      @speed = 0 #m/s
      @location = 0 #meters
      @highest_speed = 0
      @time_stopped = 0.0
      @time_at_max_speed = 0.0
      @lights_stopped_at = []
    end

    def step
      if location >= road.length
        return :finished
      end
      @light = next_light
      if light.nil? || light_distance > braking_distance + 3 || light.state == :green
        accelerate!
      elsif light.state == :red
        brake!
      elsif light.state == :yellow
        if beat_yellow?(light)
          accelerate!
        else
          brake!
        end
      end
    end

    def accelerate!
      @doing = 'A'
      new_speed = speed + (acceleration_rate * Speeders.config.time_interval).round(3)
      new_speed = max_speed if new_speed > max_speed
      update_speed_location(new_speed)
    end

    def brake!
      @doing = 'B'
      new_speed = speed - (deceleration_rate * Speeders.config.time_interval).round(3)
      new_speed = 0 if new_speed < 0
      update_speed_location(new_speed)
    end

    def update_speed_location(new_speed)
      avg_speed = ((speed + new_speed) / 2).round(3)
      traveled = (avg_speed * Speeders.config.time_interval).round(3)
      @speed = [new_speed, 0].max
      @highest_speed = [@speed, @highest_speed].max
      if @speed == @max_speed
        @time_at_max_speed = (@time_at_max_speed + Speeders.config.time_interval).round(1)
      end
      if @speed == 0
        @lights_stopped_at |= [light.id]
        @time_stopped = (@time_stopped + Speeders.config.time_interval).round(1)
      end
      @location += traveled
      if @location >= road.length
        report_completion
      end
    end

    def report_completion
      res = {
        name: name,
        time: seconds_to_minutes(Speeders.time),
        avg_kph: (road.length / Speeders.time * 3.6).round(1),
        max_kph: (@highest_speed * 3.6).round(1),
        accel_rate: acceleration_rate,
        time_at_max: seconds_to_minutes(@time_at_max_speed),
        time_stopped: seconds_to_minutes(@time_stopped),
        num_lights_hit: @lights_stopped_at.length
      }
      puts res.to_yaml
    end

    def seconds_to_minutes(sec)
      return "#{sec.round.to_s}s" if sec < 60
      m = (sec / 60).floor
      s = sec.round - (m * 60)
      "#{m}m #{s}s"
    end

    def braking_distance
      (speed * speed / deceleration_square_divsor).round(3)
    end

    def light_distance
      (light.location - location).round(1)
    end

    def beat_yellow?(light)
      (time_to_light(light) + reaction_time ) < light.elapsed_cycle
    end

    def next_light
      road.lights.select do |light|
        light.location > location
      end.first
    end

    def time_to_light(light)
      distance = light.location - location
      distance / speed
    end
  end
end
