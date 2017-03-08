angular.module('loomioApp').directive 'pollBrainstormVoteForm', (AppConfig, Records, PollService, TranslationService, MentionService, KeyEventService) ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/brainstorm/vote_form/poll_brainstorm_vote_form.html'
  controller: ($scope) ->
    $scope.pollOptionNames = []
    $scope.submit = PollService.submitStance $scope, $scope.stance,
      prepareFn: ->
        $scope.stance.stanceChoicesAttributes = _.map $scope.pollOptionNames, (name) ->
          {poll_option_name: name}

    TranslationService.eagerTranslate $scope,
      reasonPlaceholder: 'poll_count_vote_form.reason_placeholder'

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
