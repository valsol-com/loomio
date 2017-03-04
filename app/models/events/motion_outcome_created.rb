class Events::MotionOutcomeCreated < Event
  def self.publish!(motion)
    create(kind: "motion_outcome_created",
           eventable: motion,
           discussion: motion.discussion,
           user: motion.outcome_author).tap { |e| EventBus.broadcast('motion_outcome_created_event', e) }
  end

  private

  def notification_actor
    eventable.outcome_author
  end
end
