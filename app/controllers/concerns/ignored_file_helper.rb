module IgnoredFileHelper

  def find_ignored_file
    @ignored_file = FileToBeIgnored.where(id: params[:id]).first
  end
  
end