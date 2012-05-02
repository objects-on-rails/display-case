require_relative '../spec_helper_nulldb'
require_relative '../fixtures/models/post'

describe Post do
  include SpecHelpers
  before do
    setup_nulldb
    @it = Post.new(:title => "TITLE")
    @ar = @it
    @ar_class = Post
  end

  after do
    teardown_nulldb
  end

  it "supports reading and writing a blog reference" do
    blog = Object.new
    @it.blog = blog
    @it.blog.must_equal blog
  end

  describe "#publish" do
    before do
      @blog = stub!
      @it.blog = @blog
      stub(@ar).valid?{true}
    end

    it "adds the post to the blog" do
      mock(@blog).add_entry(@it)
      @it.publish
    end

    it "returns truthy on success" do
      assert(@it.publish)
    end

    describe "given an invalid post" do
      before do
        stub(@ar).valid?{false}
      end

      it "wont add the post to the blog" do
        dont_allow(@blog).add_entry
        @it.publish
      end

      it "returns false" do
        refute(@it.publish)
      end
    end
  end

  describe "#pubdate" do
    describe "before publishing" do
      it "is blank" do
        @it.pubdate.must_be_nil
      end
    end

    describe "after publishing" do
      before do
        @clock = stub!
        @now = DateTime.parse("2011-09-11T02:56")
        stub(@clock).now(){@now}
        @it.blog = stub!
        @it.publish(@clock)
      end

      it "is a datetime" do
        assert(@it.pubdate.is_a?(DateTime) ||
               @it.pubdate.is_a?(ActiveSupport::TimeWithZone),
               "pubdate must be a datetime of some kind")
      end

      it "is the current time" do
        @it.pubdate.must_equal(@now)
      end

    end
  end

  describe "#picture?" do
    it "is true when the post has a picture URL" do
      @it.image_url = "http://example.org/foo.png"
      assert(@it.picture?)
    end

    it "is false when the post has no picture URL" do
      @it.image_url = ""
      refute(@it.picture?)
    end
  end
end
