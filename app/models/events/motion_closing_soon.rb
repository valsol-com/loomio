class Events::MotionClosingSoon < Event

  def self.publish!(motion)
    create(kind: "motion_closing_soon",
           eventable: motion).tap { |e| EventBus.broadcast('motion_closing_soon_event', e) }
  end

  private

  def notification_actor
    nil
  end
end
