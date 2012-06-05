require_relative '../spec_helper_lite'
require_relative '../../lib/display_case'
require_relative '../fixtures/exhibits/blog_exhibit'

module DisplayCase
  describe Exhibit do
    describe '#exhibits' do
      it 'should not include BlogExhibit when explicit and no exhibits given' do
        DisplayCase.configure do |config|
          config.explicit = true
        end
        refute_includes(Exhibit.exhibits,BlogExhibit)
      end

      it 'should include BlogExhibit when explicit and BlogExhibit listed' do
        DisplayCase.configure do |config|
          config.explicit = true
          config.exhibits = [BlogExhibit]
        end
        assert_includes(Exhibit.exhibits,BlogExhibit)
      end
    end
  end
end