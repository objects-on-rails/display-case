require_relative '../spec_helper_lite'
require_relative '../../lib/display_case'
require 'ostruct'

describe DisplayCase::Exhibit do
  let(:model) { stub }

  it "should handle several exhibits" do
    first_exhibit = new_exhibit
    second_exhibit = new_exhibit

    exhibited = DisplayCase::Exhibit.exhibit(model)
    exhibited.exhibit_chain.must_include first_exhibit
    exhibited.exhibit_chain.must_include second_exhibit
  end

  it "should correctly send #render messages to exhibits" do
    context = stub!
    first_exhibit = new_exhibit
    second_exhibit = new_exhibit

    mock.instance_of(first_exhibit).render.with_any_args

    exhibited = DisplayCase::Exhibit.exhibit(model)
    exhibited.render(context)
  end

  private
  def new_exhibit
    Class.new(DisplayCase::Exhibit) { def self.applicable_to?(*args); true; end }
  end
end
