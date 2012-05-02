require_relative 'tag_list'
module TaggableRecord
  attr_accessor :_tag_storage

  def tags
    @_tag_list ||= TagList.new(_tag_storage.load)
  end

  def tags=(new_tags)
    @_tag_list = TagList.new(new_tags)
  end

  def save(*, &block)
    super.tap do |successful|
      if successful
        _tag_storage.store(tags.to_a)
      end
    end
  end
end
