require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Pancakes::Positional::Field do
  before :each do
    @integer = Pancakes::Positional::Field.new("01", :as => :integer, :position => 0..1)
    @float = Pancakes::Positional::Field.new("1.23", :as => :float, :position => 0..4)
    @string = Pancakes::Positional::Field.new("x", :as => :string, :position => 0..1)
  end

  it "should print fields" do
    @integer.print.should == " 1"
    @float.print.should == " 1.23"
    @string.print.should == "x "
  end
end

describe Pancakes::Positional do
  DATA = <<END
01234 67 9
END

  class Widget < Pancakes::PositionalPancake
    field :integer, :position => 0..1, :as => :integer
    field :string,  :position => 2..3, :as => :string
    field :proc,    :position => 2..3, :as => lambda { |raw_value| raw_value.to_i * 2  }, :print => false
    field :money,   :position => 2..3, :as => [ :integer, lambda { |i| i / 100.0  } ], :print => false
    field :default, :position => 5..8
  end

  before :each do
    @widget = Widget.load(DATA)
  end

  it "should parse string fields" do
    @widget.integer.should == 1
  end

  it "should convert fields" do
    @widget.string.should == "23"
  end

  it "should accept proc converters" do
    @widget.proc.should == 46
  end

  it "should process multiple converters in order as decorators" do
    @widget.money.should == 0.23
  end

  it "should default to stripped string fields" do
    @widget.default.should == "67"
  end

  it "should create new pancakes with supplied attributes" do
    widget = Widget.new(:integer => 123, :string => " abc ")
    widget.integer.should == 123
    widget.string.should == "abc"
  end

  it "should overwrite attributes when written to" do
    @widget.integer = 456
    @widget.integer.should == 456
  end

  it "should print line" do
    @widget.print.should == " 123 67  "
  end
end
