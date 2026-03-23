# frozen_string_literal: true

class Portal < ApplicationRecord
  # Each portal must be paired with a destination portal
  belongs_to :destination_portal, class_name: 'Portal', optional: true

  # Validation: cannot be used unless paired
  validate :must_be_paired

  private

  def must_be_paired
    errors.add(:destination_portal, 'must be set for portal to function') if destination_portal.nil?
  end
end
