angular.module('loomioApp').controller 'StartGroupPageController', ($scope, $location, $rootScope, Records, ModalService, GroupModal, AbilityService) ->
  $rootScope.$broadcast('currentComponent', { page: 'startGroupPage', skipScroll: true })

  ModalService.open(GroupModal,
    preventClose: -> true,
    group: -> Records.groups.build
      name:         $location.search().name
      sourcePollId: $location.search().source_poll_id
  ) if AbilityService.isLoggedIn()

  return
