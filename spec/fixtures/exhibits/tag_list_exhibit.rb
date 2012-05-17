require_relative '../../../lib/display_case'

class TagListExhibit < Exhibit
  def self.applicable_to?(object)
    object_is_any_of?(object, 'TagList')
  end
end
