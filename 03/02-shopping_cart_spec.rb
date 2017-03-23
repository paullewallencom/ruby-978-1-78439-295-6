require 'rspec'
require_relative 'simple_mock'

class ShoppingCart  
  def total_price
    products.inject(0) do |sum, product|
      sum += product.price
    end
  end
  
  # ...
end

class Product
  # ...
end

RSpec.describe ShoppingCart do
  describe '#total_price' do
    it "returns the sum of the prices of all products" do
      num_products  = 22
      price         = 100
      cart          = ShoppingCart.new
      some_products = [Product.new] * num_products
      
      ShoppingCart.mock(:products, some_products) do
        Product.mock(:price, price) do
          expect(cart.total_price).to eq(num_products * price)
        end
      end
    end
    
    context "using RSpec's allow_any_instance_of" do
      it "returns the sum of the prices of all products" do
        num_products  = 22
        price         = 100
        cart          = ShoppingCart.new
        some_products = [Product.new] * num_products
      
        expect_any_instance_of(ShoppingCart).to receive(:products)
          .and_return(some_products)
        
        allow_any_instance_of(Product).to receive(:price)
          .and_return(price)
      
        expect(cart.total_price).to eq(num_products * price)
      end      
    end
    
context "using Object.new" do
  it "returns the sum of the prices of all products" do
    num_products  = 22
    price         = 100
    cart          = ShoppingCart.new
    product       = Object.new
    some_products = [product] * num_products
  
    expect(cart).to receive(:products)
      .and_return(some_products)
    
    allow(product).to receive(:price)
      .and_return(price)
  
    expect(cart.total_price).to eq(num_products * price)
  end      
end    

context "using RSpec's double" do
  it "returns the sum of the prices of all products" do
    num_products  = 22
    price         = 100
    cart          = ShoppingCart.new
    product       = double('Product', price: price)
    some_products = [product] * num_products
  
    expect(cart).to receive(:products)
      .and_return(some_products)
  
    expect(cart.total_price).to eq(num_products * price)
  end      
end        
  end
end