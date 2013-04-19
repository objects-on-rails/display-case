require_relative '../../spec_helper_lite'
require_relative '../../../lib/display_case'
require_relative '../../fixtures/exhibits/blog_exhibit'

module DisplayCase
  module Cache
    describe Store do
      let(:key) { "key" }
      let(:stored_value) { "value" }
      let(:cache) { DisplayCase::Cache::Store.new }

      it "can write and read an object" do 
        assert_nil cache.read(key)
        cache.write(key, stored_value)        
        assert_equal stored_value, cache.read(key)
      end
      
      it "can delete a key" do
        cache.write(key, stored_value)        
        assert_equal stored_value, cache.read(key)
        cache.delete(key)
        assert_nil cache.read(key)
      end
      
      it "can fetch a key" do 
        cache.write(key, stored_value)        
        assert_equal stored_value, cache.fetch(key)
      end
      
      it "can tell if a key exists" do 
        assert !cache.exist?(key)
      end
    end
  end
end