require "converters"
require "active_support"

module Pancakes
  module Positional
    
    class Field
      attr_reader :options

      def initialize(data, options={}, supplied_value=nil)
        @data, @options, @supplied_value = data, options, supplied_value
      end
      
      def value
        converters.inject(raw_value) { |val, conv| conv.convert(val) }
      end
      
      def raw_value
        @data && @data[position] || @supplied_value
      end

      def print
        converters.inject(value) { |val, conv| conv.deconvert(val, length) }
      end

      def print?
        options[:print] != false
      end

      def position
        options[:position]
      end

      def start_pos
        position.first
      end

      def end_pos
        position.last
      end

      def length
        end_pos - start_pos + 1
      end

      private

      def converters
        [*@options[:as]].map do |opt|
          if opt.respond_to? :call
            Converters::ProcConverter.new(opt)
          else
            Converters::CONVERTERS[opt] || Converters::CONVERTERS[:default]
          end
        end
      end
    end

    module InstanceMethods
      def initialize(values={}, data=nil)
        @fields = {}
        @data = data

        set_fields_from_data
        set_fields_from_values(values)
      end

      def method_missing(method, *args)
        if field = @fields[method]
          field.value
        elsif (field_name = method.to_s.sub(/=$/, '').to_sym) && @fields[field_name]
          @fields[field_name] = Field.new(nil, @fields[field_name].options, args.first)
          @fields[field_name].value
        else
          super
        end
      end

      def print(padstr=' ')
        line_length = @fields.values.map(&:end_pos).sort.last + 1

        returning(padstr * line_length) do |s|
          @fields.values.select(&:print?).sort_by(&:start_pos).each do |f|
            s[f.start_pos..f.end_pos] = f.print
          end
        end
      end

      private

      def set_fields_from_data
        field_defs.each_pair { |key, opts| @fields[key] = Positional::Field.new(@data, opts) }
      end

      def set_fields_from_values(values)
        values.each_pair do |key, val|
          @fields[key] = Positional::Field.new(@data, field_defs[key], val)
        end
      end

      def field_defs
        self.class.field_defs
      end
    end

    module ClassMethods
      def field_defs
        @field_defs ||= Hash.new({})
      end
      
      def load(data)
        new({}, data)
      end
      
      def field(name, options={})
        field_defs[name.to_sym] = options
      end
    end
  end

  class PositionalPancake
    include Positional::InstanceMethods
    extend Positional::ClassMethods
  end

end
