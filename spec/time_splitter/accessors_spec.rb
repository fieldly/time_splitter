require 'active_support/all'
require_relative "../../lib/time_splitter/accessors.rb"

describe TimeSplitter::Accessors do
  let(:model) { Model.new() }
  before do
    class ModelParent; attr_accessor :starts_at; end
    class Model < ModelParent; attr_accessor :starts_at, :attributes; end
    Model.extend(TimeSplitter::Accessors)
    Model.split_accessor(:starts_at)
  end

  describe "#starts_at" do
    it 'does not override the default reader for the field' do
      class Model; def starts_at; 5; end; end
      expect(model.starts_at).to eq 5
    end

    it 'correctly returns nil if not set' do
      expect(model.starts_at).to eq nil
    end
  end

  describe "split datetime methods" do
    context 'when #starts_at is nil' do
      describe 'overriding the default time' do
        before { Model.split_accessor :starts_at, default: ->{ DateTime.new(1111, 2, 3, 4, 5, 0, '+7') } }

        it 'sets the date on the new default' do
          model.starts_at_date = '2222-5-6'
          expect(model.starts_at).to eq DateTime.new(2222, 5, 6, 4, 5, 0, '+7')
          expect(model.starts_at_date).to eq Date.new(2222, 5, 6)
        end

        it 'sets zero date if invalid date format' do
          model.starts_at_date = 'invalid'
          expect(model.starts_at).to eq DateTime.new(0, 1, 1, 0, 0, 0)
          expect(model.starts_at_date).to eq Date.new(0, 1, 1)
        end

        it 'sets zero date if invalid time format' do
          model.starts_at_time = 'invalid'
          expect(model.starts_at).to eq DateTime.new(0, 1, 1, 0, 0, 0)
          expect(model.starts_at_time).to eq Date.new(0, 1, 1)
        end

        it 'sets the hour on the new default' do
          model.starts_at_hour = 9
          expect(model.starts_at).to eq DateTime.new(1111, 2, 3, 9, 5, 0, '+7')
          expect(model.starts_at_hour).to eq 9
        end

        it 'sets the minute on the new default' do
          model.starts_at_min = 20
          expect(model.starts_at).to eq DateTime.new(1111, 2, 3, 4, 20, 0, '+7')
          expect(model.starts_at_min).to eq 20
        end

        it 'sets the time on the new default' do
          model.starts_at_time = '09:22'
          expect(model.starts_at).to eq DateTime.new(1111, 2, 3, 9, 22, 0, '+7')
          expect(model.starts_at_time).to eq DateTime.new(1111, 2, 3, 9, 22, 0, '+7')
        end
      end

      describe "#starts_at_date" do
        it "returns nil" do
          expect(model.starts_at_date).to be_nil
        end

        it "lets you modify the format" do
          Model.split_accessor(:starts_at, date_format: "%D")
          expect(model.starts_at_date).to be_nil
        end

        it "sets the appropiate parts of #starts_at" do
          model.starts_at_date = Time.new(1111, 1, 1)
          expect(model.starts_at).to eq Time.new(1111, 1, 1, 0, 0, 0, '+00:00')
        end

        it "can set from a string" do
          model.starts_at_date = "1111-01-01"
          expect(model.starts_at).to eq Time.new(1111, 1, 1, 0, 0, 0, '+00:00')
        end

        it "can set from a string when format is modified" do
          Model.split_accessor(:starts_at, date_format: "%m-%d-%Y")
          model.starts_at_date = "12-31-1111"
          expect(model.starts_at).to eq Time.new(1111, 12, 31, 0, 0, 0, '+00:00')
        end

        it "can set from a date when format is modified" do
          Model.split_accessor(:starts_at, date_format: "%m-%d-%Y")
          model.starts_at_date = Time.new(1111, 12, 31, 0, 0, 0, '+00:00')
          expect(model.starts_at).to eq Time.new(1111, 12, 31, 0, 0, 0, '+00:00')
        end

        it "is nil if the string is empty" do
          model.starts_at_date = ""
          expect(model.starts_at).to be_nil
        end
      end

      describe "#starts_at_hour" do
        it "returns nil" do
          expect(model.starts_at_hour).to be_nil
        end

        it "sets the hour of starts_at" do
          model.starts_at_hour = 11
          expect(model.starts_at).to eq Time.new(0, 1, 1, 11, 0, 0, '+00:00')
        end

        it "is nil if the string is empty" do
          model.starts_at_hour = ""
          expect(model.starts_at).to be_nil
        end
      end

      describe "#starts_at_min" do
        it "returns nil" do
          expect(model.starts_at_min).to be_nil
        end

        it "sets the minute of #starts_at" do
          model.starts_at_min = 55
          expect(model.starts_at).to eq Time.new(0, 1, 1, 0, 55, 0, '+00:00')
        end

        it "is nil if the string is empty" do
          model.starts_at_min = ""
          expect(model.starts_at).to be_nil
        end
      end

      describe '#starts_at_time' do
        it 'returns nil' do
          expect(model.starts_at_time).to be_nil
        end

        it "lets you modify the time format" do
          Model.split_accessor(:starts_at, time_format: "%I:%M%p")
          expect(model.starts_at_time).to be_nil
        end

        it 'sets the hour and minute of #starts_at' do
          model.starts_at_time = '08:33'
          expect(model.starts_at).to eq Time.new(0, 1, 1, 8, 33, 0, '+00:00')
        end

        it 'is nil if the string is empty' do
          model.starts_at_time = ''
          expect(model.starts_at).to be_nil
        end
      end
    end

    context 'when modifying #starts_at' do
      before { model.starts_at = Time.new(2222, 12, 22, 13, 44, 0, '+00:00') }

      describe "#starts_at_date" do
        it "returns the model's starts_at date" do
          expect(model.starts_at_date).to eq Date.new(2222, 12, 22)
        end

        it "lets you modify the format" do
          Model.split_accessor(:starts_at, date_format: "%D")
          expect(model.starts_at_date).to eq "12/22/22"
        end

        it "sets the appropiate parts of #starts_at" do
          model.starts_at_date = Time.new(1111, 1, 1)
          expect(model.starts_at).to eq Time.new(1111, 1, 1, 13, 44, 0, '+00:00')
        end

        it "can set from a string" do
          model.starts_at_date = "1111-01-01"
          expect(model.starts_at).to eq Time.new(1111, 1, 1, 13, 44, 0, '+00:00')
        end

        it "uses the default if the string is empty" do
          model.starts_at_date = ""
          expect(model.starts_at).to eq Time.new(2222, 12, 22, 13, 44, 0, '+00:00')
        end
      end

      describe "#starts_at_hour" do
        it "returns the hour" do
          expect(model.starts_at_hour).to eq 13
        end

        it "sets the hour of starts_at" do
          model.starts_at_hour = 11
          expect(model.starts_at).to eq Time.new(2222, 12, 22, 11, 44, 0, '+00:00')
        end

        it "uses the default if the string is empty" do
          model.starts_at_hour = ""
          expect(model.starts_at).to eq Time.new(2222, 12, 22, 13, 44, 0, '+00:00')
        end
      end

      describe "#starts_at_min" do
        it "returns the min" do
          expect(model.starts_at_min).to eq 44
        end

        it "sets the minute of #starts_at" do
          model.starts_at_min = 55
          expect(model.starts_at).to eq Time.new(2222, 12, 22, 13, 55, 0, '+00:00')
        end

        it "uses the default if the string is empty" do
          model.starts_at_min = ""
          expect(model.starts_at).to eq Time.new(2222, 12, 22, 13, 44, 0, '+00:00')
        end
      end

      describe '#starts_at_time' do
        it 'returns the time' do
          expect(model.starts_at_time).to eq Time.new(2222, 12, 22, 13, 44, 0, '+00:00')
        end

        it "lets you modify the time format" do
          Model.split_accessor(:starts_at, time_format: "%I:%M%p")
          expect(model.starts_at_time).to eq "01:44PM"
        end

        it "can set from a string when format is modified" do
          Model.split_accessor(:starts_at, time_format: "%k-%M")
          model.starts_at_time = "23-59"
          expect(model.starts_at).to eq Time.new(2222, 12, 22, 23, 59, 0, '+00:00')
        end

        it 'sets the hour and minute of #starts_at' do
          model.starts_at_time = '08:33'
          expect(model.starts_at).to eq Time.new(2222, 12, 22, 8, 33, 0, '+00:00')
        end

        it 'uses the default if the string is empty' do
          model.starts_at_time = ''
          expect(model.starts_at).to eq Time.new(2222, 12, 22, 13, 44, 0, '+00:00')
        end
      end
    end
  end
end
