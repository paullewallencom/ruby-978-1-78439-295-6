module AddressValidator
  FIELD_NAMES = [:street, :city, :region, :postal_code, :country]
  VALID_VALUE = /^[A-Za-z0-9\.\# ]+$/
  class << self
    def valid?(o)
      normalized = parse(o)
      FIELD_NAMES.all? do |k|
        v = normalized[k]
        !v.nil? && v != "" && valid_part?(v)
      end
    end

    def missing_parts(o)
      normalized = parse(o)
      FIELD_NAMES - normalized.keys
    end

    private

    def parse(o)
      if (o.is_a?(String))
        values = o.split(",").map(&:strip)
        Hash[ FIELD_NAMES.zip(values) ]
      elsif (o.is_a?(Hash))
        o
      else
        raise "Don't know how to parse #{o.class}"
      end
    end

    def valid_part?(value)
      value =~ VALID_VALUE
    end
  end
end
