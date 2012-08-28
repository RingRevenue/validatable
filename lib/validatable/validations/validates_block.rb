module Validatable
  class ValidatesBlock < ValidationBase #:nodoc:
    required_option :logic

    def valid?(instance)
      instance.instance_eval(&logic)
      true
    end
  end
end
