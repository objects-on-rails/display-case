require_relative '../spec_helper_lite'
require_relative '../fixtures/exhibits/link_exhibit'
require 'json'

describe LinkExhibit do
  before do
    @next = Object.new
    @prev = Object.new
    @up   = Object.new
    @model = Object.new
    stub(@model).next{ @next }
    stub(@model).prev{ @prev }
    stub(@model).up{ @up }
    stub(@model).serializable_hash{{model_data: "MODEL_DATA"}}
    @context = Object.new
    @it = LinkExhibit.new(@model, @context)
    stub(@context).url_for(@next){"URL_FOR_NEXT"}
    stub(@context).url_for(@prev){"URL_FOR_PREV"}
    stub(@context).url_for(@up){"URL_FOR_UP"}
  end

  it "constructs URLs for prev, next, and up" do
    @it.prev_url.must_equal "URL_FOR_PREV"
    @it.next_url.must_equal "URL_FOR_NEXT"
    @it.up_url.must_equal "URL_FOR_UP"
  end

  describe "#serializable_hash" do
    it "adds next, prev, and up URLs" do
      @it.serializable_hash["links"].
        must_include({"rel" => "up", "href" => "URL_FOR_UP"})
      @it.serializable_hash["links"].
        must_include({"rel" => "next", "href" => "URL_FOR_NEXT"})
      @it.serializable_hash["links"].
        must_include({"rel" => "prev", "href" => "URL_FOR_PREV"})
    end

    it "includes data from the model" do
      @it.serializable_hash[:model_data].must_equal "MODEL_DATA"
    end

    it "passes arguments to the model" do
      mock(@model).serializable_hash({:foo => "bar"}){{}}
      @it.serializable_hash({:foo => "bar"})
    end

  end

  describe "#to_json" do
    it "spits out the JSON version of the serializable hash" do
      @it.to_json.must_equal @it.serializable_hash.to_json
    end
  end
end
