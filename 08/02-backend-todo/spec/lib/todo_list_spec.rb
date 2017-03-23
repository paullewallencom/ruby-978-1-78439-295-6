require_relative '../spec_helper'
require_relative '../../lib/todo_list'

RSpec.describe Todo::TodoList, redis: true do
  subject(:todo_list) { Todo::TodoList.new(::REDIS_CLIENT) }
  let(:todos) do
    [
      {
        'text' => 'Water the garden',
        'done' => false
      },
      {
        'text' => 'Get some sleep',
        'done' => false
      }
    ]
  end

  def todos_with_ids(ids)
    todos.each_with_index.map do |hsh, i|
      hsh['id'] = ids[i]
      hsh
    end
  end

  def get_raw_hash
    ::REDIS_CLIENT.hgetall(described_class::HASH_NAME)
  end

  context '.new' do
    it 'expects a Redis client' do
      expect{
        described_class.new(:foo)
      }.to raise_error('Expected a Redis instance, got Symbol')
    end

    it 'sets @redis_client' do
      tl = described_class.new(::REDIS_CLIENT)

      actual = tl.instance_variable_get(:@redis_client)

      expect(actual).to eq(::REDIS_CLIENT)
    end
  end

  context '#add' do
    it 'stores the todo in redis' do
      expect(get_raw_hash.size).to eq(0)

      todo_list.add(todos.first['text'])

      raw_hash = get_raw_hash
      expect(raw_hash.size).to eq(1)

      actual   = MultiJson.decode(raw_hash.values.first)
      expected = todos.first

      expect(actual['text']).to eq(expected['text'])
    end

    it 'returns the ID of added todo' do
      expect(get_raw_hash.size).to eq(0)

      id1 = todo_list.add(todos[0]['text'])
      id2 = todo_list.add(todos[1]['text'])

      expected1 = MultiJson.decode(get_raw_hash[id1])
      expected2 = MultiJson.decode(get_raw_hash[id2])

      expected1.delete('id')
      expected1.delete('ts')
      expected2.delete('id')
      expected2.delete('ts')

      expect(expected1).to eq(todos[0])
      expect(expected2).to eq(todos[1])
    end
  end

  context '#all' do
    it 'returns all todos' do
      expect(todo_list.all).to eq([])

      id1 = todo_list.add(todos[0]['text'])
      id2 = todo_list.add(todos[1]['text'])

      actual   = todo_list.all
      expected = todos_with_ids([id1, id2])
      expect(actual).to eq(expected)
    end
  end

  context '#delete_all' do
    it 'deletes all todos and returns an empty array' do
      expect(todo_list.all).to eq([])

      id1 = todo_list.add(todos[0]['text'])
      id2 = todo_list.add(todos[1]['text'])

      all_todos = todos_with_ids([id1, id2])
      expect(todo_list.all).to eq(all_todos)

      actual = todo_list.delete_all
      expect(todo_list.all).to eq([])
      expect(actual).to eq([])
    end
  end

  context '#toggle_done' do
    it 'updates an item as done by ID and returns the updated item' do
      todo_list.add(todos[0]['text'])
      id = todo_list.add(todos[1]['text'])

      actual = todo_list.toggle_done(id)

      expect(actual['text']).to eq(todos.last['text'])
      expect(actual['done']).to eq(true)

      expect(todo_list.all.last['done']).to eq(true)
    end
  end

  context '.delete_finished' do
    let(:finished_todos) do
      [
        {
          'text' => 'Buy cheese',
          'done' => true
        },
        {
          'text' => 'Fix the computer',
          'done' => true
        }
      ]
    end
    it 'deletes finished todos and returns all remaining todos' do
      id1 = todo_list.add(todos[0]['text'])
      id2 = todo_list.add(todos[1]['text'])
      id3 = todo_list.add(finished_todos[0]['text'])
      id4 = todo_list.add(finished_todos[1]['text'])

      todo_list.toggle_done(id3)
      todo_list.toggle_done(id4)

      actual    = todo_list.delete_finished
      expected  = todos_with_ids([id1, id2])

      expect(actual).to eq(expected)
      expect(todo_list.all).to eq(expected)
    end
  end
end