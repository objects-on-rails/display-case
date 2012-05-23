require_relative '../../../lib/display_case'
require_relative '../models/taggable'

class PostExhibit < DisplayCase::Exhibit
  include ::Conversions
  def self.applicable_to?(object)
    object_is_any_of?(object, 'Post')
  end

  def tags
    exhibit(Taggable(to_model).tags)
  end

  def to_partial_path
    "/posts/post"
  end
end
