class Commit
  include Mongoid::Document
  include Mongoid::Timestamps

  field :message, type: String
  field :commit_date, type: DateTime
  field :html_url, type: String

  belongs_to :member
  belongs_to :repository
  belongs_to :team

  has_many :scores, as: :scorable, dependent: :destroy

  validates :message, uniqueness: {:scope => :commit_date}

  def self.graph_data(start_date, end_date, type)
    last_commit = Commit.order(created_at: :asc).last
    title = last_commit.present? ? "Code Curiosity Stats (Last Updated: #{last_commit.created_at.strftime('%c')})" : "No Data"

    graph_series = []
    blank_row = [-1]*Team.count

    teams = Team.all.order(name: :asc)
    teams.each_with_index do |team, i|
       team.members.each do |member|
          data = blank_row.clone

          if type == "Team commits"
            data[i] = member.commits.between(commit_date: start_date..end_date).count
          end

          graph_series << { name: member.username, data: data }
       end
    end

    return { title: title, teams: teams.pluck(:name), graph_series: graph_series }
  end
end
