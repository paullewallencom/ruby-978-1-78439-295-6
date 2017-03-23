describe AddressValidator do
  let(:address) { { street: street, city: city } }
  let(:street)  { "123 Any Street"               }
  let(:city)    { "Anytown"                      }
  it "valid? returns false for incomplete address" do
    expect(AddressValidator.valid?(address)).to be_false
  end
  context "address contains invalid characters" do
    let(:address) { "$123% Any^ St., Anytown, CA, USA 12345" }
    it "valid? returns false for incomplete address" do
      expect(AddressValidator.valid?(address)).to be_false
    end
  end
  context "address is a String" do
    let(:address) { "123 Any St., Anytown" }
    it "valid? returns false for incomplete address" do
      expect(AddressValidator.valid?(address)).to be_false
    end
  end
  context "complete address" do
    let(:address) do
      {
        street:       "123 Any Street",
        city:         "Anytown",
        region:       "Anyplace",
        country:      "Anyland",
        postal_code:  "123456"
      }
    end
    it "valid? returns true" do
      expect(AddressValidator.valid?(address)).to be_true
    end
    context "address is a String" do
      let(:address) { "123 Any St., Anytown, CA, USA, 12345" }
      it "valid? returns true" do
        expect(AddressValidator.valid?(address)).to be_true
      end
    end
  end
end
