class Events::PollClosingSoon < Event
  def self.publish!(poll)
    create(kind: "poll_closing_soon",
           user: poll.author,
           announcement: !!poll.events.find_by(kind: :poll_created)&.announcement,
           eventable: poll).tap { |e| EventBus.broadcast('poll_closing_soon_event', e) }
  end
end
