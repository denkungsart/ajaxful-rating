class Car < ApplicationRecord
  ajaxful_rateable stars: 10, dimensions: [:speed, :reliability, :price]
end
