require_relative './exhibit_two'
class ExhibitOne < ExhibitTwo
  def self.applicable_to?(*args); true; end
  def change_this
    "unchanged"
  end
end
