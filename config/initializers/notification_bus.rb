require 'notification_bus'

NotificationBus.configure do |config|
  config.listen(
    communities: :loomio_group,
    events:      [:new_comment, :new_motion, :new_discussion]
  ) do |community, event|
    puts "loomio group community!"
  end

  config.listen(
    communities: :public,
    events:      :outcome_created
  ) do |community, event|
    puts "public community!"
  end
end
