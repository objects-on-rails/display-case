require 'date'
require 'active_record'

class Post < ActiveRecord::Base
  LIMIT_DEFAULT = 10

  validates :title, presence: true

  def self.most_recent(limit=LIMIT_DEFAULT)
    order("pubdate DESC").limit(limit)
  end

  def self.first_before(date)
    first(conditions: ["pubdate < ?", date],
          order:      "pubdate DESC")
  end

  def self.first_after(date)
    first(conditions: ["pubdate > ?", date],
          order:      "pubdate ASC")
  end

  def self.find_by_id(id)
    super(id)
  end

  attr_writer :blog

  def blog
    @blog ||= THE_BLOG
  end

  def picture?
    image_url.present?
  end

  def publish(clock=DateTime)
    return false unless valid?
    self.pubdate ||= clock.now
    @blog.add_entry(self)
  end

  def prev
    self.class.first_before(pubdate)
  end

  def next
    self.class.first_after(pubdate)
  end

  def up
    blog
  end

  def save(*)
    set_default_body
    super
  end

  private

  def set_default_body
    if body.blank?
      self.body = 'Nothing to see here'
    end
  end
end
