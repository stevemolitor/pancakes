require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Examples used in README" do
  EXAMPLE_DATA = <<END
ORD         123
ORD_HEADER  a special order
ORD_L       1    car engine400.99
ORD_L       2    toothpick   1.99
END

  class Order < Pancakes::PositionalPancake
    field :order_id, :position => 12..16
    
    has_one  :order_header, :key => "ORD_HEADER"
    has_many :order_lines,  :key => "ORD_L"
  end
  
  class OrderHeader < Pancakes::PositionalPancake
    field :description, :position => 12..26
  end
  
  class OrderLine < Pancakes::PositionalPancake
    field :line_num,    :position => 12..16, :as => :integer
    field :description, :position => 17..26
    field :price,       :position => 27..32, :as => :float
  end

  before :each do
    @order = Order.load(EXAMPLE_DATA)
  end

  it "should parse example as described in README" do
    @order.order_id.should == '123'
    @order.order_header.description.should == 'a special order'

    @order.order_lines.size.should == 2

    @order.order_lines.first.line_num.should == 1
    @order.order_lines.last.line_num.should == 2

    @order.order_lines.first.description.should == 'car engine'
    @order.order_lines.last.description.should == 'toothpick'

    @order.order_lines.first.price.should == 400.99
    @order.order_lines.last.price.should == 1.99
  end

end
