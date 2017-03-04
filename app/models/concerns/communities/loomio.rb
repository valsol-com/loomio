module Communities::Loomio
  def notify!(user_ids, event, options = {})
    recipients_for(user_ids, event).each do |recipient|
      event.mailer.send(event.kind, recipient, event)
    end
  end

  def notify_in_app!(user_ids, event, options = {})
    event.notifications.import(recipients_for(user_ids, event).map do |recipient|
      event.build_notification_for(recipient)
    end)
  end

  private

  def recipients_for(ids, event)
    members.where(id: Array(recipient_ids)).without(event.user)
  end
end
