require_relative '../api_helper'

RSpec.describe Todo::API, api: true, redis: true do
  # create a new browser session before each example
  let!(:browser) { RackTestBrowser.new_browser }

  def parsed_todos
    MultiJson.decode(browser.last_response.body)['todos']
  end

  context 'GET /api/v1/todos' do
    it 'returns an empty array at first' do
      browser.get '/api/v1/todos'

      expect(browser.last_response.status).to eq(200)
      expect(parsed_todos).to eq([])

      browser.post '/api/v1/todos', {'text' => 'my first todo'}
      browser.post '/api/v1/todos', {'text' => 'my second todo'}

      browser.get '/api/v1/todos'

      expect(browser.last_response.status).to eq(200)
      expect(parsed_todos.size).to eq(2)
      expect(parsed_todos[0]['text']).to eq('my first todo')
      expect(parsed_todos[1]['text']).to eq('my second todo')
    end
  end

  context 'POST /api/v1/todos' do
    it 'creates a new todo' do
      browser.post '/api/v1/todos', {'text' => 'my first todo'}
      expect(browser.last_response.status).to eq(201)
      expect(parsed_todos.size).to eq(1)
      expect(parsed_todos[0]['text']).to eq('my first todo')
    end
  end

  context 'DELETE /api/v1/todos' do
    it 'delete all todos' do
      browser.post '/api/v1/todos', {'text' => 'my first todo'}
      browser.post '/api/v1/todos', {'text' => 'my second todo'}

      browser.get '/api/v1/todos'

      expect(browser.last_response.status).to eq(200)
      expect(parsed_todos.size).to eq(2)

      browser.delete 'api/v1/todos'
      expect(browser.last_response.status).to eq(200)
      expect(parsed_todos).to eq([])
    end
  end

  context 'POST /api/v1/todos/:id/toggle_done' do
    it 'marks the todo as done' do
      browser.post '/api/v1/todos', {'text' => 'my first todo'}
      browser.post '/api/v1/todos', {'text' => 'my second todo'}

      browser.get '/api/v1/todos'

      expect(browser.last_response.status).to eq(200)
      expect(parsed_todos.size).to eq(2)
      expect(parsed_todos[0]['done']).to eq(false)

      id = parsed_todos[0]['id']

      browser.post "api/v1/todos/#{id}/toggle_done", ""
      expect(browser.last_response.status).to eq(200)
      expect(parsed_todos.size).to eq(2)
      expect(parsed_todos[0]['done']).to eq(true)
    end
  end

  context 'DELETE /api/v1/todos/done' do
    it 'marks the todo as done' do
      browser.post '/api/v1/todos', {'text' => 'my first todo'}
      browser.post '/api/v1/todos', {'text' => 'my second todo'}

      browser.get '/api/v1/todos'

      expect(browser.last_response.status).to eq(200)
      id = parsed_todos[0]['id']

      browser.post "api/v1/todos/#{id}/toggle_done", ""

      browser.delete "api/v1/todos/done"
      expect(browser.last_response.status).to eq(200)
      expect(parsed_todos.size).to eq(1)
      expect(parsed_todos[0]['text']).to eq('my second todo')
    end
  end
end