module JudgeScoringHelper
   extend ActiveSupport::Concern

   included do
     field :judges_score, type: Integer
   end

   def set_judges_avg_score
     score = scores.any? ? (scores.pluck(:value).sum/scores.count.to_f).round : nil

     self.set(judges_score: score)
   end

   def avg_score
     if self.scores.any?
       (scores.pluck(:value).sum/scores.count.to_f).round
     end
   end

   def judge_rating(user)
     scores.where(user: user).first.try(:value)
   end

   def final_score
     judges_score || auto_score
   end
end
