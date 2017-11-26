class Lesson < ApplicationRecord
  attr_accessor :starts_at_time, :starts_at_date, :ends_at_time, :ends_at_date

  belongs_to :sender, class_name: "User",  foreign_key: 'sender_id'
  belongs_to :receiver, class_name: "User", foreign_key: 'receiver_id'
  belongs_to :subject

  validate :sender_cannot_be_busy_on_lesson_time
  validate :receiver_cannot_be_busy_on_lesson_time
  validate :time_cannot_be_in_the_past
  validate :sender_should_be_available_on_lesson_time
  validate :receiver_should_be_available_on_lesson_time

  before_validation :serialize_time, on: :create

  after_create :notify_receiver
  after_update :notify_sender

  private

  def notify_receiver
    receiver.notifications.create(
      message: "You have been invited to study together",
      link: Rails.application.routes.url_helpers.user_lessons_path(receiver.id)
    )
  end

  def notify_sender
    sender.notifications.create(
      message: "#{receiver.name} has accepted your invation to study",
      link: Rails.application.routes.url_helpers.user_lessons_path(sender.id)
    )
  end

  def sender_should_be_available_on_lesson_time
    t = to_availability_week(time)
    sender.availability.each do |r|
      return true if r.include?(t)
    end
    errors.add(:time, "#{sender.name} is not available at that time")
  end

  def receiver_should_be_available_on_lesson_time
    t = to_availability_week(time)
    receiver.availability.each do |r|
      return true if r.include?(t)
    end
    errors.add(:time, "#{receiver.name} is not available at that time")
  end

  def to_availability_week range
    b = range.begin
    e = range.end
    Time.zone.parse("1996-01-01 #{b.to_s(:time)}") + (b.wday - 1).days ..
    Time.zone.parse("1996-01-01 #{e.to_s(:time)}") + (e.wday - 1).days
  end

  def sender_cannot_be_busy_on_lesson_time
    t = to_availability_week(time)
    errors.add(:time, "#{sender.name} is busy at that time") if
     sender.lessons.exists?([
       "(time && tstzrange(:begin, :end)) AND confirmed_at IS NOT NULL",
       begin: time.begin, end: time.end
     ]) ||
     sender.lessons.exists?([
       "(time && tstzrange(:begin, :end)) AND confirmed_at IS NOT NULL AND recurring IS NOT NULL",
       begin: t.begin, end: t.end
     ])
  end

  def receiver_cannot_be_busy_on_lesson_time
    t = to_availability_week(time)

    errors.add(:time, "#{receiver.name} is busy at that time") if
      receiver.lessons.exists?([
        "(time && tstzrange(:begin, :end)) AND confirmed_at IS NOT NULL",
        begin: time.begin, end: time.end
      ]) ||
      receiver.lessons.exists?([
        "(time && tstzrange(:begin, :end)) AND confirmed_at IS NOT NULL AND recurring IS NOT NULL",
        begin: t.begin, end: t.end
      ])
  end

  def time_cannot_be_in_the_past
    unless time.begin > Time.current || recurring
      errors.add(:time, "You can`t set up lesson on past days")
    end
  end

  def serialize_time
    self.time = Time.zone.parse("#{starts_at_date} #{starts_at_time}")..Time.zone.parse("#{ends_at_date} #{ends_at_time}")
    self.time = to_availability_week(time) if recurring
  end

  def self.time_for current_user, user
    self.select("time, recurring").where("(sender_id = ? OR receiver_id = ? OR sender_id = ? OR receiver_id = ?) AND confirmed_at IS NOT NULL",
      current_user.id ,current_user.id, user.id, user.id).to_json
  end
end
