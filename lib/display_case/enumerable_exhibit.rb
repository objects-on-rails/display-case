require_relative 'exhibit'

module DisplayCase
  class EnumerableExhibit < Exhibit
    include Enumerable

    def self.applicable_to?(object, context=nil)
      # ActiveRecord::Relation, surprisingly, is not Enumerable. But it
      # behaves sufficiently similarly for our purposes.
      check_for = [object, 'Enumerable']
      check_for << 'ActiveRecord::Relation' if defined?(ActiveRecord)
      object_is_any_of? check_for
    end

    # Wrap an Enumerable method which returns another collection
    def self.exhibit_enum(*method_names, &post_process)
      post_process ||= ->(result){exhibit(result)}
      method_names.each do |method_name|
        define_method(method_name) do |*args, &block|
          result = __getobj__.public_send(method_name, *args, &block)
          instance_exec(result, &post_process)
        end
      end
    end
    private_class_method :exhibit_enum

    exhibit_query :[], :fetch, :slice, :values_at, :last
    exhibit_enum :select, :grep, :reject, :to_enum, :sort, :sort_by, :reverse
    exhibit_enum :partition do |result|
      result.map{|group| exhibit(group)}
    end
    exhibit_enum :group_by do |result|
      result.inject({}) { |h,(k,v)|
        h.merge!(k => exhibit(v))
      }
    end

    def each(*)
      __getobj__.map do |e|
        yield exhibit(e) if block_given?
        exhibit(e)
      end.each
    end

    # `render '...', :collection => self` will call #to_ary on this
    # before rendering, so we need to be prepared.
    def to_ary
      self
    end

    def render(template)
      inject(ActiveSupport::SafeBuffer.new) { |output,element|
        output << element.render(template)
      }
    end

  end
end
