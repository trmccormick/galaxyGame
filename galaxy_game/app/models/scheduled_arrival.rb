# app/models/scheduled_arrival.rb
class ScheduledArrival < ApplicationRecord
  belongs_to :cycler, class_name: 'Craft::Transport::Cycler'
  belongs_to :space_station, class_name: 'Settlement::SpaceStation'
end