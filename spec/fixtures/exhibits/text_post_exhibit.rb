require_relative 'post_exhibit'
class TextPostExhibit < PostExhibit
  def self.applicable_to?(object)
    super && (!object.picture?)
  end

  def render_body(template)
    template.render(partial: "/posts/text_body", locals: {post: self})
  end
end
