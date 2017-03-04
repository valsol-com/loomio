require 'notification_bus'

NotificationBus.configure do |config|
  # here we are asked to give an event kind and a series of options which
  # define the notification behaviour

  # Each proc accepts an eventable, and returns a list of user ids to notify or email.

  #

  # NB that the user of the event will never receive emails or notifications
  # about that event (given that they performed the action; they know about it!)

  # if the 'notify' option is set to :same_as_email, the users who are emailed will
  # also receive an in-app notification

  # events set to 'live_update' will publish themselves through to clients
  # events set to 'join_discussion' will update the discussion reader of the user for that discussion to 'loud'

  config.notify_loomio_group [:discussion_moved, :stance_created],
    live_update:     true

  config.notify_loomio_group [:motion_closed_by_user, :motion_outcome_created, :motion_outcome_updated],
    live_update:     true,
    join_discussion: true

  config.notify_loomio_group :new_coordinator,
    notify: proc { |membership| membership.user_id }

  config.notify_loomio_group :comment_liked,
    notify: proc { |comment_vote|
      comment = comment_vote.comment
      comment.author_id unless !comment || !comment.group.memberships.find_by(user: comment.author)
    },
    live_update: true

  config.notify_loomio_group :invitation_accepted,
    notify: proc { |membership| membership.inviter_id }

  config.notify_loomio_group :comment_replied_to,
    email:  proc { |comment| comment.parent.author_id },
    notify: :same_as_email,
    live_update: true

  config.notify_loomio_group :membership_request_approved,
    mailer: UserMailer,
    email:  proc { |membership| membership.user_id },
    notify: :same_as_email

  config.notify_loomio_group :membership_requested,
    mailer: GroupMailer,
    email:  proc { |group| group.admins.active.pluck(:id) },
    notify: :same_as_email

  config.notify_loomio_group :new_vote,
    email:  proc { |vote| Queries::UsersByVolumeQuery.loud(vote.discussion).without(vote.author).pluck(:id) },
    live_update:     true,
    join_discussion: true

  config.notify_loomio_group :motion_closed,
    email:  proc { |motion| motion.author_id },
    notify: proc { |motion| Queries::UsersByVolumeQuery.normal_or_loud(motion.discussion).pluck(:id) }

  config.notify_loomio_group :motion_outcome_created,
    email:  proc { |motion| Queries::UsersByVolumeQuery.normal_or_loud(motion.discussion).without(motion.outcome_author).pluck(:id) },
    notify: :same_as_email,
    live_update:     true,
    join_discussion: true

  config.notify_loomio_group :motion_closing_soon,
    email:  proc { |motion|
      User.distinct.where.any_of(
        Queries::UsersByVolumeQuery.normal_or_loud(motion.discussion),
        User.email_proposal_closing_soon_for(motion.group)
      ).pluck(:id)
    },
    notify: proc { |motion| Queries::UsersByVolumeQuery.normal_or_loud(motion.discussion).pluck(:id) }

  config.notify_loomio_group [:new_discussion, :new_motion],
    email_announcement: proc { |model|
      Queries::UsersByVolumeQuery.normal_or_loud(model.discussion)
                                 .without(model.discussion.author)
                                 .without(model.discussion.mentioned_group_members)
                                 .pluck(:id)
    },
    email: proc { |model|
      Queries::UsersByVolumeQuery.loud(model.discussion)
                                 .without(model.discussion.author)
                                 .without(model.discussion.mentioned_group_members)
                                 .pluck(:id)
    },
    live_update:     true,
    join_discussion: true

  config.notify_loomio_group :new_comment,
    email: proc { |comment|
      Queries::UsersByVolumeQuery.loud(comment.discussion)
                                 .without(comment.author)
                                 .without(comment.mentioned_group_members)
                                 .without(comment.parent_author)
                                 .pluck(:id)
    },
    live_update:     true,
    join_discussion: true

  config.notify_loomio_group :poll_created,
    mailer:              PollMailer,
    email_announcement:  proc { |poll| Queries::UsersByVolumeQuery.normal_or_loud(poll.discussion) },
    email:               proc { |poll| Queries::UsersToMentionQuery.for(poll).where(email_when_mentioned: true).pluck(:id) },
    notify_announcement: proc { |poll| poll.group.member_ids },
    notify:              proc { |poll| Queries::UsersToMentionQuery.for(poll).pluck(:id) },
    live_update: true

  config.notify_loomio_group :poll_edited,
    mailer:              PollMailer,
    email_announcement:  proc { |version| version.item.participants },
    email:               proc { |version| Queries::UsersToMentionQuery.for(version.item).where(email_when_mentioned: true).pluck(:id) },
    notify_announcement: proc { |version| version.item.participants },
    notify:              proc { |version| Queries::UsersToMentionQuery.for(version.item).pluck(:id) },
    live_update: true

  config.notify_loomio_group :poll_closing_soon,
    mailer:              PollMailer,
    email_announcement:  proc { |poll| Queries::UsersByVolumeQuery.normal_or_loud(poll.discussion) },
    notify_announcement: proc { |poll| poll.group.member_ids },
    also:                proc { |event| PollMailer.poll_closing_soon_author(event.user, event).deliver_now }

  config.notify_loomio_group :poll_expired,
    mailer:              PollMailer,
    email:               proc { |poll| poll.author_id },
    notify:              :same_as_email

  config.notify_loomio_group :outcome_created,
    mailer:              PollMailer,
    email_announcement:  proc { |poll| Queries::UsersByVolumeQuery.normal_or_loud(poll.discussion) },
    email:               proc { |poll| Queries::UsersToMentionQuery.for(poll).where(email_when_mentioned: true).pluck(:id) },
    notify_announcement: proc { |poll| poll.group.member_ids },
    notify:              proc { |poll| Queries::UsersToMentionQuery.for(poll).pluck(:id) }

  config.notify_loomio_group :user_added_to_group,
    mailer:              UserMailer,
    email:               proc { |membership| membership.user_id },
    notify:              :same_as_email

  config.notify_loomio_group :user_mentioned,
    email:               proc { |_, custom_fields| custom_fields['mentioned_user_id'].to_i },
    notify:              proc { |_, custom_fields| User.where(id: custom_fields['mentioned_user_id'].to_i, email_when_mentioned: true).pluck(:id) }

end
