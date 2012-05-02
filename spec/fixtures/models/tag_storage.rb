class TagStorage
  attr_reader :item

  def initialize(item)
    @item = item
  end

  def store(tags)
    current_tags  = item_tags.map(&:name)
    new_tags      = Array(tags)
    remove_tags(current_tags, new_tags)
    add_tags(current_tags, new_tags)
  end

  def load
    item_tags.map(&:name)
  end

  private

  def item_tags
    @item_tags ||= fetch_item_tags
  end

  def fetch_item_tags
    ItemTag.where(item_type: item.class, item_id: item.id).includes(:tag)
  end
  
  def item_tag_attributes(t)
    tag = Tag.find_or_create_by_name(t)
    {item: item, tag: tag}
  end

  def add_tags(current_tags, new_tags)
    new_tags = new_tags - current_tags
    new_tags.each do |tag|
      item_tags << ItemTag.create!(item_tag_attributes(tag))
    end
  end

  def remove_tags(current_tags, new_tags)
    removed_tags = current_tags - new_tags
    item_tags.each do |item_tag|
      if removed_tags.include?(item_tag.name)
        item_tag.delete
        item_tags.delete(item_tag)
      end
    end
  end
end
