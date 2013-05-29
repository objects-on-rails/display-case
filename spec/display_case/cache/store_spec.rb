require_relative '../../spec_helper_lite'
require_relative '../../../lib/display_case'
require_relative '../../fixtures/exhibits/blog_exhibit'
require_relative 'store'

module DisplayCase
  describe Exhibit do
    let(:exhibit) { BasicExhibit.new(mock, mock) }
    it "can use a block to access the cache" do
      result = exhibit.cache mock do 
        "cache this"
      end
      assert_equal "cache this", result
    end
    
    it "can utilize the dumb cache store and save computation time" do 
      begin
        DisplayCase.configuration.cache_store = Cache::Store.new
      
        target_time_saved = 1
        block_to_cache = lambda do 
          sleep(target_time_saved)
          "done"
        end

        result_on_miss = nil
        initial_timing = Benchmark.realtime do
          result_on_miss = exhibit.cache "key", &block_to_cache
        end

        result_on_hit = nil
        cached_timing = Benchmark.realtime do
          result_on_hit = exhibit.cache "key", &block_to_cache
        end 
      
        assert_equal(result_on_miss, result_on_hit)
      
        actual_time_difference = initial_timing - cached_timing
        
        assert_in_delta(target_time_saved, actual_time_difference, 0.5)
      ensure
        DisplayCase.configuration.cache_store = nil
      end
    end
    
  end
  
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
      
      it "can fetch a key with a block" do
        assert_equal stored_value, cache.fetch(key){ stored_value }
      end
      
      it "can tell if a key exists" do
        assert !cache.exist?(key)
      end
    end
  end
end