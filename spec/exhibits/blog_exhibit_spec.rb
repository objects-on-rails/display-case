require_relative '../spec_helper_lite'
require_relative '../fixtures/exhibits/blog_exhibit'

describe BlogExhibit do
  subject        { BlogExhibit.new(blog, context) }
  let(:blog)     { OpenStruct.new(:tags => tags) }
  let(:tags)     { Object.new }
  let(:context)  { Object.new }

  it 'exhibits its tags' do
    exhibited_tags = Object.new
    mock(subject).exhibit(tags) { exhibited_tags }
    subject.tags.must_be_same_as(exhibited_tags)
  end

  describe '#filter_by_tag' do
    it 'exhibits the result' do
      exhibited_blog = Object.new
      filtered_blog  = Object.new
      mock(blog).filter_by_tag("foo") { filtered_blog }
      mock(subject).exhibit(filtered_blog) { exhibited_blog }
      subject.filter_by_tag("foo").must_be_same_as(exhibited_blog)

    end
  end
end
