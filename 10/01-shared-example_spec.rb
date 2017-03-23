require_relative 'address_validator'

describe AddressValidator do
  shared_examples_for "invalid address" do |addr|
    it "valid? returns false" do
      expect(AddressValidator.valid?(addr)).to eq(false)
    end
  end
  shared_examples_for "valid address" do |addr|
    it "valid? returns true" do
      expect(AddressValidator.valid?(addr)).to eq(true)
    end
  end
  it_behaves_like("invalid address", {
    street: "123 Any Street",
    city:   "Anytown"
  })
  it_behaves_like "invalid address", "123 Any St., Anytown"
  it_behaves_like(
    "invalid address",
    "$123% Any^ St., Anytown, CA, USA, 12345"
  )

  it_behaves_like(
    "valid address",
    "123 Any St., Anytown, CA, USA, 12345"
  )
  it_behaves_like("valid address",  {
    street:       "123 Any Street",
    city:         "Anytown",
    region:       "Anyplace",
    country:      "Anyland",
    postal_code:  "123456"
  })
end

shared_examples_for "address validation module" do
  shared_examples_for "invalid address" do |addr|
    it "valid? returns false" do
      expect(validator.valid?(addr)).to eq(false)
    end
  end
  shared_examples_for "valid address" do |addr|
    it "valid? returns true" do
      expect(validator.valid?(addr)).to eq(true)
    end
  end
  it_behaves_like("invalid address", {
    street: "123 Any Street",
    city:   "Anytown"
  })
  it_behaves_like "invalid address", "123 Any St., Anytown"
  it_behaves_like(
    "invalid address",
    "$123% Any^ St., Anytown, CA, USA, 12345"
  )

  it_behaves_like(
    "valid address",
    "123 Any St., Anytown, CA, USA, 12345"
  )
  it_behaves_like("valid address",  {
    street:       "123 Any Street",
    city:         "Anytown",
    region:       "Anyplace",
    country:      "Anyland",
    postal_code:  "123456"
  })
end

describe AddressValidator do
  subject(:validator) { AddressValidator }
  it_behaves_like "address validation module"
end

describe NewAddressValidator do
  subject(:validator) { NewAddressValidator }
  it_behaves_like "address validation module"

  # add specs for new features here
end
