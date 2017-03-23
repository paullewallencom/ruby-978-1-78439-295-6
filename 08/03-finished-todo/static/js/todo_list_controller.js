'use strict';

// define the angular controller to connect the model to the view
var TodoListController = function($scope, TodoList) {
  TodoList.all().then(function(todos){
    $scope.todos = todos;
  });

  $scope.addTodo = function() {
    if ( (typeof $scope.newTodoText === 'string') && $scope.newTodoText.length > 0)  {
      TodoList.add($scope.newTodoText).then(function(todos){
        $scope.newTodoText = '';

        $scope.todos = todos;
      });
    }
  };

  $scope.$watchCollection('todos', function(newVal){
    if (newVal){
      $scope.unfinishedCount = newVal.filter(function(todo){
        return ! todo.done;
      }).length
    }
  });

  $scope.clearCompleted = function() {
    TodoList.deleteCompleted().then(function(todos){
      $scope.todos = todos;
    });
  };

  $scope.toggleDone = function(todo) {
    TodoList.toggleDone(todo.id).then(function(todos){
      $scope.todos = todos;
    });
  }
};
