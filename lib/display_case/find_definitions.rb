module DisplayCase
  class << self
    # An Array of strings specifying locations that should be searched for
    # exhibit classes and definitions. By default, "/app/exhibits" will be searched and
    # existing file will be loaded.
    attr_accessor :definition_file_paths
  end

  self.definition_file_paths = %w(app/exhibits)

  def self.find_definitions
    absolute_definition_file_paths = definition_file_paths.map {|path| File.expand_path(path) }

    absolute_definition_file_paths.uniq.each do |path|
      load("#{path}.rb") if File.exists?("#{path}.rb")

      if File.directory? path
        Dir[File.join(path, '**', '*.rb')].sort.each do |file|
          load file
        end
      end
    end
  end
end
