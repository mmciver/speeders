# frozen_string_literal: true

require 'pry'

require_relative 'lib/config'
require_relative 'lib/curve'
require_relative 'lib/light'
require_relative 'lib/light_generator'
require_relative 'lib/road'
require_relative 'lib/simulator'
require_relative 'lib/vehicle'

module Speeders
  # Modify options for the simulator in config.yaml
  def self.config
    @config ||= Config.new
  end

  def self.simulator
    @simulator ||= Speeders::Simulator.new
  end

  def self.time
    simulator.time
  end
end

Speeders.simulator.run

# https://www.sciencedirect.com/science/article/pii/S2352146517307937
