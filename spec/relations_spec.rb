require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require "stringio"

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
    puts "loaded order"
  end

  it "should handle one to many relationships" do
    @order.data.should == '3456'
    @order.order_lines.size.should == 2
    @order.order_lines.first.data.should == 'ab'
    @order.order_lines.last.data.should == 'cd'
  end

  MANY_ORDERS_DATA = <<END
ORD1234
ORD_Lab
ORD_Lcd
ORD5678
ORD_Lef
ORD_Lgh
END

  class OrderContainer < Pancakes::PositionalPancake
    has_many :orders, :key => "ORD"
  end

  it "should load many orders" do
    @orders = OrderContainer.load(ORDER_DATA)
    @orders.orders.size.should == 2
  end
end
