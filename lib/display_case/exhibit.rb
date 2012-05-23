require 'delegate'
require 'active_support/core_ext'
require 'display_case/railtie' if defined?(Rails)

module DisplayCase
  class Exhibit < SimpleDelegator
    @@exhibits = []
  
    def self.exhibits
      @@exhibits
    end
  
    def self.inherited(child)
      @@exhibits << child
    end

    def self.exhibit(object, context)
      return object if exhibited_object?(object)
      Rails.logger.debug "Registered exhibits: #{@@exhibits}"
      Rails.logger.debug "Exhibiting #{object.inspect}"
      Rails.logger.debug "Exhibit context: #{context}"
      object = Exhibited.new(object, context)
      exhibits.inject(object) do |object, exhibit_class|
        exhibit_class.exhibit_if_applicable(object, context)
      end.tap do |obj|
        Rails.logger.debug "Exhibits applied: #{obj.inspect_exhibits}"
      end
    end

    def self.exhibit_if_applicable(object, context)
      if applicable_to?(object)
        new(object, context)
      else
        object
      end
    end

    def self.applicable_to?(object)
      false
    end

    def self.exhibited_object?(object)
      object.respond_to?(:exhibited?) && object.exhibited?
    end

    def self.exhibit_query(*method_names)
      method_names.each do |name|
        define_method(name) do |*args, &block|
          exhibit(super(*args, &block))
        end
      end
    end
    private_class_method :exhibit_query

    # A helper for matching models to classes/modules, intended for use
    # in .applicable_to?.
    def self.object_is_any_of?(object, *classes)
      # What with Rails development mode reloading making class matching
      # unreliable, plus wanting to avoid adding dependencies to
      # external class definitions if we can avoid it, we just match
      # against class/module name strings rather than the actual class
      # objects.

      # Note that '&' is the set intersection operator for Arrays.
      (classes.map(&:to_s) & object.class.ancestors.map(&:name)).any?
    end
    private_class_method :object_is_any_of?

    attr_reader :context

    def initialize(model, context)
      @context = context
      super(model)
    end

    alias_method :__class__, :class
    def class
      __getobj__.class
    end

    def exhibit(model)
      Exhibit.exhibit(model, context)
    end

    def to_partial_path
      if __getobj__.respond_to?(:to_partial_path)
        __getobj__.to_partial_path
      else
        partialize_name(__getobj__.class.name)
      end
    end

    def render(template)
      template.render(:partial => to_partial_path, :object => self)
    end

    def exhibit_chain
      inner_exhibits = defined?(super) ? super : []
      [__class__] + inner_exhibits
    end

    def inspect_exhibits
      exhibit_chain.map(&:to_s).join(':')
    end

    def inspect
      "#{inspect_exhibits}(#{__getobj__.inspect})"
    end

    def exhibited?
      true
    end

    private

    # The terminator for the exhibit chain, and a marker that an object
    # has been through the exhibit process
    class Exhibited < Exhibit
      def exhibit_chain
        []
      end

      def to_model
        __getobj__
      end
    end

    def partialize_name(name)
      "/#{name.underscore.pluralize}/#{name.demodulize.underscore}"
    end
  end
end