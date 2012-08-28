require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module Functional
  class ValidatesBlockTest < Test::Unit::TestCase
    test "when using validate block, which is executed on the instance" do
      klass = Class.new do
        include Validatable
        attr_accessor :name
        validate do
          self.name = 'validated'
          errors.add(:validation, "is invalid")
        end
      end
      instance = klass.new
      assert !instance.valid?
      assert_equal "is invalid", instance.errors.on(:validation)
    end

    test "vaidate block should also yield a parameter which is the object" do
      klass = Class.new do
        include Validatable
        attr_accessor :name
        validate do |instance|
          instance.name = "validated"
        end
      end
      instance = klass.new
      assert_equal true, instance.valid?
      assert_equal "validated", instance.name
    end
  end
end
