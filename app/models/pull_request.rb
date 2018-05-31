class PullRequest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :number,              type: Integer
  field :created_on,          type: String
  field :comment_count,       type: Integer
  field :author_association,  type: String
  field :label,               type: DateTime

  has_many :commits
end
