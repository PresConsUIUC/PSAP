class Event < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :assessments, join_table: 'events_assessments'
  has_and_belongs_to_many :assessment_questions, join_table: 'events_assessment_questions'
  has_and_belongs_to_many :formats
  has_and_belongs_to_many :institutions
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :repositories
  has_and_belongs_to_many :resources
  has_and_belongs_to_many :users

  validates :description, presence: true

  def readonly?
    !new_record?
  end

  def self.matching_params(params)
    q = "%#{params[:q]}%"
    event_level = params[:level]
    event_level = EventLevel::NOTICE if event_level.nil?
    begin_date = (params[:begin_date] && params[:begin_date].length > 3) ?
        parse_date(params[:begin_date]) : Time.new('1000')
    end_date = (params[:end_date] && params[:end_date].length > 3) ?
        parse_date(params[:end_date]) : Time.new('3000')

    Event.joins('LEFT JOIN users ON users.id = events.user_id').
        where('events.description LIKE ? OR users.username LIKE ? OR events.address LIKE ?', q, q, q).
        where('events.created_at >= ?', begin_date).
        where('events.created_at <= ?', end_date).
        where('events.event_level <= ?', event_level).
        order(created_at: :desc)
  end

  private

  def self.parse_date(date)
    return (date.length > 3) ? Time.new(*date.split('-')) : nil
  end

end
