module DisplayCase
  class IsAClassComparator
    def initialize
      @context = Object
    end

    def call(object, *classes)
      classes.map!{|klass| Module === klass ? klass : constantize(klass)}
      classes.any?{|klass| object.is_a?(klass)}
    end

    private

    def constantize(class_name)
      class_name.to_s.split('::').inject(@context){|context, name|
        context.const_get(name)
      }
    end
  end
end
