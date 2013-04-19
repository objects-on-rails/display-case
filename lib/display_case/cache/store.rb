module DisplayCase
  module Cache
    class Store
      def initialize
        @store = {}
      end
      
      def read(key)
        @store[key]
      end
      alias :fetch :read
      
      def write(key, value)
        @store[key] = value
      end
      
      def delete(key)
        @store.delete(key)
      end
      
      def exist?(key)
        @store.has_key?(key)
      end
    end
  end
end