class Events::NewDiscussion < Event
  include Events::LiveUpdate

  def self.publish!(discussion)
    create(kind: 'new_discussion',
           announcement: discussion.make_announcement,
           eventable: discussion).tap { |e| EventBus.broadcast('new_discussion_event', e) }
  end
end
