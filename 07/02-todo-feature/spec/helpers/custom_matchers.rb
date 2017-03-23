require 'rspec/expectations'

# custom matchers to simplify assertions
RSpec::Matchers.define :have_completed_item do |text|
  match do |node|
    node.has_selector?('.completed label', :text => text)
  end

  match_when_negated do |node|
    node.has_no_selector?('.completed label', :text => text)
  end
end