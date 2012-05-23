require_relative '../spec_helper_lite'
stub_class 'DisplayCase::Exhibit'
require_relative '../../lib/display_case'

describe DisplayCase::ExhibitsHelper do
  before do
    @it = Object.new
    @it.extend DisplayCase::ExhibitsHelper
    @context = stub!
  end

  it "delegates exhibition decisions to Exhibit" do
    model = Object.new
    mock(::DisplayCase::Exhibit).exhibit(model, @context)
    @it.exhibit(model, @context)
  end
end
