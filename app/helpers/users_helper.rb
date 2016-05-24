module UsersHelper

  def logged_in_user?
    current_user == @user
  end
end
