class Rate < ApplicationRecord
  belongs_to :rater, class_name: "<%= file_name.classify %>"
  belongs_to :rateable, polymorphic: true
  validates_numericality_of :stars, minimum: 1
end
