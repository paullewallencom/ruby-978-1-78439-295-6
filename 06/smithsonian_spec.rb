require 'capybara/rspec'

Capybara.current_driver = :selenium  

# switch to chrome based on environment variable. e.g.:
#   $ BROWSER=chrome rspec smithsonian_spec.rb
if ENV['BROWSER'] == 'chrome'
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end  

# use poltergeist headless driver/browser based on environment variable, e.g.
#   $ BROWSER=poltergeist rspec smithsonian_spec.rb
elsif ENV['BROWSER'] == 'poltergeist'
  puts "Using poltergeist headless driver..."
  
  require 'capybara/poltergeist'
  
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {timeout: 60})
  end  
  
  Capybara.current_driver = :poltergeist  
end  

describe "si.edu", type: :feature do  
  it "has a search feature" do
    visit 'http://si.edu'
    
    fill_in "Search", :with => 'Wright Brothers'
    find_button('Go').click

    expect(page).to have_content('National Air and Space Museum')
    expect(page).to_not have_content('Marshmallows')

    expect(page).to have_selector('.keymatch_result a')

    suggested_link = page.find '.keymatch_result a'
    suggested_link.click
    
    expected_text = 'On December 17, 1903, at Kitty Hawk, North Carolina, the Wright Flyer became the first powered, heavier-than-air machine to achieve controlled, sustained flight with a pilot aboard.'
    
    expect(page).to have_content(expected_text)
    
    page.save_screenshot('wright-brothers.png')
  end
end