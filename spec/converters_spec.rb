require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

include Pancakes::Converters

describe Pancakes::Converters do
  it "should parse integers" do
    CONVERTERS[:integer].convert("123").should == 123
  end

  it "should not do octal conversions" do
    CONVERTERS[:integer].convert("0123").should == 123
  end

  it "should convert invalid integers to 0" do
    CONVERTERS[:integer].convert("asdf").should == 0
  end

  it "should convert floats" do
    CONVERTERS[:float].convert("123.45").should == 123.45
  end

  it "should convert precision decimals" do
    
  end

  it "should strip strings" do
    CONVERTERS[:string].convert(" abc  ").should == "abc"
  end

  it "should not do anything when using raw converter" do
    CONVERTERS[:raw].convert(" abc  ").should == " abc  "    
  end
end
