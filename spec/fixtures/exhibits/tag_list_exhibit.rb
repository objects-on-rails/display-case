require_relative '../../../lib/display_case'

class TagListExhibit < DisplayCase::Exhibit
  def self.applicable_to?(object, context=nil)
    object_is_any_of?(object, 'TagList')
  end
end
