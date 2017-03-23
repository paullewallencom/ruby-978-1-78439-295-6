Class User

...

  def valid_address?
    self.address.street =~ VALID_STREET_ADDRESS_REGEX       &&
       self.address.postal_code =~ VALID_POSTAL_CODE_REGEX  &&
       CITIES.include?(self.address.city)                   &&
       REGIONS.include?(self.address.region)                &&
       COUNTRIES.include?(self.address.country)
  end

  def persist_to_db
    DB_CONNECTION.write(self)
  end

  def save
    if valid_address?
      persist_to_db

      true
    else
      false
    end
  end

  def save!
    self.save || raise InvalidRecord.new("Invalid address!")
  rescue
    raise FailedToSave.new("Error saving address: #{$!.inspect}")
  end

...

end
