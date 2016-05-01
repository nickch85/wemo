require 'rest-client'
require 'crack'
require 'builder'


module WeMo
  class Light
    attr_reader :name, :id, :state

    def initialize(name, id, state)
      @name = name
      @id = id
      @state = state
    end

  end
end
