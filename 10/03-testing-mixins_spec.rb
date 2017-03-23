require_relative 'address_validator'

describe AddressValidator do
  class Dummy
    attr_accessor :address

    include AddressValidator
  end
  subject(:addressable) { Dummy.new }

  it "should have an address_valid? method" do
    expect(addressable).to respond_to(:address_valid?)
  end
end

module Cheesy
  def self.included(base)
    base.class_eval do
      def method_missing(meth, *args, &block)
        if meth.to_s =~ /_with_cheese$/
          without_cheese = meth.to_s.gsub(/_with_cheese$/, '')

          if respond_to?(without_cheese)
            "#{without_cheese} is better with cheese!"
          else
            "Don't know how to add cheese to #{without_cheese}!"
          end
        else
          super
        end
      end

      def respond_to?(meth, include_private = false)
        if meth.to_s =~ /_with_cheese$/
          without_cheese = meth.to_s.gsub(/_with_cheese$/, '')

          respond_to?(without_cheese)
        else
          super
        end
      end
    end
  end
end

describe Cheesy do
  class Dummy
    include Cheesy
  end
  subject(:cheesed) { Dummy.new }

  it "has an inspect_with_cheese method" do
    expect(cheesed).to respond_to(:inspect_with_cheese)
  end

  it "adds cheese to inspect" do
    actual = cheesed.inspect_with_cheese
    expect(actual).to eq("inspect is better with cheese!")
  end

  it "doesn't add cheese to foobar" do
    actual   = cheesed.foobar_with_cheese
    expected = "Don't know how to add cheese to foobar!"
    expect(actual).to eq(expected)
  end
end
