angular.module('loomioApp').directive 'pollBrainstormForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/brainstorm/form/poll_brainstorm_form.html'
  controller: ($scope, FormService, PollService, KeyEventService, TranslationService) ->
    $scope.submit = PollService.submitPoll $scope, $scope.poll,

    TranslationService.eagerTranslate $scope,
      titlePlaceholder:   'poll_brainstorm_form.title_placeholder'
      detailsPlaceholder: 'poll_brainstorm_form.details_placeholder'
      actionPlaceholder:  'poll_brainstorm_form.action_placeholder'

    KeyEventService.submitOnEnter($scope)
