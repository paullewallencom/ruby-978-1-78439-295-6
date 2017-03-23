'use strict';

angular.module('todoApp', [])
  .factory('TodoList', [
    '$http', 
    TodoList
  ])
  .controller('TodoListController', [
    '$scope', 
    'TodoList', 
    TodoListController
  ]);
;