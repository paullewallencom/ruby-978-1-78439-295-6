'use strict';

angular.module('todoApp', [])
  .factory('TodoList', MockTodoList)
  .controller('TodoListController', [
    '$scope', 
    'TodoList', 
    TodoListController
  ]);
;