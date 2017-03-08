angular.module('loomioApp').directive 'pollBrainstormVoteForm', (AppConfig, Records, PollService, TranslationService, MentionService, KeyEventService) ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/brainstorm/vote_form/poll_brainstorm_vote_form.html'
  controller: ($scope) ->
    $scope.pollOptionNames = if $scope.stance.isNew()
      []
    else
      _.map $scope.stance.stanceChoices(), (choice) -> choice.pollOption().name

    $scope.submit = PollService.submitStance $scope, $scope.stance,
      prepareFn: ->
        $scope.stance.stanceChoicesAttributes = _.map $scope.pollOptionNames, (name) ->
          {poll_option_name: name}

    $scope.add = ->
      return if $scope.nameNotEntered()
      $scope.pollOptionNames.push($scope.newName)
      $scope.newName = ''

    $scope.remove = (name) ->
      $scope.pollOptionNames = _.pull $scope.pollOptionNames, name

    $scope.nameNotEntered = ->
      ($scope.newName or '').length <= 0

    TranslationService.eagerTranslate $scope,
      reasonPlaceholder: 'poll_count_vote_form.reason_placeholder'

    MentionService.applyMentions($scope, $scope.stance)
    KeyEventService.submitOnEnter($scope)
