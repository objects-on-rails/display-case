require_relative '../spec_helper_lite'
require_relative '../../lib/display_case'
require 'ostruct'

describe "ordering" do
  let(:model) { stub }
  let(:first_exhibit) { new_exhibit }
  let(:second_exhibit) { new_exhibit }

  before do
    @exhibits = [first_exhibit, second_exhibit]
  end
  
  it "should favor Exhibits with a similar name to the context" do
    TestCaseExhibit = new_exhibit
    SomeOtherExhibit = new_exhibit

    DisplayCase.configure do |config|
      config.explicit = false
    end

    stub(DisplayCase::Exhibit).exhibits { [TestCaseExhibit] + @exhibits + [SomeOtherExhibit] } # the last applied exhibit will be the topmost one, so we reverse the order here
    smart_exhibited = DisplayCase::Exhibit.exhibit(model, Struct.new("TestCaseController").new)
    smart_exhibited.exhibit_chain.first.must_equal TestCaseExhibit
  end

  it 'does not order according to context if explicit ordering is configured' do
    TestCase2Exhibit = new_exhibit
    SomeOther2Exhibit = new_exhibit

    DisplayCase.configure do |config|
      config.explicit = true
      config.exhibits = [TestCase2Exhibit, SomeOther2Exhibit] # the last applied exhibit will be the topmost one, so we reverse the order here
    end

    smart_exhibited = DisplayCase::Exhibit.exhibit(model, Struct.new("TestCase2Controller").new)
    smart_exhibited.exhibit_chain.first.must_equal SomeOther2Exhibit
  end

  private
  def new_exhibit
    Class.new(DisplayCase::Exhibit) do
      def self.applicable_to?(obj, ctx)
        true
      end
    end
  end
end