ENV['RAILS_ENV'] ||= 'test'

gem 'minitest' # demand gem version
require 'minitest/autorun'
require 'rr'
require 'ostruct'
$: << File.expand_path('../lib', File.dirname(__FILE__))

class MiniTest::Unit::TestCase
  include RR::Adapters::MiniTest
end

def stub_module(full_name, &block)
  stub_class_or_module(full_name, Module)
end

def stub_class(full_name, &block)
  stub_class_or_module(full_name, Class)
end

def stub_class_or_module(full_name, kind, &block)
  full_name.to_s.split(/::/).inject(Object) do |context, name|
    begin
      # Give autoloading an opportunity to work
      context.const_get(name)
    rescue NameError
      # Defer substitution of a stub module/class to the last possible
      # moment by overloading const_missing. We use a module here so
      # we can "stack" const_missing definitions for various
      # constants.
      mod = Module.new do
        define_method(:const_missing) do |missing_const_name|
          if missing_const_name.to_s == name.to_s
            value = kind.new
            const_set(name, value)
            value
          else
            super(missing_const_name)
          end
        end
      end
      context.extend(mod)
    end
  end
end
