# app/models/scheduled_departure.rb
class ScheduledDeparture < ApplicationRecord
  belongs_to :cycler, class_name: 'Craft::Transport::Cycler'
  belongs_to :space_station, class_name: 'Settlement::SpaceStation'
end