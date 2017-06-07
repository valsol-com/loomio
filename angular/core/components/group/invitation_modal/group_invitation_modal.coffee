angular.module('loomioApp').factory 'GroupInvitationModal', ->
  templateUrl: 'generated/components/group/invitation_modal/group_invitation_modal.html'
  controller: ($scope, group) ->
    $scope.group = group.clone()

    $scope.$on 'inviteComplete', $scope.$close
