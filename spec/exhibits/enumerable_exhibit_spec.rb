require_relative '../spec_helper_lite'
require_relative '../../lib/display_case'

describe DisplayCase::EnumerableExhibit do
  describe "class" do
    subject { DisplayCase::EnumerableExhibit }

    it "is applicable to Enumerables" do
      assert subject.applicable_to?([])
      assert subject.applicable_to?({})
    end

    it "is inapplicable to singular objects" do
      refute subject.applicable_to?(Object.new)
    end

    it "is itself enumerable" do
      assert (subject < Enumerable)
    end
  end

  subject { DisplayCase::EnumerableExhibit.new(model, context) }
  let(:model) { ["e1", "e2", "e3"] }
  let(:context) { Object.new }

  before do
    # #exhibit is part of the superclass interface, not this class'
    # interface, so it is fair game for stubbing
    stub(subject).exhibit {|model|
      @last_exhibited = model
      "exhibit(#{model})"
    }
  end

  describe "#each" do
    it "exhibits each element" do
      results = []
      subject.each do |e| results << e end
      results.must_equal(["exhibit(e1)", "exhibit(e2)", "exhibit(e3)"])
    end

    it "returns enumerator" do
      subject.each.must_be_instance_of(Enumerator)
    end

    it "chains with_index" do
      results = []
      subject.each.with_index do |*e| results << e end
      results.must_equal([
                          ["exhibit(e1)", 0],
                          ["exhibit(e2)", 1],
                          ["exhibit(e3)", 2]])
    end
  end

  describe "#each_with_index" do
    it "exhibits each element" do
      results = []
      subject.each_with_index do |*e| results << e end
      results.must_equal([
                          ["exhibit(e1)", 0],
                          ["exhibit(e2)", 1],
                          ["exhibit(e3)", 2]])
    end
  end

  describe "#to_enum" do
    it "returns an exhibited enumerator" do
      subject.to_enum
      @last_exhibited.to_a.must_equal(model)
    end
  end

  describe "#to_ary" do
    it "returns itself" do
      assert(subject.equal?(subject.to_ary))
    end
  end
  
  describe "#to_json" do 
    it "returns #as_json from elements in its collection" do
      subject.to_json.must_equal('["exhibit(e1)","exhibit(e2)","exhibit(e3)"]')
      with_custom_as_json = subject.map.with_index{|m, i| m.define_singleton_method(:as_json){|opts={}| i }; m }
      with_custom_as_json.to_json.must_equal("[0,1,2]")
    end
  end

  describe "#grep" do
    it "exhibits the result set" do
      subject.grep(/[12]/).must_equal('exhibit(["e1", "e2"])')
    end
  end

  describe "#select" do
    it "exhibits each result" do
      subject.select{|e| /[23]/ === e}.must_equal('exhibit(["e2", "e3"])')
    end
  end

  describe "#detect" do
    it "exhibits the result" do
      subject.detect{|e| /[23]/ === e}.
        must_equal("exhibit(e2)")
    end
  end

  describe "#[]" do
    it "exhibits the result" do
      subject[1].must_equal("exhibit(e2)")
    end
  end

  describe "#fetch" do
    it "exhibits the result" do
      subject.fetch(1).must_equal("exhibit(e2)")
    end
  end

  describe "#first" do
    it "exhibits the result" do
      subject.first.must_equal("exhibit(e1)")
    end
  end

  describe "#last" do
    it "exhibits the result" do
      subject.last.must_equal("exhibit(e3)")
    end
  end

  describe "#min" do
    it "exhibits the result" do
      subject.min.must_equal("exhibit(e1)")
    end
  end

  describe "#max" do
    it "exhibits the result" do
      subject.max.must_equal("exhibit(e3)")
    end
  end

  describe "#minmax" do
    it "exhibits the result" do
      subject.minmax.must_equal(["exhibit(e1)", "exhibit(e3)"])
    end
  end

  describe "#sort" do
    it "exhibits the result" do
      subject.sort{|x,y| y <=> x}.must_equal('exhibit(["e3", "e2", "e1"])')
    end
  end

  describe "#sort_by" do
    it "exhibits the result" do
      subject.sort_by(&:to_s).must_equal('exhibit(["e1", "e2", "e3"])')
    end
    it "returns an enumerator without arguments" do
      subject.sort_by.must_match(/Enumerator/)
    end
  end

  describe "#reverse" do
    it "exhibits the result" do
      subject.reverse.must_equal('exhibit(["e3", "e2", "e1"])')
    end
  end

  describe "#slice" do
    it "exhibits the result" do
      subject.slice(1,2).must_equal('exhibit(["e2", "e3"])')
    end
  end

  describe "#values_at" do
    it "exhibits the result" do
      subject.values_at(0,2).must_equal('exhibit(["e1", "e3"])')
    end
  end

  describe "#reject" do
    it "exhibits the result" do
      subject.reject{|e| e =~ /2/}.must_equal('exhibit(["e1", "e3"])')
    end
    it "returns an enumerator without arguments" do
      subject.reject.must_match(/Enumerator/)
    end
  end

  describe "#partition" do
    it "exhibits the result" do
      subject.partition{|e| e < "e2"}.
        must_equal(['exhibit(["e1"])', 'exhibit(["e2", "e3"])'])
    end
  end

  describe "#group_by" do
    it "exhibits the result" do
      subject.group_by{|e| e == "e2"}.
        must_equal({ true  => 'exhibit(["e2"])',
                     false => 'exhibit(["e1", "e3"])'})
    end
  end

  describe "#render" do
    let(:template) { Object.new }

    before do
      stub(subject).exhibit{|object| object}
      model.each do |e|
        stub(e).render{ "R(#{e})" }
      end
    end
    it "concatenates the rendered elements" do
      subject.render(template).must_equal("R(e1)R(e2)R(e3)")
    end
    it "produces a safe string" do
      assert(subject.render(template).html_safe?)
    end
  end

end
