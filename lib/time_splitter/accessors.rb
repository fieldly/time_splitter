module TimeSplitter
  module Accessors

    INVALID_FROMAT = :invalid_format
    ZERO_DATE_TIME = DateTime.new(0, 1, 1, 0, 0, 0, '+00:00')

    def split_accessor(*attrs)
      options = attrs.extract_options!

      attrs.each do |attr|
        # Maps the setter for #{attr}_time to accept multipart-parameters for Time
        composed_of "#{attr}_time".to_sym, class_name: 'DateTime' if self.respond_to?(:composed_of)

        # Default instance of the attribute, used if setting an element of the
        # time attribute before the attribute was sent. Allows us to retrieve a
        # default value for +#{attr}+ to modify without explicitely overriding
        # the attr_reader. Defaults to a Time object with all fields set to 0.
        define_method("#{attr}_or_new") do
          self.send(attr) || options.fetch(:default, ->{ ZERO_DATE_TIME }).call
        end

        # Writers

        define_method("#{attr}_date=") do |date|
          return unless date.present?
          return if send("#{attr}_date") == INVALID_FROMAT # skip setting date if invalid time

          unless date.is_a?(Date) || date.is_a?(Time)
            begin
              if options[:date_format]
                date = Date.strptime(date.to_s, options[:date_format])
              else
                date = Date.parse(date.to_s)
              end
            rescue
              attributes["#{attr}_time"] = INVALID_FROMAT # set this, to prevent overriding invalid date by valid time
              send("#{attr}=", ZERO_DATE_TIME) # set zero date to allow validation in e.g. Rails
              return
            end
          end
          self.send("#{attr}=", self.send("#{attr}_or_new").change(year: date.year, month: date.month, day: date.day))
        end

        define_method("#{attr}_hour=") do |hour|
          return unless hour.present?
          self.send("#{attr}=", self.send("#{attr}_or_new").change(hour: hour, min: self.send("#{attr}_or_new").min))
        end

        define_method("#{attr}_min=") do |min|
          return unless min.present?
          self.send("#{attr}=", self.send("#{attr}_or_new").change(min: min))
        end

        define_method("#{attr}_time=") do |time|
          return unless time.present?
          return if send("#{attr}_time") == INVALID_FROMAT # skip setting time if invalid date

          unless time.is_a?(Date) || time.is_a?(Time)
            begin
              if options[:time_format]
                time = Time.strptime(time, options[:time_format])
              else
                time = Time.parse(time)
              end
            rescue
              attributes["#{attr}_date"] = INVALID_FROMAT # set this, to prevent overriding invalid time by valid date
              send("#{attr}=", ZERO_DATE_TIME) # set zero date to allow validation in e.g. Rails
              return
            end
          end
          self.send("#{attr}=", self.send("#{attr}_or_new").change(hour: time.hour, min: time.min))
        end

        # Readers
        define_method("#{attr}_date") do
          date = self.send(attr).try :to_date
          date && options[:date_format] ? date.strftime(options[:date_format]) : date
        end

        define_method("#{attr}_hour") do
          self.send(attr).try :hour
        end

        define_method("#{attr}_min") do
          self.send(attr).try :min
        end

        define_method("#{attr}_time") do
          time = self.send(attr)
          time && options[:time_format] ? time.strftime(options[:time_format]) : time
        end
      end
    end
  end
end
