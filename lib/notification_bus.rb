class NotificationBus

  # this combination of community and event is used as a hash key for listeners
  CommunityEvent = Struct.new(:community, :event)

  def self.configure
    yield self
  end

  def self.notify!(community, event)
    listeners[CommunityEvent.new(community.class, event.class)].map { |listener| listener.call(community, event) }
  end

  def self.listen(communities:, events:, &block)
    community_events_for(communities, events) { |community_event| listeners[community_event].add(block) }
  end

  def self.deafen(communities:, events:, &block)
    community_events_for(communities, events) { |community_event| listeners[community_event].delete(block) }
  end

  def self.clear
    @@listeners = nil
  end

  def self.listeners
    @@listeners ||= Hash.new { |hash, key| hash[key] = Set.new }
  end
  private_class_method :listeners

  def self.community_events_for(communities, events)
    communities = Array(communities).map { |c| "Communities::#{c.to_s.camelize}".constantize }
    events      = Array(events).map      { |e| "Events::#{e.to_s.camelize}".constantize }
    communities.product(events).each     { |ce| yield CommunityEvent.new(*ce) }
  end
  private_class_method :community_events_for

  def self.notify_loomio_group(kinds,
    mailer:              ThreadMailer,
    email:               proc {}, # <-- don't be afraid of these; they're just procs which we can call that do nothing!
    notify:              proc {},
    email_announcement:  email,
    notify_announcement: notify,
    live_update:         false,
    join_discussion:     false,
    also:                proc {})
    notify = email if notify == :same_as_email
    listen(communities: [:loomio_group, :loomio_users], events: kinds) do |community, event|
      email_proc  =  event.announcement ? email_announcement  : email
      notify_proc =  event.announcement ? notify_announcement : notify

      community.notify!          email_proc.call(event.eventable, event.custom_fields), event, mailer
      community.notify_in_app!   notify_proc.call(event.eventable, event.custom_fields), event
      community.live_update!     event if live_update
      community.join_discussion! event if join_discussion

      also.call(event)
    end
  end

end
