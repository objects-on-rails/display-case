module Namespaced
  class ExhibitThree < ExhibitFour
    def self.applicable_to?(*args); true; end
    def change_this
      "unchanged"
    end
  end
end