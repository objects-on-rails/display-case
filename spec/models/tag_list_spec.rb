require 'ostruct'
require_relative '../spec_helper_lite'
require_relative '../fixtures/models/tag_list'

describe TagList do
  include Conversions

  describe "given a blank string" do
    before do
      @it = TagList.new("")
    end

    it "is empty" do
      @it.must_be_empty
    end

    it "stringifies to the empty string" do
      @it.to_s.must_equal ""
    end

    it "arrayifies to the empty array" do
      @it.to_a.must_equal []
    end
  end

  describe "given tags separated by commas or whitespace" do
    before do
      @it = TagList.new("barley, hops water, yeast")
    end

    it "is not empty" do
      @it.wont_be_empty
    end

    it "stringifies to a comma separated list" do
      @it.to_s.must_equal "barley, hops, water, yeast"
    end

    it "arrayifies to a list of strings" do
      @it.to_a.must_equal %w[barley hops water yeast]
    end
  end

  describe "given duplicate tags" do
    before do
      @it = TagList.new("barley, hops, barley")
    end

    it "eliminates duplicates" do
      @it.to_a.must_equal %w(barley hops)
    end
  end

  describe "given mixed-case tags" do
    before do
      @it = TagList.new("Barley, hOps, YEAST")
    end

    it "lowercases the tags" do
      @it.to_a.must_equal %w(barley hops yeast)
    end
  end

  describe "given duplicate mixed case tags" do
    before do
      @it = TagList.new("barley, hops, BarlEy")
    end

    it "eliminates duplicates ignoring case" do
      @it.to_a.must_equal %w(barley hops)
    end
  end

  describe "given nil" do
    before do
      @it = TagList.new(nil)
    end

    it "is empty" do
      @it.must_be_empty
    end
  end

  describe "#+" do
    it "combines tag lists into one" do
      result = TagList.new("foo, bar") + TagList.new("baz, buz")
      result.must_equal(TagList.new("foo, bar, baz, buz"))
    end
  end

  describe "#alphabetical" do
    before do
      @it = TagList.new("foo, bar, baz, fuz")
      @result = @it.alphabetical
    end

    it "returns the tags in alpha order" do
      @result.to_a.must_equal %w(bar baz foo fuz)
    end

    it "returns another tag list" do
      @result.must_be_kind_of TagList
      @result.wont_be_same_as @it
    end
  end

  describe "TagList()" do
    describe "given a TagList" do
      it "returns the same tag list" do
        list = TagList.new("")
        TagList(list).must_be_same_as(list)
      end
    end

    describe "given an array" do
      before do
        @it = TagList(%w[foo bar])
      end
      it "returns a tag list" do
        @it.must_be_kind_of(TagList)
      end

      it "contains the given tags" do
        @it.to_a.must_equal(%w[foo bar])
      end
    end
  end
end
