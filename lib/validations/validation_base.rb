module Validatable
  class ValidationBase #:nodoc:
    class << self
      def required_option(*args)
        option(*args)
        requires(*args)
      end
      
      def option(*args)
        attr_accessor(*args)
        understands(*args)
      end
      
      def default(hash)
        defaults.merge! hash
      end
      
      def defaults
        @defaults ||= {}
      end
      
      def all_defaults
        return defaults.merge(self.superclass.all_defaults) if self.superclass.respond_to? :all_defaults
        defaults
      end
      
      def after_validate(&block)
        after_validations << block
      end
      
      def after_validations
        @after_validations ||= []
      end
      
      def all_after_validations
        return after_validations + self.superclass.all_after_validations if self.superclass.respond_to? :all_after_validations
        after_validations
      end
    end

    include Understandable
    include Requireable
    
    option :message, :if, :times, :level, :groups, :key
    default :level => 1, :groups => [], :key => "key"
    attr_accessor :attribute
    
    def initialize(klass, attribute, options={})
      must_understand options
      requires options
      raise_error_if_dup_keys(klass)
      self.class.all_understandings.each do |understanding|
        options[understanding] = self.class.all_defaults[understanding] unless options.has_key? understanding
        self.instance_variable_set("@#{understanding}", options[understanding])
      end
      self.attribute = attribute
      self.groups = [self.groups] unless self.groups.is_a?(Array)
      self.key = "#{self.class.name}:#{self.attribute}:#{self.key}"
    end
    
    def raise_error_if_dup_keys(options)
    end
    
    def should_validate?(instance)
      result = validate_this_time?(instance)
      result &&= instance.instance_eval(&self.if) unless self.if.nil?
      result
    end
    
    def message(instance)
      @message.respond_to?(:call) ? instance.instance_eval(&@message) : @message
    end
    
    def validate_this_time?(instance)
      return true if @times.nil?
      self.times > instance.times_validated(self.key)
    end
    
    def run_after_validate(result, instance, attribute)
      self.class.all_after_validations.each do |block|
        block.call result, instance, attribute
      end
    end
  end
end