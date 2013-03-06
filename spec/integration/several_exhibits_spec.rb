require_relative '../spec_helper_lite'
require_relative '../../lib/display_case'
require 'ostruct'

describe "several exhibits" do
  let(:model) { stub }
  let(:first_exhibit) { new_exhibit }
  let(:second_exhibit) { new_exhibit }

  before do
    @exhibits = [first_exhibit, second_exhibit]
    stub(DisplayCase::Exhibit).exhibits { @exhibits }
    @exhibited = DisplayCase::Exhibit.exhibit(model)
  end

  it "exhibited should include defined exhibits" do
    @exhibited.exhibit_chain.must_include first_exhibit
    @exhibited.exhibit_chain.must_include second_exhibit
  end

  it "should correctly send #render messages to exhibits" do
    mock.instance_of(first_exhibit).render.with_any_args
    context = stub!

    @exhibited.render(context)
  end

  it "should apply Basic Exhibit by default" do
    @exhibited.exhibit_chain.must_include DisplayCase::BasicExhibit
  end

  it "should favor Exhibits with a similar name to the context" do
    TestCaseExhibit = new_exhibit
    stub(DisplayCase::Exhibit).exhibits { [TestCaseExhibit] + @exhibits }
    smart_exhibited = DisplayCase::Exhibit.exhibit(model, Struct.new("TestCaseController").new)
    smart_exhibited.exhibit_chain.first.name.must_equal "TestCaseExhibit"
  end

  private
  def new_exhibit
    Class.new(DisplayCase::Exhibit) { def self.applicable_to?(*args); true; end }
  end
end
