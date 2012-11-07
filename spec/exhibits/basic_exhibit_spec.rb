require_relative '../spec_helper_lite'
require_relative '../../lib/display_case'

describe DisplayCase::BasicExhibit do
  subject { DisplayCase::BasicExhibit.new(model, context) }
  let(:model) { ["e1", "e2", "e3"] }
  let(:context) { Object.new }

  describe '#to_partial_path' do
    it 'delegates to the model if it has the method' do
      stub(model).to_partial_path{ "MODEL_PARTIAL_PATH" }
      subject.to_partial_path.must_equal("MODEL_PARTIAL_PATH")
    end

    it 'uses munged model class name if it cannot delegate' do
      stub(my_class = Object.new).name{ "MyModule::MyClass" }
      stub(model).class{ my_class }
      subject.to_partial_path.must_equal('/my_module/my_classes/my_class')
    end

    it "should be called from basic exhibit by default" do
      stub(model).to_partial_path{ "MODEL_PARTIAL_PATH" }

      exhibited = DisplayCase::Exhibit.exhibit(model)
      exhibited.to_partial_path.must_equal("MODEL_PARTIAL_PATH")
    end
  end
end

