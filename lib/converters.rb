module Pancakes
  module Converters

    class Base
      def deconvert(value, length, padstr=' ', justify_direction=:left)
        val = value.to_s[0..length-1]

        case justify_direction
        when :left
          val.ljust(length, padstr)
        when :right
          val.rjust(length, padstr)
        else
          val
        end
      end
    end
    
    class IntegerConverter < Base
      def convert(raw_value)
        raw_value.to_i
      end

      def deconvert(value, length, padstr=' ')
        super(value, length, padstr, :right)
      end
    end
    
    class FloatConverter < Base
      def convert(raw_value)
        raw_value.to_f
      end

      def deconvert(value, length, padstr=' ')
        super(value, length, padstr, :right)
      end
    end
    
    class StrippingConverter < Base
      def convert(raw_value)
        raw_value.to_s.strip
      end

      def deconvert(value, length, padstr=' ')
        super(value, length, padstr, :left)
      end
    end
    
    class ProcConverter < Base
      def initialize(proc)
        @proc = proc
      end

      def convert(raw_value)
        @proc.call(raw_value)
      end
    end

    class NoOpConverter < Base
      def convert(raw_value)
        raw_value
      end
    end
    
    CONVERTERS = {
      :integer => IntegerConverter.new,
      :float => FloatConverter.new,
      :string => StrippingConverter.new,
      :raw => NoOpConverter.new,
      :default => StrippingConverter.new
    }
    
  end
end
