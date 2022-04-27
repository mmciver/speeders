# frozen_string_literal: true

require 'yaml'

module Speeders
  class Config
    attr_reader :time_interval, :road_length, :speed_limit, :num_lights, :min_light_gap,
      :light_spacing, :num_curves, :curve_length, :min_curve_recommended_speed,
      :max_curve_recommended_speed, :drivers, :light_priority

    def initialize
      opts = YAML.load(IO.read('config/config.yaml'))
      opts.each do |key, value|
        instance_variable_set("@#{key}",value)
      end
    end
  end
end
