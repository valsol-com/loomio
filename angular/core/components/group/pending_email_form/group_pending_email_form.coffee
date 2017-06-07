angular.module('loomioApp').directive 'groupPendingEmailForm', (FormService, FlashService, Records) ->
  scope: {group: '='}
  templateUrl: 'generated/components/group/pending_email_form/group_pending_email_form.html'
  controller: ($scope) ->

    $scope.form = Records.invitationForms.build
      groupId: $scope.group.id
      emails:  $scope.group.features.pending_emails

    $scope.$on 'emailsSubmitted', FormService.submit $scope, $scope.form,
      drafts: true
      submitFn: Records.invitations.sendByEmail
      prepareFn: (scope, model) ->
        $scope.form.emails = $scope.form.emails.join(',')
      successCallback: (response) =>
        $scope.$emit 'invitePendingComplete'
        switch response.invitations.length
          when 0 then $scope.noInvitations = true
          when 1 then FlashService.success 'invitation_form.messages.invitation_sent'
          else        FlashService.success 'invitation_form.messages.invitations_sent', count: response.invitations.length
