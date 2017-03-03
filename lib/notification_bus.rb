class NotificationBus

  # this combination of community and event is used as a hash key for listeners
  CommunityEvent = Struct.new(:community, :event)

  def self.configure
    yield self
  end

  def self.notify!(community, event)
    listeners[CommunityEvent.new(community.class, event.class)].map(&:call)
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

end
