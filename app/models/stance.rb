class Stance < ActiveRecord::Base
  include HasMentions

  ORDER_SCOPES = ['newest_first', 'oldest_first', 'priority_first', 'priority_last']

  is_mentionable  on: :reason

  belongs_to :poll, required: true
  has_many :stance_choices, dependent: :destroy
  has_many :poll_options, through: :stance_choices

  accepts_nested_attributes_for :stance_choices
  attr_accessor :visitor_attributes

  belongs_to :participant, polymorphic: true, required: true

  update_counter_cache :poll, :stances_count

  scope :latest, -> { where(latest: true) }

  scope :newest_first,   -> { order(created_at: :desc) }
  scope :oldest_first,   -> { order(created_at: :asc) }
  # scope :voters_a_to_z,  -> { joins(:participant).order('participants.name DESC') }
  # scope :voters_z_to_a,  -> { joins(:participant).order('participants.name ASC') }
  scope :priority_first, -> { joins(:poll_options).order('poll_options.priority ASC') }
  scope :priority_last,  -> { joins(:poll_options).order('poll_options.priority DESC') }

  validates :stance_choices, length: { minimum: 1 }
  validate :total_score_is_valid
  validate :participant_is_complete

  delegate :group, to: :poll, allow_nil: true
  delegate :can_add_options, to: :poll, allow_nil: true
  alias :author :participant

  def choice=(choice)
    if choice.kind_of?(Hash)
      self.stance_choices_attributes = poll.poll_options.where(name: choice.keys).map do |option|
        {poll_option_id: option.id,
         score: choice[option.name]}
      end
    elsif options = poll.poll_options.where(name: choice).presence
      self.stance_choices_attributes = options.map { |option| {poll_option_id: option.id} }
    elsif self.can_add_options
      Array(choice).each do |name|
        self.stance_choices.build(poll_option: self.poll.poll_options.build(name: name))
      end
    end
  end

  private

  def autosave_associated_records_for_stance_choices
    # :(
    stance_choices.map { |choice| choice.stance = self; choice.poll_option.poll = self.poll }
    stance_choices.map(&:save)
  end

  def total_score_is_valid
    return unless poll.poll_type == 'dot_vote'
    if stance_choices.map(&:score).sum > poll.custom_fields['dots_per_person'].to_i
      errors.add(:dots_per_person, "Too many dots")
    end
  end

  def participant_is_complete
    if participant&.name.blank?
      errors.add(:participant_name, I18n.t(:"activerecord.errors.messages.blank"))
      participant.errors.add(:name, I18n.t(:"activerecord.errors.messages.blank"))
    end
  end
end
