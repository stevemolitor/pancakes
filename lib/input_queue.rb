module Pancakes
  module Util
    class InputQueue #:nodoc:
      def initialize(input)
        @input = input
        @buffer = nil
      end

      def pop
        result = @buffer || @input.gets
        @buffer = nil
        result
      end

      def peek
        @buffer ||= pop
      end
    end
  end
end
