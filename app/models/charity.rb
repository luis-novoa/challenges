class Charity < ActiveRecord::Base
  validates :name, presence: true

  def credit_amount(amount)
    update_attribute :total, total + amount
  end
end
