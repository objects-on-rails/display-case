class NilExhibit < DisplayCase::Exhibit
  def self.applicable_to?(object, context=nil)
    object.class.name == 'String' || object.nil?
  end

  def name
    if __getobj__.nil?
      return "I am nil!"
    else
      return "I am not nil!"
    end
  end
end
