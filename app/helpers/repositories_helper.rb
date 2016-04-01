module RepositoriesHelper

  def repository_uri(type = :source_url)
    return params[:repository][:source_url] if params[:repository].present?
  end

  def popular_repository_label
    "Repository with minimum #{REPOSITORY_CONFIG['popular']['stars']} stars."
  end
end
