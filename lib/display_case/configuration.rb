require_relative 'enumerable_exhibit'

module DisplayCase
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :explicit

    def initialize
      @explicit = false
      @exhibits = []
    end

    def explicit?
      explicit
    end

    def exhibits
      [DisplayCase::Exhibit::Exhibited,DisplayCase::EnumerableExhibit] + @exhibits
    end

    def exhibits=(val)
      @exhibits = Array(val)
    end
  end

  configure {}
end