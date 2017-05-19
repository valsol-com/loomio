angular.module('loomioApp').directive 'pollsCard', ->
  scope: {model: '=', collection: '@', limit: '@?', title: '@?'}
  templateUrl: 'generated/components/polls_card/polls_card.html'
  controller: ($scope) ->
    $scope.pollCollection =
      polls: ->
        if parseInt($scope.limit) > 0
          _.take $scope.model[$scope.collection](), $scope.limit
        else
          $scope.model[$scope.collection]()
