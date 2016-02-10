class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content, type: String
  field :is_public, type: Boolean, default: false

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  validates :content, presence: true

  after_create do |c|
    c.commentable.inc(comments_count: 1)
  end

end
