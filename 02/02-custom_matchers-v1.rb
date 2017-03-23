# v1 : custom error message without a custom matcher
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
  let(:product)      { "foo123"                           }
  let(:discounts)    { { product => 0.1 }                 }
  subject(:customer) { Customer.new(discounts: discounts) }

  it "detects when customer has a discount" do
    actual = customer.discount_amount_for(product)
    expect(actual).to eq(0.2)
  end

  it "has a custom error message" do
    actual = customer.discount_amount_for(product)
    if actual != 0.2
      fail "Expected discount amount to equal 0.2 not #{actual}"
    end
  end
end