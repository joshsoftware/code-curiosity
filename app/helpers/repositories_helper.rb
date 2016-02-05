module RepositoriesHelper

  def repository_uri
    return params[:repository][:source_url] if params[:repository].present?
  end
end
