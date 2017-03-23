# v5 : class to allow split assertion
class HaveDiscountOf
  def initialize(expected_discount)
    @expected = expected_discount
  end

  def matches?(customer)
    @customer = customer
    @actual = @customer.discount_amount_for(@product)

    @actual == @expected
  end
  alias == matches? # only for deprecated customer.should syntax

  def for(product)
    @product = product
    self
  end

  def failure_message
    "Expected #{@product} discount of #{@expected}, got #{@actual}"
  end

  def failure_message_when_negated
    "Expected #{@product} to not have discount of #{@expected}"
  end
end

class Customer
  def initialize(opts)
    # assume opts = { discounts: { "foo123" => 0.1 } }
    @discounts = opts[:discounts]
  end

  def has_discount_for?(product_code)
    @discounts.has_key?(product_code)
  end

  def discount_amount_for(product_code)
    @discounts[product_code] || 0
  end
end

describe "product discount" do
  def have_discount_of(discount)
    HaveDiscountOf.new(discount)
  end

  let(:product)      { "foo123"                           }
  let(:discounts)    { { product => 0.1 }                 }
  subject(:customer) { Customer.new(discounts: discounts) }

  it "detects when customer has a discount" do
    expect(customer).to have_discount_of(0.2).for(product)
  end

  it "detects when customer does not have a discount" do
    expect(customer).to_not have_discount_of(0.1).for(product)
  end
end