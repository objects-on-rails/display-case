require_relative "../spec_helper_lite.rb"
require_relative "../helpers/shared_specs_helper"

module DisplayCase
  shared_examples_for 'a class comparator' do
    describe "DisplayCase Class Comparators" do
      it 'identifies when an object is of a given class' do
        object = TestClass.new
        comparator.call(object, TestClass).must_equal true
      end

      it 'identifies when an object is not of a given class' do
        object = OtherTestClass.new
        comparator.call(object, TestClass).must_equal false
      end

      it 'identifies when an object is of any of a list classes' do
        object = OtherTestClass.new
        comparator.call(object, TestClass, OtherTestClass).must_equal true
      end

      it 'identifies when an object is of a class including a given module' do
        object = TestClassIncludingModule.new
        comparator.call(object, TestClassIncludingModule).must_equal true
      end

      it 'identifies objects when classes are given as names' do
        object = TestClass.new
        comparator.call(object, 'DisplayCase::TestClass').must_equal true
        comparator.call(object, 'DisplayCase::OtherTestClass').must_equal false
      end

      it 'identifies objects when classes are given as symbols' do
        object = TestClass.new
        comparator.call(object, :'DisplayCase::TestClass').must_equal true
        comparator.call(object, :'DisplayCase::OtherTestClass').must_equal false
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
end