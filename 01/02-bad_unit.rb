Class User

  ...
  
  def save
    if self.address.street =~ VALID_STREET_ADDRESS_REGEX &&
       self.address.postal_code =~ VALID_POSTAL_CODE_REGEX &&      
       CITIES.include?(self.address.city) &&
       REGIONS.include?(self.address.region) &&
       COUNTRIES.include?(self.address.country)
       
       DB_CONNECTION.write(self)
       
       true
     else
       raise InvalidRecord.new("Invalid address!")
     end
   end
   
   ...
   
 end
