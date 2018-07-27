class TimeResultPresenter
  attr_accessor :minutes, :seconds, :thousands
  attr_reader :display_hours, :display_thousands

  def self.from_thousands(time_in_thousands)
    thousands = time_in_thousands % 1000
    seconds_remaining = (time_in_thousands - thousands) / 1000
    seconds = seconds_remaining % 60
    minutes = (seconds_remaining - seconds) / 60
    new(minutes, seconds, thousands)
  end

  def initialize(minutes, seconds, thousands, display_hours: nil, display_thousands: nil)
    @minutes = minutes.to_i
    @seconds = seconds.to_i
    @thousands = thousands.to_i
    @display_hours = display_hours
    @display_thousands = display_thousands
  end

  def full_time
    return unless minutes.positive? || seconds.positive? || thousands.positive?
    "#{hours_minutes_string}:#{seconds_string}#{thousands_string}"
  end

  private

  # convert thousands into a string forma: ".XXX"
  # if the number of thousands happens to be a multiple
  # of 100, we assume that we only have 0.1 second precision,
  # and thus we only print ".X"
  def thousands_string
    if thousands.zero?
      if display_thousands
        return ".000"
      else
        return ""
      end
    end

    if (thousands % 100).zero? && !display_thousands
      ".#{(thousands / 100)}"
    else
      ".#{thousands.to_s.rjust(3, '0')}"
    end
  end

  def hours_minutes_string
    hours = minutes / 60
    if hours.positive? || display_hours
      remaining_minutes = minutes % 60
      "#{hours}:#{remaining_minutes.to_s.rjust(2, '0')}"
    else
      minutes.to_s
    end
  end

  def seconds_string
    seconds.to_s.rjust(2, "0")
  end
end
