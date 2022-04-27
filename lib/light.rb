# frozen_string_literal: true

module Speeders
  class Light
    attr_reader :id
    attr_accessor :location, :priority, :cycles, :state, :elapsed_cycle

    def initialize(id)
      @id = id
    end

    def first_cycle
      @state = @cycles.keys.shuffle.first
      @elapsed_cycle = (0..cycles[@state]).to_a.shuffle.first
    end

    def step
      first_cycle if @state.nil?
      @elapsed_cycle = (@elapsed_cycle - Speeders.config.time_interval).round(1)
      if @elapsed_cycle <= 0
        next_state!
      end
    end

    def next_state!
      case @state
      when :red
        @state = :green
      when :yellow
        @state = :red
      when :green
        @state = :yellow
      end
      @elapsed_cycle = @cycles[state]
    end
  end
end
