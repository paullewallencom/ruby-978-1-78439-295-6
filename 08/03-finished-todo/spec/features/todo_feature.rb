require_relative '../feature_helper'

RSpec.feature "Manage to-do items", :type => :feature, :redis => true do

  # As a user
  # In order to keep track of what I need to do
  # And in order to keep track of what I’ve already finished
  # I want to add todo items to a list
  # And I want to mark them as completed

  include WebInputHelpers

  before(:example) { reset_page }

  scenario "add" do
    add_item "Learn Go"
    add_item "Review C"

    expect(page).to have_content 'Learn Go'
    expect(page).to have_content 'Review C'

    expect(page).to have_content '2 items left'
  end

  scenario 'mark as done' do
    add_item "Learn Go"
    add_item "Review C"

    expect(page).to have_content 'Learn Go'
    expect(page).to have_content 'Review C'

    expect(page).to have_content '2 items left'

    check_item 'Review C'

    expect(page).to have_completed_item 'Review C'
    expect(page).to_not have_completed_item 'Learn Go'

    expect(page).to have_content '1 item left'
  end
end