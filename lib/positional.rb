require "converters"
require "input_queue"
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
        converters.inject(value) { |val, conv| conv.deconvert(val, length, padstr) }
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

      def padstr
        options[:padstr] || ' '
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
        @children = {}
        @data = data

        set_fields_from_data
        set_fields_from_values(values)
      end

      def get_field_value(name, options)
        field = @fields[name]
        unless field
          field = @fields[name] = Positional::Field.new(@data, options)
        end
        field.value
      end

      def print(padstr=' ')
        line_length = @fields.values.map(&:end_pos).sort.last + 1

        returning(padstr * line_length) do |s|
          @fields.values.select(&:print?).sort_by(&:start_pos).each do |f|
            s[f.start_pos..f.end_pos] = f.print
          end
        end
      end

      def load_children(input_q)
        child_keys = association_defs.values.map { |opts| opts[:key] }
        
        while line = input_q.pop
          association_defs.each_pair do |name, opts|
            other_child_keys = child_keys.reject { |k| k == opts[:key] }
            if line.starts_with?(opts[:key]) && !other_child_keys.detect { |k| line.starts_with?(k) }
              record_class = opts[:class] || self.class.const_get(name.to_s.classify)
              child = record_class.new({}, line)
              add_child(name, child, opts[:cardinality])
            end
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

      def association_defs
        self.class.association_defs
      end

      def add_child(name, child, cardinality)
        case cardinality
        when :one
          @children[name] = child
        else # :many
          @children[name] ||= []
          @children[name] << child
        end
      end
    end

    module ClassMethods
      def field_defs
        @field_defs ||= Hash.new({})
      end

      def association_defs
        @association_defs ||= Hash.new({})
      end
      
      def load(data)
        data = StringIO.new(data) if data.kind_of? String

        q = Util::InputQueue.new(data)
        first_line = q.pop

        returning new({}, first_line) do |record|
          record.load_children(q)
        end
      end
      
      def field(name, options={})
        field_defs[name] = options

        define_method(name) do
          @fields[name] && @fields[name].value || nil
        end

        define_method("#{name}=") do |value|
          @fields[name] = Field.new(nil, @fields[name].options, value)
          @fields[name].value
        end
      end

      def has_many(name, options={})
        define_association(name, options.merge(:cardinality => :many))
      end

      def has_one(name, options={})
        define_association(name, options.merge(:cardinality => :one))
      end

      private

      def define_association(name, options)
        association_defs[name.to_sym] = options
        define_method(name) { @children[name] }
      end
    end
  end
  
  class PositionalPancake
    include Positional::InstanceMethods
    extend Positional::ClassMethods
  end

end
