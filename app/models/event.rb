class Event < ActiveRecord::Base
  include HasTimeframe
  include PrettyUrlHelper

  KINDS = %w(new_discussion discussion_title_edited discussion_description_edited discussion_edited discussion_moved
             new_comment new_motion new_vote motion_close_date_edited motion_name_edited motion_description_edited
             motion_edited motion_closing_soon motion_closed motion_closed_by_user motion_outcome_created
             motion_outcome_updated membership_requested invitation_accepted user_added_to_group user_joined_group
             new_coordinator membership_request_approved comment_liked comment_replied_to user_mentioned invitation_accepted
             poll_created stance_created outcome_created poll_closed_by_user poll_expired poll_edited poll_closing_soon).freeze

  has_many :notifications, dependent: :destroy
  belongs_to :eventable, polymorphic: true
  belongs_to :discussion
  belongs_to :user

  scope :sequenced, -> { where('sequence_id is not null').order('sequence_id asc') }
  scope :chronologically, -> { order('created_at asc') }

  after_create :notify!
  after_create :call_thread_item_created
  after_destroy :call_thread_item_destroyed

  validates_inclusion_of :kind, in: KINDS
  validates_presence_of :eventable

  acts_as_sequenced scope: :discussion_id, column: :sequence_id, skip: lambda {|e| e.discussion.nil? || e.discussion_id.nil? }

  def active_model_serializer
    "Events::#{eventable.class.to_s.split('::').last}Serializer".constantize
  rescue NameError
    Events::BaseSerializer
  end

  # an event knows about the communities that it is a part of through its eventable.
  # this defaults to the loomio group, but can be modify for things like poll events,
  # which have their own network of communities
  def communities
    @communities ||= Communities::LoomioGroup.where(id: eventable.group.community.id)
  end

  def notify!
    communities.each { |community| NotificationBus.notify!(community, self) }
  end
  handle_asynchronously :notify!

  def build_notification_for(user)
    notifications.build(
      user:               user,
      actor:              notification_actor,
      url:                notification_url,
      translation_values: notification_translation_values
    )
  end

  private

  # defines the avatar which appears next to the notification
  def notification_actor
    @notification_actor ||= user || eventable.author
  end

  # defines the link that clicking on the notification takes you to
  def notification_url
    @notification_url ||= polymorphic_url(eventable)
  end

  # defines the values that are passed to the translation for notification text
  # by default we infer the values needed from the eventable class,
  # but this method can be overridden with any translation values for a particular event
  def notification_translation_values
    case eventable
    when Poll, Outcome then { name: notification_translation_name, title: notification_translation_title, poll_type: I18n.t(:"poll_types.#{eventable.poll.poll_type}").downcase }
    else                    { name: notification_translation_name, title: notification_translation_title }
    end
  end

  def notification_translation_name
    notification_actor&.name
  end

  def notification_translation_title
    case eventable
    when PaperTrail::Version              then eventable.item.title
    when Comment, CommentVote, Discussion then eventable.discussion.title
    when Group, Membership                then eventable.group.full_name
    when Poll, Outcome                    then eventable.poll.title
    when Motion                           then eventable.name
    end
  end

  def call_thread_item_created
    discussion.thread_item_created!(self) if discussion_id.present?
  end

  def call_thread_item_destroyed
    discussion.thread_item_destroyed!(self) if discussion_id.present?
  end
end
