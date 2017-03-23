'use strict';

// define the angular controller to connect the model to the view
var TodoListController = function($scope, TodoList) {
  $scope.todos = TodoList.all();

  $scope.addTodo = function() {
    if ( (typeof $scope.newTodoText === 'string') && $scope.newTodoText.length > 0)  {
      TodoList.add($scope.newTodoText);
      $scope.newTodoText = '';
      $scope.todos = TodoList.all();
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
    $scope.todos = TodoList.deleteCompleted();
  };

  $scope.toggleDone = function(todo){
    if (todo.done) {
      $scope.unfinishedCount = $scope.unfinishedCount - 1;
    } else {
      $scope.unfinishedCount = $scope.unfinishedCount + 1;
    }
  };
};
