require_relative '../spec_helper_lite'
require_relative '../../lib/display_case'
require 'ostruct'

describe "reloading namespaced exhibits" do
  let(:model) { stub }
  let(:exhibit_file) {
    File.expand_path('spec/fixtures/exhibits/changing_exhibits/namespaced_exhibit_three.rb')
  }

  before do
    DisplayCase.configure do |config|
      config.definition_file_paths = [exhibit_file.sub('namespaced_exhibit_three.rb', '')]
      DisplayCase.find_definitions
      config.explicit = true
      config.swallow_superclass_mismatch_for_exhibits = true
      config.exhibits = [Namespaced::ExhibitThree, Namespaced::ExhibitFour].reverse
    end
  end

  it "reloading namespaced exhibits should include the new changes" do
    begin
      exhibited = DisplayCase::Exhibit.exhibit(model)
      exhibited.change_this.must_equal "unchanged"
      exhibited.dont_change_this.must_equal "unchanged"

      Namespaced.send(:remove_const, :ExhibitThree) # Issue 57 relies on this
      #load File.expand_path('spec/fixtures/exhibits/changing_exhibits/namespaced_exhibit_four.rb')
      change_exhibit_file

      DisplayCase.find_definitions

      exhibited = DisplayCase::Exhibit.exhibit(model)
      exhibited.change_this.must_equal "changedit"
      exhibited.dont_change_this.must_equal "unchanged"
    ensure
      restore_exhibit_file
    end
  end

  private
  def change_exhibit_file
    contents = File.read(exhibit_file)
    File.open(exhibit_file, 'w') do |f|
      f.write contents.gsub('"unchanged"','"changedit"')
    end
  end

  def restore_exhibit_file
    contents = File.read(exhibit_file)
    File.open(exhibit_file, 'w') do |f|
      f.write contents.gsub('"changedit"','"unchanged"')
    end
  end
end
