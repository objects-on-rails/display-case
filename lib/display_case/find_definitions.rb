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
    if File.exist?(file) && (@file_changes[file].to_i < (mtime = File.mtime(file).to_i))
      begin
        load file
        @file_changes[file] = mtime
      rescue TypeError => error
        klass = find_class_candidates(error.message).first # TODO: Is there a way to make this work correctly if there are multiple candidates?
        if klass.ancestors.include?(DisplayCase::Exhibit) && configuration.swallow_superclass_mismatch_for_exhibits?
          delimiter = '::'
          namespace, klass_name =
            if klass.name.index(delimiter)
              klass_names = klass.name.split(delimiter)
              namespace_name = klass_names[0..-2].join(delimiter).constantize
              klass_name = klass_names.last
              [namespace_name, klass_name]
            else
              [Object, klass.name]
            end
          namespace.send(:remove_const, klass_name.to_sym)
          retry
        else
          raise error
        end
      end
    end
  end

  def self.find_class_candidates(error_message)
    klass_name = error_message.gsub("superclass mismatch for class ", "")
    [klass_name.constantize]
  rescue NameError
    ObjectSpace.each_object(Class).select{|c| c.to_s.split('::').last == klass_name}
  end
end
