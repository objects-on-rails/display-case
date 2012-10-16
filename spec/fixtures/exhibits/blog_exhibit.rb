require_relative '../../../lib/display_case'

class BlogExhibit < DisplayCase::Exhibit
  def self.applicable_to?(object, context=nil)
    object_is_any_of?(object, 'Blog', 'Blog::FilteredBlog')
  end

  exhibit_query :tags, :filter_by_tag, :entries
end
