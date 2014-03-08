require 'delegate'
require 'active_support/core_ext'
require 'display_case/railtie' if defined?(::Rails)
require_relative 'configuration'
require_relative 'is_a_class_comparator'
require_relative 'name_class_comparator'

module DisplayCase
  class Exhibit < SimpleDelegator
    @@exhibits = []

    def self.exhibits
      if DisplayCase.configuration.explicit?
        DisplayCase.configuration.exhibits
      else
        @@exhibits
      end
    end

    def self.inherited(child)
      @@exhibits << child
    end

    def self.exhibit(object, context=nil)
      return object if exhibited_object?(object)
      if DisplayCase.configuration.logging_enabled?
        ::Rails.logger.debug "Registered exhibits: #{@@exhibits}"
        ::Rails.logger.debug "Exhibiting #{object.inspect}"
        ::Rails.logger.debug "Exhibit context: #{context}"
      end

      object = BasicExhibit.new(Exhibited.new(object, context), context)

      # done w/ unsimilar first since the last applied exhibit is the top-most one
      sorted_exhibits(context).inject(object) do |object, exhibit_class|
        exhibit_class.exhibit_if_applicable(object, context)
      end.tap do |obj|
        ::Rails.logger.debug "Exhibits applied: #{obj.inspect_exhibits}" if DisplayCase.configuration.logging_enabled?
      end
    end

    def self.partition_by_name(exhibits, context=nil)
      exhibits.partition do |exhibit_class|
        exhibit_name = exhibit_class.name.to_s.downcase.gsub("exhibit", "")
        exhibit_name.length > 0 && context.class.name.downcase.include?(exhibit_name)
      end
    end
    private_class_method :partition_by_name

    def self.sorted_exhibits(context)
      if smart_matching?(context)
        similar, unsimilar = partition_by_name(exhibits, context)
        unsimilar + similar
      else
        exhibits
      end
    end
    private_class_method :sorted_exhibits

    def self.smart_matching?(context)
      DisplayCase.configuration.smart_matching? && !(DisplayCase.configuration.explicit? || context.nil? || context.class.name.nil?)
    end
    private_class_method :smart_matching?

    def self.exhibit_if_applicable(object, context)
      if applicable_to?(object, context)
        new(object, context)
      else
        object
      end
    end

    def self.applicable_to?(object, context=nil)
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

    def self.class_comparator
      @@class_comparator ||= begin
        comparator = nil

        if defined? ::Rails
          config = ::Rails.respond_to?(:config) ? ::Rails.config : ::Rails.application.config
          comparator = NameClassComparator.new unless config.cache_classes
        end

        comparator || IsAClassComparator.new
      end
    end

    # A helper for matching models to classes/modules, intended for use
    # in .applicable_to?.
    def self.object_is_any_of?(object, *classes)
      self.class_comparator.call(object, *classes)
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

    alias_method :__kind_of__?, :kind_of?
    def kind_of?(klass)
      __getobj__.kind_of?(klass)
    end

    alias_method :__is_a__?, :is_a?
    alias_method :is_a?, :kind_of?

    alias_method :__instance_of__?, :instance_of?
    def instance_of?(klass)
      __getobj__.instance_of?(klass)
    end

    def exhibit(model)
      Exhibit.exhibit(model, context)
    end

    def exhibit_chain
      inner_exhibits = __getobj__.respond_to?(:exhibit_chain) ? __getobj__.exhibit_chain : []
      [__class__] + inner_exhibits
    end

    def inspect_exhibits
      exhibit_chain.map(&:to_s).join(':')
    end

    def inspect
      "#{inspect_exhibits}(#{__getobj__.inspect})"
    end

    def render(template, options = {})
      template.render(options.reverse_merge(:partial => to_partial_path, :object => self))
    end

    def exhibited?
      true
    end

    def cache(key, options = {}, &block)
      if DisplayCase.configuration.cache_store
        DisplayCase.configuration.cache_store.fetch(key, options, &block)
      else
        yield
      end
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
