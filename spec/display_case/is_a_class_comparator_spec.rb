require_relative '../../lib/display_case/is_a_class_comparator'
require_relative 'class_comparator_shared_examples'

module DisplayCase
  describe IsAClassComparator do
    let(:comparator) { IsAClassComparator.new }
    it_behaves_like 'a class comparator'
  end
end
