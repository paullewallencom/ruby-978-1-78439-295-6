require_relative '../feature_helper'

RSpec.feature "Manage to-do items", :type => :feature do

  # As an office worker
  # In order to make sure I finish all my tasks for the day
  # And in order to know which tasks are still outstanding
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