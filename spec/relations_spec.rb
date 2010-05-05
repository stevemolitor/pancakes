require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Positional relations" do
  ORDER_DATA = <<END
ORD3456
ORD_Lab
ORD_Lcd
END

  class Order < Pancakes::PositionalPancake
    field :data, :position => 3..6
     has_many :order_lines, :key => "ORD_L"
  end

  class OrderLine < Pancakes::PositionalPancake
    field :data, :position => 5..6
  end

  before :each do
    @order = Order.load(ORDER_DATA)
  end

  it "should handle one to many relationships" do
    @order.data.should == '3456'
    @order.order_lines.size.should == 2
    @order.order_lines.first.data.should == 'ab'
    @order.order_lines.last.data.should == 'cd'
  end
end
