require_relative 'exhibit'

module DisplayCase
  class EnumerableExhibit < Exhibit
    include Enumerable

    def self.applicable_to?(object, context=nil)
      # ActiveRecord::Relation, surprisingly, is not Enumerable. But it
      # behaves sufficiently similarly for our purposes.
      object.respond_to?(:each)
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

    exhibit_query :[], :fetch, :slice, :values_at, :last, :pop
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
      self.to_a
    end

    # See https://github.com/objects-on-rails/display-case/issues/27
    def to_json(*args)
      as_json(*args).to_json(*args)
    end

    def render(template, options = {})
      inject(ActiveSupport::SafeBuffer.new) { |output,element|
        output << element.render(template, options)
      }
    end

  end
end
