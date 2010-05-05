require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.dirname(__FILE__) + "/../lib/input_queue"
require "stringio"

describe Pancakes::Util::InputQueue do

  DATA = <<END
one
two
three
END

  before :each do
    @q = Pancakes::Util::InputQueue.new(StringIO.new(DATA))
  end

  it "should peek and pop" do
    @q.peek.chomp.should == "one"
    @q.peek.chomp.should == "one"

    @q.pop.chomp.should == "one"
    @q.peek.chomp.should == "two"

    @q.pop.chomp.should == "two"
    @q.pop.chomp.should == "three"
    @q.pop.should be_nil
    @q.peek.should be_nil
  end
end
