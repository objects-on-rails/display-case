module DisplayCase
  class IsAClassComparator
    def call(object, *classes)
      classes.any?{|klass| object.is_a?(class_object(klass))}
    end

    private
    
    # A simple memoizing class name tracker
    class ClassTracker
      def initialize
        @context = Object
        @data = Hash.new {|h, k| h[k] = constantize(k)}
      end

      def class_for(class_name)
        @data[class_name]
      end
      
      def constantize(class_name)
        return class_name if Module === class_name
        class_name.to_s.split('::').inject(@context){|context, name|
          context.const_get(name)
        }
      end
    end

    # holds a reference to the tracker
    def class_tracker
      @class_tracker ||= ClassTracker.new
    end

    # helper method for object_is_any_of to use
    def class_object(cls)
      class_tracker.class_for(cls)
    end
  end
end
