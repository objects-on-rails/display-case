require_relative 'post_exhibit'

class PicturePostExhibit < PostExhibit
  def self.applicable_to?(object, context=nil)
    super && object.picture?
  end

  def render_body(template)
    template.render(partial: "/posts/picture_body", locals: {post: self})
  end
end
