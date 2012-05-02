require_relative '../spec_helper_lite'
require_relative '../fixtures/models/taggable_record'

describe TaggableRecord do
  include Conversions

  class Item
    attr_writer :save_result
    def initialize(tags)
      @attributes = {:tags => tags}
    end

    def save; @save_result end

    def [](key)
      @attributes[key]
    end
  end

  before do
    @item        = Item.new("foo, bar, baz")
    @tag_storage = Object.new
    stub(@tag_storage).load{[]}
    @it          = @item.extend(TaggableRecord)
    stub(@item)._tag_storage{@tag_storage}
  end

  it "exposes the item's tags as a TagList" do
    stub(@tag_storage).load{%w[x y z]}
    @it.tags.must_equal TagList.new(%w[x y z])
  end

  it "intercepts successful save to store the array of current tags" do
    @it.tags = %[foo bar baz]
    @item.save_result = true
    mock(@tag_storage).store(%w[foo bar baz])
    @it.save
  end

  it "does not store tags on unsuccessful save" do
    @it.tags = %[foo bar baz]
    @item.save_result = false
    dont_allow(@tag_storage).store
    @it.save
  end

  it "intercepts #tags= to create a new TagList" do
    @it.tags = "fuz buz faz"
    @it.tags.must_equal TagList.new(%w[fuz buz faz])
  end

  it "loads tags using the tag storage" do
    @tag_storage = Object.new
    stub(@item)._tag_storage{@tag_storage}
    mock(@tag_storage).load{%w[a b c]}
    @it.tags.must_equal TagList.new(%w[a b c])
  end
end
