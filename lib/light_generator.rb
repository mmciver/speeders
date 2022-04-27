# frozen_string_literal: true

module Speeders
  class LightGenerator
    attr_reader :num_lights, :light_spacing, :lights

    def initialize
      @num_lights = Speeders.config.num_lights
      @light_spacing = Speeders.config.light_spacing
      @lights = create_lights
      assign_locations
      assign_priority
    end

    def create_lights
      num_lights.times.to_a.map do |index|
        Speeders::Light.new(index)
      end
    end

    def assign_priority
      available = light_priority_array
      lights.each do |light|
        light.priority = available.shuffle.first
        light.cycles = PRIORITY_CYCLES.fetch(light.priority)
      end
    end

    def light_priority_array
      Speeders.config.light_priority.map do |type, odds|
        Array.new(odds, type)
      end.flatten
    end

    def assign_locations
      locations = light_locations.sort
      lights.each_with_index do |light, index|
        light.location = locations[index]
      end
    end

    def light_locations
      case light_spacing
      when :equal
        equal_light_locations
      when :random
        random_light_locations
      else
        raise("Unknown spacing: #{light_spacing}")
      end
    end

    def equal_light_locations
      gap_number = lights.count + 1
      gap_size = Speeders.config.road_length / gap_number
      ary = Array.new(lights.count)
      ary.each_with_index.map do |light, index|
        (index + 1) * Speeders.config.min_light_gap
      end
    end

    def random_light_locations
      min_gap = Speeders.config.min_light_gap
      earliest = min_gap
      latest = Speeders.config.road_length - min_gap
      ary = (earliest..latest).step(min_gap).to_a
      take = ary.shuffle[1..num_lights]
    end

    def assign_lights(locations)
      lights.each_with_index do |light, index|
        light.location = locations[index]
      end
    end

    PRIORITY_CYCLES = {
      equal: { green: 50.0,  yellow: 5.0, red: 50.0 },
      favorable: { green: 70.0,  yellow: 5.0, red: 30.0 },
      unfavorable: { green: 30.0,  yellow: 5.0, red: 70.0 }
    }
  end
end
