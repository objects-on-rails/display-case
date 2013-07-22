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

    # A cache store which responds to `fetch(key, options, &block)`
    attr_accessor :cache_store

    # A boolean indicating whether or not to log to the Rails logger
    attr_accessor :logging_enabled

    # A boolean indicating whether Exhibits with names that are similar to
    # context should be favored over other exhibits. By default, this is true
    attr_accessor :smart_matching

    def initialize
      @definition_file_paths = %w(app/exhibits)
      @explicit = false
      @exhibits = []
      @cache_store = nil
      @logging_enabled = false
      @smart_matching = true
    end

    def explicit?
      explicit
    end

    def smart_matching?
      smart_matching
    end

    def logging_enabled?
      defined? ::Rails and logging_enabled
    end

    def exhibits
      [DisplayCase::Exhibit::Exhibited,DisplayCase::BasicExhibit,DisplayCase::EnumerableExhibit] + @exhibits
    end

    def exhibits=(val)
      @exhibits = Array(val)
    end
  end

  configure {}
end
