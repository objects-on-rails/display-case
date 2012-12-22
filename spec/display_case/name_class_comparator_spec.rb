require_relative '../../lib/display_case/name_class_comparator'
require_relative 'class_comparator_shared_examples'

module DisplayCase
  describe NameClassComparator do
    let(:comparator) { NameClassComparator.new }

    it_should_behave_like 'a class comparator'
  end
end
