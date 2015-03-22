module DisplayCase

  def self.find_definitions
    absolute_definition_file_paths = configuration.definition_file_paths.map {|path| File.expand_path(path) }

    absolute_definition_file_paths.uniq.each do |path|
      file = "#{path}.rb"
      display_case_load file

      if File.directory? path
        Dir[File.join(path, '**', '*.rb')].sort.each do |file|
          display_case_load file
        end
      end
    end
  end

  private
  def self.display_case_load(file)
    @file_changes ||= {}
    if File.exists?(file) && (@file_changes[file].to_i < (mtime = File.mtime(file).to_i))
      begin
        load file
        @file_changes[file] = mtime
      rescue TypeError
        klass = $!.message.gsub("superclass mismatch for class ", "").constantize
        if klass.ancestors.include?(DisplayCase::Exhibit)
          Object.send(:remove_const, klass.name.to_sym)
          retry
        else
          raise $!
        end
      end
    end
  end
end
