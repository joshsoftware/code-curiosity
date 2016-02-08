class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :current_round

  def current_round
    @rounds = Round.order(from_date: :desc)
    @current_round = if session[:current_round]
                       Round.find(session[:current_round])
                     else
                       Round.find_by({status: 'open'})
                     end
  end
  helper_method :current_round

  # common polymorphic method for scoring.
  def score
    rank = params.delete(:rank)
    begin
      # This can potentially raise a NameError for an unknown model
      model = params.keys.first.titleize.constantize
      @scorable = model.find(params.values.first)

      # If the object is not found, there's nothing we can do about it anyway!
      if @scorable
        # Check if the score is to be updated or a new one!
        # This can potentially raise a NoMethodError for scores, incase the
        # model is not polymorphic with Scores.
        score = @scorable.scores.where(user: current_user).first
        if score
          # Special condition: If the judge selectes the blank option, it means
          # he is not intersted in ranking this item. Delete the score.
          if rank.empty?
            score.delete
          else
            # Update the new ranking.
            score.rank = rank
            score.save!
          end
        else
          @scorable.scores.create!(rank: rank, user: current_user)
        end
      end
    rescue NameError, NoMethodError => e
      # Ignore -- otherwise raise hell!
    end
  end

  protected

  def after_sign_in_path_for(resource)
    if session[:subscription_url]
      redirect_to session[:subscription_url]
      session[:subscription_url] = nil
    else
      dashboard_path
    end
  end

  def authenticate_judge!
    unless current_user.is_judge
      redirect_to :back, notice: I18n.t('messages.unauthorized_access')
    end
  end
end
