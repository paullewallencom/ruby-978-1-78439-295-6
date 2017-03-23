'use strict';

// define the model to handle the data
var TodoList = function ($http) {
	var store = {};

  function returnTodos(response){
    return response.data.todos;
  }

  store.all = function(){
    return $http.get('/api/v1/todos').then(returnTodos);
  }

  store.add = function(todoText){
    var newTodo = {"text" : todoText, "done" : false};

    return $http.post('/api/v1/todos', newTodo).then(returnTodos);
  }

  store.deleteAll = function() {
    return $http.delete('/api/v1/todos').then(returnTodos);
  }

  store.deleteCompleted = function(){
    return $http.delete('/api/v1/todos/done').then(returnTodos);
  }

  store.toggleDone = function(id) {
    return $http.post('/api/v1/todos/' + id + '/toggle_done').then(returnTodos);
  }

	return store;
};