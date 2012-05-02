require_relative '../data/item_tag'
class RelationTagStorage
  def initialize(klass)
    @klass = klass
  end

  def load
    ItemTag.where(item_type: @klass).map(&:name)
  end

  def store(tags)
    raise NotImplementedError
  end
end
