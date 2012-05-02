require_relative '../spec_helper_lite'
require_relative '../fixtures/exhibits/tag_list_exhibit'

describe TagListExhibit do
  subject { TagListExhibit.new(tag_list, context) }
  let(:tag_list) { Object.new }
  let(:context) { Object.new }
end
