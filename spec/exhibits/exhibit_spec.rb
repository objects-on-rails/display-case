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

  it 'reports its type as if it was the original object' do
    subject.class.must_equal model.class
    subject.must_be_kind_of model.class #wtf -> why does this pass?
    assert subject.kind_of?(model.class), "The subject class (#{subject.class}) is not kind_of? the model class (#{model.class})."
    assert subject.is_a?(model.class), "The subject class (#{subject.class}) is not is_a? the model class (#{model.class})."
    assert subject.instance_of?(model.class), "The subject class (#{subject.class}) is not an instance_of? the model class (#{model.class})."
  end
  
  it 'reports its real type if you ask it' do 
    subject.__class__.must_equal exhibit_class
    assert !subject.__kind_of__?(model.class), "The subject should not __kind_of be the model."
    assert !subject.__is_a__?(model.class), "The subject should not __is_a be the model."
    assert !subject.__instance_of__?(model.class), "The subject should not be __instance_of the model."
  end
  
  it 'eses the same class comparator across subclasses of Exhibit' do
    class StringExhibit < DisplayCase::Exhibit; end;
    assert exhibit_class.class_comparator.object_id == StringExhibit.class_comparator.object_id
  end

  it "#render'ing uses the models partial path and passes self" do
    class TestPartialExhibit < DisplayCase::Exhibit
      def self.applicable_to?(*)
        true
      end

      def to_partial_path
        'a partial'
      end
    end

    result = DisplayCase::Exhibit.exhibit(model, context)
    template = Object.new

    mock(template).render(:partial => 'a partial', :object => result) { :rendered_result }

    result.render(template).must_equal :rendered_result
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
    it 'calls Exhibit.exhibit with current context and model' do
      result      = Object.new
      other_model = Object.new
      mock(DisplayCase::Exhibit).exhibit(other_model, context){ result }
      subject.exhibit(other_model).must_be_same_as(result)
    end

    it 'works when passed a context instance of an anonymous class' do
      anonymous   = Class.new.new
      result      = DisplayCase::Exhibit.exhibit(model, anonymous)
      DisplayCase::Exhibit.exhibited_object?(result).must_equal true
    end
  end
end
