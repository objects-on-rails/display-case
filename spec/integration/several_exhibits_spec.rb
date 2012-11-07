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

  private
  def new_exhibit
    Class.new(DisplayCase::Exhibit) { def self.applicable_to?(*args); true; end }
  end
end
