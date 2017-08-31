module RepoLeaders

  def leaders(round)
    map = %Q{
        function() {
          emit(this.user_id, this.judges_score || this.auto_score || 0);
        }
    }

    reduce = %Q{
      function(key, values) {
        return Array.sum(values);
      }
    }

    repo_ids = Repository.or(source_gh_id: gh_id).or(gh_id: gh_id).pluck(:id)

    result = Commit.where(round: round, :repository_id.in => repo_ids)
                   .map_reduce(map, reduce)
                   .out(inline: 1)
    leaders = result.to_a.sort!{|r1, r2| r2['value'] <=> r1['value'] }.first(10)
    leaders.each do |r|
      r['user'] = User.find(r['_id'])
    end

    return leaders
  end

end
