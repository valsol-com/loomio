class Communities::LoomioGroup < Communities::Base
  include Communities::Loomio
  set_community_type :loomio_group
  set_custom_fields  :group_key

  validates :group, presence: true

  def to_user_community
    Communities::LoomioUsers.new(loomio_user_ids: members.pluck(:id), group_key: self.group_key)
  end

  def group
    @group = nil unless @group&.key == self.group_key
    @group ||= Group.find_by(key: self.group_key)
  end

  def group=(group)
    self.group_key = group.key
  end

  def includes?(member)
    member.is_admin_of?(self.group) ||
    (member.is_member_of?(self.group) && group.members_can_vote?)
  end

  def members
    @members ||= group.members
  end

  def join_discussion!(event)
    DiscussionReader.for_model(event.eventable).update_reader(read_at: event.created_at, participate: true, volume: :loud)
  end

  def live_update!(event)
    MessageChannelService.publish(EventCollection.new(event).serialize!, to: group)
  end

  private

  def recipients_for(ids, event)
    members.where(id: Array(recipient_ids)).without(event.user)
  end
end
