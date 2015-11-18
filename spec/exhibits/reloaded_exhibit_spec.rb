require_relative '../spec_helper_lite'
require_relative '../../lib/display_case'
require 'ostruct'

describe "reloading exhibits" do
  let(:model) { stub }
  let(:exhibit_file) {
    File.expand_path('spec/fixtures/exhibits/changing_exhibits/exhibit_one.rb')
  }

  before do
    DisplayCase.configure do |config|
      config.definition_file_paths = [exhibit_file.sub('exhibit_one.rb', '')]
      DisplayCase.find_definitions
      config.explicit = true
      config.swallow_superclass_mismatch_for_exhibits = true
      config.exhibits = [ExhibitOne, ExhibitTwo]
    end
  end

  it "reloading exhibits should include the new changes" do
    begin
      exhibited = DisplayCase::Exhibit.exhibit(model)
      exhibited.change_this.must_equal "unchanged"
      exhibited.dont_change_this.must_equal "unchanged"

      Object.send(:remove_const, :ExhibitOne) # Issue 55 relies on this
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
    File.write(exhibit_file, contents.gsub('"unchanged"','"changedit"'))
  end

  def restore_exhibit_file
    contents = File.read(exhibit_file)
    File.write(exhibit_file, contents.gsub('"changedit"','"unchanged"'))
  end
end
