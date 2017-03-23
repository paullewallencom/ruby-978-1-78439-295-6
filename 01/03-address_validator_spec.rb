require 'rspec'
require_relative 'address_validator'

describe AddressValidator do
  it "returns false for incomplete address" do
    address = { street: "123 Any Street", city: "Anytown" }
    expect(
      AddressValidator.valid?(address)
    ).to eq(false)
  end

  it "missing_parts returns an array of missing required parts" do
    address = { street: "123 Any Street", city: "Anytown" }
    expect(
      AddressValidator.missing_parts(address)
    ).to eq([:region, :postal_code, :country])
  end
end
