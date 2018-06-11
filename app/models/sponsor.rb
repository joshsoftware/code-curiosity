class Sponsor
  include Mongoid::Document

  field :name,          type: String
  field :is_individual, type: Boolean, default: false

  has_many :budgets, dependent: :destroy
  accepts_nested_attributes_for :budgets

  validates :name, presence: true
  validates :name, uniqueness: true
end
