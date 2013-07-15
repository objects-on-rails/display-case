module DisplayCase
  # What with Rails development mode reloading making class matching
  # unreliable, plus wanting to avoid adding dependencies to external
  # class definitions if we can avoid it, this class just matches
  # against class/module name strings rather than the actual class
  # objects.
  class NameClassComparator
    def call(object, *classes)
      # Note that '&' is the set intersection operator for Arrays.
      (classes.map(&:to_s) & object.class.ancestors.map {|c| name_for(c)}).any?
    end

    private
    class ClassNameTracker
      def initialize
        @data = Hash.new {|h, k| h[k] = k.name}
      end

      def name_for(kls)
        @data[kls]
      end
    end

    def class_name_tracker
      @class_name_tracker ||= ClassNameTracker.new
    end

    def name_for(cls)
      class_name_tracker.name_for(cls)
    end
  end
end
