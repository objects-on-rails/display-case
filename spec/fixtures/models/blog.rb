require_relative 'taggable'
require 'delegate'

module Conversions; end

require 'delegate'
class Blog

  def self.model_name
    ActiveModel::Name.new(self)
  end

  attr_reader :entries
  attr_writer :post_source

  def initialize(entry_fetcher=->{Taggable(Post.most_recent)})
    @entry_fetcher = entry_fetcher
  end

  def title
    "Watching Paint Dry"
  end

  def subtitle
    "The trusted source for drying paint news & opinion"
  end

  def entries
    fetch_entries
  end

  def new_post(*args)
    post_source.call(*args).tap do |p|
      p.blog = self
    end
  end

  # Fetch a post by ID
  def post(id)
    entries.find_by_id(id)
  end

  def add_entry(entry)
    entry.save
  end

  def tags
    entries.all_tags_alphabetical
  end

  def filter_by_tag(tag)
    FilteredBlog.new(self, tag)
  end

  private

  class FilteredBlog < DelegateClass(Blog)
    include ::Conversions

    def initialize(blog, tag)
      super(blog)
      @tag = tag
    end

    def entries
      super.tagged(@tag)
    end
  end

  def fetch_entries
    @entry_fetcher.()
  end

  def post_source
    @post_source ||= Taggable(Post).public_method(:new)
  end
end
