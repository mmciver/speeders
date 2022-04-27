# frozen_string_literal: true

module Speeders
  class Simulator
    attr_accessor :time

    def initialize
      @time = 0.0
    end

    def road
      @road ||= Road.new
    end

    def vehicles
      @vehicles ||= Speeders.config.drivers.select do |name, config|
        config[:enabled]
      end.map do |name, config|
        [name, Vehicle.new(config, road)]
      end.to_h
    end

    def step
      @time = (@time + Speeders.config.time_interval).round(1)
      step_lights
      step_vehicles
    end

    def step_lights
      road.lights.each do |light|
        light.step
      end
    end

    def step_vehicles
      vehicles.each do |name, vehicle|
        vehicle.step
      end
    end

    def run
      while vehicle_locations.min < road.length
        step
      end
    end

    def vehicle_locations
      vehicles.values.map(&:location)
    end
  end
end
