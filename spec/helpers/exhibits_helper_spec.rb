require_relative '../spec_helper_lite'
stub_class 'Exhibit'
require_relative '../../lib/display_case/exhibits_helper'

describe ExhibitsHelper do
  before do
    @it = Object.new
    @it.extend ExhibitsHelper
    @context = stub!
  end

  it "delegates exhibition decisions to Exhibit" do
    model = Object.new
    mock(::Exhibit).exhibit(model, @context)
    @it.exhibit(model, @context)
  end
end
