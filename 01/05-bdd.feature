Feature: Address Validation

As a postal customer,
In order to ensure my packages are delivered,
I want to validate addresses

Scenario: Invalid address
	Given I enter “Seoul, USA”
  When I validate the address
  I should see the error message, “City and Country do not match”
