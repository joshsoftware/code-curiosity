module JudgeScoringHelper
   extend ActiveSupport::Concern

   included do
     field :judges_score, type: Float
   end

   def set_judges_avg_score
     score = scores.any? ? (scores.pluck(:value).sum/scores.count.to_f).round : nil

     self.set(judges_score: score)
   end
end
