angular.module('loomioApp').directive 'pollCommonDirective', ($compile, $injector) ->
  scope: {poll: '=?', stance: '=?', back: '=?', name: '@'}
  link: ($scope, element) ->
    $scope.poll = $scope.poll or $scope.stance.poll()

    qualifier = ->
      if $injector.has(_.camelCase("poll_#{$scope.poll.pollType}_#{$scope.name}_directive"))
        $scope.poll.pollType
      else
        'common'

    $scope.poll = $scope.stance.poll() if $scope.stance and !$scope.poll
    element.append $compile("<poll_#{qualifier()}_#{$scope.name} poll='poll' stance='stance' back='back' />")($scope)
