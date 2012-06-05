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
    # A boolean indicating whether the Exhibits will be explicitly listed in order or
    # dynamically collected with the inherited callback. By default, this is false
    # and the list will be generated via the inherited callback.
    attr_accessor :explicit
    
    # An Array of strings specifying locations that should be searched for
    # exhibit classes and definitions. By default, "/app/exhibits" will be searched and
    # existing file will be loaded.
    attr_accessor :definition_file_paths

    def initialize
      @definition_file_paths = %w(app/exhibits)
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