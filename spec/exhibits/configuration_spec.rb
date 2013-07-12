require_relative '../spec_helper_lite'
require_relative '../../lib/display_case'
require_relative '../fixtures/exhibits/blog_exhibit'

module DisplayCase
  describe Exhibit do
    describe '#exhibits' do
      it 'should not include BlogExhibit when explicit and no exhibits given' do
        DisplayCase.configure do |config|
          config.explicit = true
          config.exhibits = []
        end
        refute_includes(Exhibit.exhibits, BlogExhibit)
      end

      it 'should include BlogExhibit when explicit and BlogExhibit listed' do
        DisplayCase.configure do |config|
          config.explicit = true
          config.exhibits = [BlogExhibit]
        end
        assert_includes(Exhibit.exhibits, BlogExhibit)
      end

      it 'should allow you to set the cache store' do
        default_store = DisplayCase.configuration.cache_store
        assert_nil default_store

        DisplayCase.configure do |config|
          config.cache_store = DisplayCase::Cache::Store.new
        end

        refute_equal DisplayCase.configuration.cache_store, default_store
      end

      it 'allows you to set whether you want logging to be enabled' do
        refute DisplayCase.configuration.logging_enabled

        DisplayCase.configure do |config|
          config.logging_enabled = true
        end

        assert DisplayCase.configuration.logging_enabled
      end
    end
  end
end
