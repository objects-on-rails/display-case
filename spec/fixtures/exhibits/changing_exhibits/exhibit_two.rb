
class ExhibitTwo < DisplayCase::Exhibit
  def self.applicable_to?(*args); true; end
  def dont_change_this
    "unchanged"
  end
end