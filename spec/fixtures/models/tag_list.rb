require 'forwardable'

module Conversions
  private
  def TagList(value)
    return value if value.is_a?(TagList)
    TagList.new(value)
  end
end

class TagList
  extend Forwardable
  include Enumerable
  attr_reader :tags

  def_delegators :tags, :empty?, :to_a, :each, :size

  def initialize(tags)
    case tags
    when Array
      @tags = tags
    else
      @tags = tags.to_s.split(/\W+/)
    end
    @tags.each(&:downcase!)
    @tags.uniq!
  end

  def to_s
    tags.join(", ")
  end

  def to_ary
    @tags
  end

  def +(other)
    self.class.new(to_a + other.to_a)
  end

  def ==(other)
    to_a == Array(other)
  end

  def alphabetical
    self.class.new(tags.sort)
  end
end
