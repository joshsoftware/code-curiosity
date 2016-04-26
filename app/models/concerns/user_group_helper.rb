module UserGroupHelper
  extend ActiveSupport::Concern

  def assing_group
    group = 1

    USER_GROUPS.each do |group_index, criteria|
      if criteria['default'] == true
        group = group_index
      else
        repos = self.repositories.where({
          owner: self.github_handle,
          :stars.gt => criteria['own_repositories']['stars']
        })

        if repos.count >= criteria['own_repositories']['count']
          group = group_index
        end
      end
    end

    self.set(level: group)
    return group
  end
end
