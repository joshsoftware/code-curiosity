class MultiLineChart::Contribution
  class << self
    def get
      contributions = Commit.collection.aggregate([match, project, group, sort])
      contributions.collect do |r|
        [
          "#{Date::ABBR_MONTHNAMES[r['_id']['month']]} #{r['_id']['year']}",
          r['total']
        ]
      end
    end

    private

    def match
      {
        '$match' => {
        'commit_date' => { '$gt' => Date.parse('Apr 2016') }
      }
      }
    end

    def project
      {
        '$project' => {
        'month' => { '$month' => '$commit_date'},
        'year' => {'$year' => '$commit_date'},
        'auto_score' => 1
      }
      }
    end

    def group
      {
        '$group' => {
        _id: {'month' => '$month', 'year' => '$year'},
        total: { '$sum' => '$auto_score' }
      }
      }
    end

    def sort
      {
        '$sort' => {
        '_id.year' => 1,
        '_id.month' => 1
      }
      }
    end
  end
end
