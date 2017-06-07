angular.module('loomioApp').factory 'GroupModal', ->
  templateUrl: 'generated/components/group/modal/group_modal.html'
  controller: ($scope, group) ->
    $scope.group = group.clone()

    $scope.currentStep = 'create'

    $scope.$on 'createComplete', (event, group) ->
      if !$scope.group.isNew() or $scope.group.parentId
        $scope.$close()
      else
        $scope.group = group
        $scope.currentStep = if group.hasPendingEmails()
          'invitePending'
        else
          'inviteNew'

    $scope.$on 'invitePendingComplete', -> $scope.currentStep = 'inviteNew'
    $scope.$on 'inviteComplete', $scope.$close
