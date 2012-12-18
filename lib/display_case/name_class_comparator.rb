module DisplayCase
  # What with Rails development mode reloading making class matching
  # unreliable, plus wanting to avoid adding dependencies to external
  # class definitions if we can avoid it, this class just matches
  # against class/module name strings rather than the actual class
  # objects.
  class NameClassComparator
    def call(object, *classes)
      # Note that '&' is the set intersection operator for Arrays.
      (classes.map(&:to_s) & object.class.ancestors.map(&:name)).any?
    end
  end
end
