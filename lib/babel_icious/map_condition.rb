module Babelicious

  class MapCondition

    def initialize
      @condition, @block = nil, nil
    end

    def is_satisfied_by(source_value)
      unless @block
        case @condition_key
        when :unless
          process_unless_condition(source_value)
        when :when
          eval "source_value.#{@condition.to_s}?"
        end
      else
        @block.call(source_value)
      end
    end

    def register(condition_key, condition=nil, &block)
      @condition_key, @condition, @block = condition_key, condition, block
    end

    private

    def process_unless_condition(source_value)
      if(@condition == :nil)
        !source_value.nil?
      else
        unless source_value.is_a?(Array) || source_value.is_a?(Hash)
          source_value = source_value.to_s
        end
        eval "!source_value.nil? && !source_value.#{@condition.to_s}?"
      end
    end

  end
end
