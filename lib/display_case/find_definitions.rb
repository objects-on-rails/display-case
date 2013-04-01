module DisplayCase

  def self.find_definitions
    absolute_definition_file_paths = configuration.definition_file_paths.map {|path| File.expand_path(path) }

    absolute_definition_file_paths.uniq.each do |path|
      require("#{path}.rb") if File.exists?("#{path}.rb")

      if File.directory? path
        Dir[File.join(path, '**', '*.rb')].sort.each do |file|
          require file
        end
      end
    end
  end
end
