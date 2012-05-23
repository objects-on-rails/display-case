require_relative '../spec_helper_lite'
require_relative '../../lib/display_case'

describe DisplayCase::Exhibit do
  subject             { exhibit_class.new(model, context) }
  let(:exhibit_class) { Class.new(DisplayCase::Exhibit) }
  let(:model)         { Object.new }
  let(:context)       { Object.new }

  it 'registers child Exhibits when inherited' do
    class TestExhibit < DisplayCase::Exhibit; end
    DisplayCase::Exhibit.exhibits.include?(TestExhibit).must_equal true
  end

  describe '.exhibit_query' do
    it 'wraps the given methods so that their results are exhibited' do
      foo_result    = Object.new
      bar_result    = Object.new
      exhibited_foo = Object.new
      exhibited_bar = Object.new
      exhibit_class.module_eval do
        exhibit_query :foo, :bar
      end

      mock(model).foo { foo_result }
      mock(DisplayCase::Exhibit).exhibit(foo_result, context) { exhibited_foo }
      subject.foo.must_be_same_as(exhibited_foo)

      mock(model).bar(123,456) { bar_result }
      mock(DisplayCase::Exhibit).exhibit(bar_result, context) { exhibited_bar }
      subject.bar(123,456).must_be_same_as(exhibited_bar)
    end
  end

  describe '#exhibit' do
    it 'calls Exhibt.exhibit with current context and model' do
      result      = Object.new
      other_model = Object.new
      mock(DisplayCase::Exhibit).exhibit(other_model, context){ result }
      subject.exhibit(other_model).must_be_same_as(result)
    end
  end

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
  end
end
