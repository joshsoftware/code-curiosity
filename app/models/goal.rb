class Goal
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification

  field :name,         type: String
  field :description,  type: String
  field :points,       type: Integer
  field :bonus_points, type: Integer
  field :image_url,    type: String
  field :status,       type: Boolean, default: true

  validates :name, presence: true
  validates :points, numericality: { only_integer: true, greater_than: 0 }

  has_many :subscriptions
  has_many :goals

  def info
    self.class.info[name]
  end

  def self.info
    @info ||= YAML.load_file(Rails.root.join('config', 'goals.yml'))['goals']
  end

  def self.setup
    info.each do |name, info|
      goal = Goal.find_or_initialize_by(name: name)

      info.each{|f, v| goal[f] = v }
      goal.save!
    end
  end
end
