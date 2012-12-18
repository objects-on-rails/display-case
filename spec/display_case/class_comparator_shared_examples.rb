module DisplayCase
  shared_examples_for 'a class comparator' do
    it 'identifies when an object is of a given class' do
      object = TestClass.new
      comparator.call(object, TestClass).should be_true
    end

    it 'identifies when an object is not of a given class' do
      object = OtherTestClass.new
      comparator.call(object, TestClass).should be_false
    end

    it 'identifies when an object is of any of a list classes' do
      object = OtherTestClass.new
      comparator.call(object, TestClass, OtherTestClass).should be_true
    end

    it 'identifies when an object is of a class including a given module' do
      object = TestClassIncludingModule.new
      comparator.call(object, TestClassIncludingModule).should be_true
    end

    it 'identifies objects when classes are given as names' do
      object = TestClass.new
      comparator.call(object, 'DisplayCase::TestClass').should be_true
      comparator.call(object, 'DisplayCase::OtherTestClass').should be_false
    end

    it 'identifies objects when classes are given as symbols' do
      object = TestClass.new
      comparator.call(object, :'DisplayCase::TestClass').should be_true
      comparator.call(object, :'DisplayCase::OtherTestClass').should be_false
    end

    class TestClass
    end

    class OtherTestClass
    end

    module TestModule
    end

    class TestClassIncludingModule
      include TestModule
    end
  end
end
