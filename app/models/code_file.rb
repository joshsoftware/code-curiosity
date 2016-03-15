class CodeFile
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,            type: String
  field :commits_count,   type: Integer, default: 0
  field :bugspots_score,  type: Integer, default: 0
  field :branches,        type: Array, default: []

  belongs_to :repository

  index({ name: 1 })
end
