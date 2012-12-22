# from https://gist.github.com/3113618
gem 'minitest'
require 'minitest/spec'
require 'minitest/autorun'

MiniTest::Spec.class_eval do
  def self.shared_examples
    @shared_examples ||= {}
  end
end
 
module MiniTest::Spec::SharedExamples
  def shared_examples_for(desc, &block)
    MiniTest::Spec.shared_examples[desc] = block
  end
 
  def it_behaves_like(desc)
    self.instance_eval do
      MiniTest::Spec.shared_examples[desc].call
    end
  end
end
 
Object.class_eval { include(MiniTest::Spec::SharedExamples) }