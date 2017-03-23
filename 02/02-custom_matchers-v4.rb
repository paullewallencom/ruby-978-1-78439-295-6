# v4 : with multiple discounts and better diffs
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

RSpec::Matchers.define :be_discounted do |hsh|
  match do |customer|
    @customer = customer
    @actual   = hsh.keys.inject({}) do |memo, product, _|
      memo[product] = @customer.discount_amount_for(product)
      memo
    end

    differ = RSpec::Support::Differ.new

    @difference = differ.diff_as_object(hsh, @actual)
    @difference == "" # blank diff means equality
  end

  failure_message do |actual|
    "Expected #{@customer} to have discounts:\n"  +
    "  #{actual.inspect}.\n"                      +
    "Diff: "                                      +
    @difference
  end
end

describe "product discount" do
  let(:products)     { %w( a b c )                         }
  let(:discounts)    { Hash[products.map{ |s| [s, 0.1] }]  }
  let(:discounts2)   { Hash[products.map{ |s| [s, 0.2] }]  }
  subject(:customer) { Customer.new(discounts: discounts2) }

  it "detects when customer has a discount" do
    # notice we now pass a single Hash to be_discounted
    expect(customer).to be_discounted(discounts)
  end
end