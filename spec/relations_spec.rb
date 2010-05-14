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
    field :not_present, :position => 100..110
    has_many :order_lines, :key => "ORD_L"
    has_many :not_present_children, :key => "NOT_HERE"
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

  it "should handle missing data" do
    @order.not_present.should == ''
    @order.not_present_children.should be_empty
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
