require_relative '../spec_helper_lite'
require_relative '../fixtures/models/blog'
require 'ostruct'

describe Blog do
  subject       { Blog.new(->{entries}) }
  let(:entries) { [] }

  it "has no entries" do
    subject.entries.must_be_empty
  end

  describe "#new_entry" do
    let(:new_post) { OpenStruct.new }

    before do
      subject.post_source = ->{ new_post }
    end

    it "returns a new post" do
      subject.new_post.must_equal new_post
    end

    it "sets the post's blog reference to itself" do
      subject.new_post.blog.must_equal(subject)
    end

    it "accepts an attribute hash on behalf of the post maker" do
      post_source = MiniTest::Mock.new
      post_source.expect(:call, new_post, [{:x => 42, :y => 'z'}])
      subject.post_source = post_source
      subject.new_post(:x => 42, :y => 'z')
      post_source.verify
    end
  end

  describe "#add_entry" do
    it "adds the entry to the blog" do
      entry = stub!
      mock(entry).save
      subject.add_entry(entry)
    end
  end

  describe "#tags" do
    it "delegates to the entry collection's #all_tags_alphabetical" do
      tags = stub!
      stub(entries).all_tags_alphabetical{tags}
      subject.tags.must_equal(tags)
    end
  end

  describe "#filter_by_tag" do
    it "returns a blog whose entries are filtered by the given tag" do
      filtered_entries = stub
      mock(entries).tagged("foo"){ filtered_entries }
      subject.filter_by_tag("foo").entries.must_equal filtered_entries
    end
  end
end
