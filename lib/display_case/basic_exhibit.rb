require_relative 'exhibit'

module DisplayCase
  class BasicExhibit < Exhibit
    def to_partial_path
      if __getobj__.respond_to?(:to_partial_path)
        __getobj__.to_partial_path.dup
      else
        partialize_name(__getobj__.class.name)
      end
    end
  end
end

