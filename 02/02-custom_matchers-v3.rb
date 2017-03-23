# v3 : single discount, no diff
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

RSpec::Matchers.define :be_discounted do |product, discount|
  match do |customer|
    @actual = customer.discount_amount_for(product)
    customer.discount_amount_for(product) == discount
  end

  failure_message do |actual|
    "Expected #{product} discount of #{discount}, got #{actual}"
  end
end


describe "product discount" do
  let(:product)      { "foo123"                           }
  let(:discounts)    { { product => 0.1 }                 }
  subject(:customer) { Customer.new(discounts: discounts) }

  it "detects when customer has a discount" do
    expect(customer).to be_discounted(product, 0.2)
  end
end