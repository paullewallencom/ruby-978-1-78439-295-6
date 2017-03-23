'use strict';

// define the model to handle the data
var MockTodoList = function () {
	var store = {
		todos: []
  };
  
  store.all = function(){
    return this.todos;
  }
  
  store.add = function(todoText){
    var newTodo = {"text" : todoText, "done" : false};
    
    this.todos.push(newTodo);
    
    return newTodo;
  }
  
  store.unfinished = function(){
    return this.todos.filter(function(todo) {
      return (! todo.done)
    });
  }
  
  store.deleteAll = function() {
    this.todos = [];
    return this.todos;
  }
  
  store.deleteCompleted = function(){
    this.todos = this.unfinished();
    
    return this.todos;
  }

	return store;
};