# v6 : custom matcher with refactored implementation

class Customer
  # ... no discount info here!
end

class Discount
  attr_reader :amount, :customer, :product

  def initialize(opts={})
    @customer = opts[:customer]
    @product  = opts[:product]
    @amount   = opts[:amount]
  end

  STORE = []
  class << self
    def create(opts={})
      STORE << self.new(opts)
    end

    def find(opts={})
      STORE.select do |discount|
        opts.each do |k, v|
          discount.send(k) == v
        end
      end.first
    end
  end
end

class HaveDiscountOf
  def initialize(expected_discount)
    @expected = expected_discount
  end

  def matches?(customer)
    @actual = Discount.find(product: @product, customer: customer)
    @amt    = @actual && @actual.amount
    @amt == @expected
  end
  alias == matches? # only for deprecated customer.should syntax

  def for(product)
    @product = product
    self
  end

  def failure_message
    if @actual
      "Expected #{@product} discount of #{@expected}, got #{@amt}"
    else
      "#{@customer} has no discount for #{@product}"
    end
  end

  def failure_message_when_negated
    "Expected #{@product} to not have discount of #{@expected}"
  end
end

describe "product discount" do
  def have_discount_of(discount)
    HaveDiscountOf.new(discount)
  end

  let(:product)      { "foo123"     }
  let(:amount)       {  0.1         }
  subject(:customer) { Customer.new }

  before do
    Discount.create(
      product:  product,
      customer: customer,
      amount:   amount
    )
  end

  it "detects when customer has a discount" do
    expect(customer).to have_discount_of(0.2).for(product)
  end

  it "detects when customer does not have a discount" do
    expect(customer).to_not have_discount_of(0.1).for(product)
  end
end
