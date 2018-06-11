class MultiLineChart::User
  class << self
    def get
      users = User.collection.aggregate([match, project, group, sort])
      users.collect do |r|
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
        'auto_created' => false,
        'created_at' => { '$gt' => Date.parse('Apr 2016') }
      }
      }
    end

    def project
      {
        '$project' => {
        'month' => { '$month' => '$created_at'},
        'year' => {'$year' => '$created_at'}
      }
      }
    end

    def group
      {
        '$group' => {
        _id: {'month' => '$month', 'year' => '$year'},
        total: { '$sum' => 1 }
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
