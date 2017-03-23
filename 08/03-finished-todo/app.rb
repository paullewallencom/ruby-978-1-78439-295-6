require 'sinatra/base'
require 'multi_json'

require_relative 'initializers/redis'
require_relative 'lib/todo_list'

module Todo
end

class Todo::API < Sinatra::Base
  helpers do
    def todo_list
      @todo_list = Todo::TodoList.new(::REDIS_CLIENT)
    end
  end

  get '/api/v1/todos' do
    todos = todo_list.all
    MultiJson.encode({'todos' => todos})
  end

  post '/api/v1/todos' do
    todo_list.add(params['text'])
    todos = todo_list.all

    status 201
    MultiJson.encode({'todos' => todos})
  end

  post '/api/v1/todos/:id/toggle_done' do
    todo_list.toggle_done(params['id'])
    todos = todo_list.all

    status 200
    MultiJson.encode({'todos' => todos})
  end

  delete '/api/v1/todos' do
    todos = todo_list.delete_all
    MultiJson.encode({'todos' => todos})
  end

  delete '/api/v1/todos/done' do
    todos = todo_list.delete_finished
    MultiJson.encode({'todos' => todos})
  end
end