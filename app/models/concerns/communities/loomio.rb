module Communities::Loomio
  def notify!(user_ids, event, mailer)
    recipients_for(user_ids, event).each do |recipient|
      mailer.send(event.kind, recipient, event).deliver_now
    end
  end

  def notify_in_app!(user_ids, event)
    event.notifications.import(recipients_for(user_ids, event).map do |recipient|
      event.build_notification_for(recipient)
    end)
  end

  private

  def recipients_for(user_ids, event)
    members.where(id: Array(user_ids)).without(event.user)
  end
end
