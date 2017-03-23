# helpers to encapsulate CSS & HTML navigation
module WebInputHelpers
  def reset_page
    visit '/'
    
    if page.has_selector?('input[type=checkbox]')
      all('input[type=checkbox]').first.click    
      click_on 'Clear completed'
    end
  end

  def add_item(s)
    # add a newline to simulate pressing enter in the UI
    # this may not work with all browsers
    # alternative: find('#new-todo').native.send_keys(:return)
    s_with_newline = s.strip + "\n"
    
    fill_in "What needs to be done?", :with => s_with_newline
  end
  
  def check_item(s)
    items = all('#todo-list li')
    
    if items.size == 0
      fail 'No todos found'
    end
    
    # iterate over each todo item
    items.select do |node|
      # click the checkbox for the matching item
      if node.text == s 
        node.find('input[type=checkbox]').click
      end
    end
  end
  
  def screenshot(name=nil)
    name ||= 'screenshot' + Time.now.to_i.to_s + '.png'
    
    page.save_screenshot(name)
  end
end
