# frozen_string_literal: true

module Speeders
  class Road
    attr_reader :length, :lights, :curves

    def initialize
      @length = Speeders.config.road_length
      @lights = generate_lights
      @curves = generate_curves
    end

    def generate_lights
      generator = LightGenerator.new
      generator.lights
    end

    def generate_curves
      # To be completed
    end
  end
end
