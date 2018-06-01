class PullRequest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :number,              type: Integer
  field :created_at_git,      type: String
  field :comment_count,       type: Integer
  field :author_association,  type: String
  field :label,               type: DateTime

  has_many :commits

  validates :number, :created_at_git, :author_association, :comment_count, presence: true
end
