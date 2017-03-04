class Events::UserMentioned < Event
  def self.publish!(model, actor, mentioned_user)
    create(kind: 'user_mentioned',
           eventable: model,
           user: actor,
           custom_fields: { mentioned_user_id: mentioned_user.id },
           created_at: model.created_at).tap { |e| EventBus.broadcast('user_mentioned_event', e) }
  end
end
