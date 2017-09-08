module ActiveJobRetriesCount
  extend ActiveSupport::Concern
  MAX_RETRY_COUNT = 5

  included do
    attr_accessor :retries_count
  end

  # define the activejob methods to increment the retry count during failed retries of a job
  def initialize(*arguments)
    super
    @retries_count ||= 0
  end

  def deserialize(job_data)
    super
    @retries_count = job_data['retries_count'] || 0
  end

  def serialize
    super.merge('retries_count' => retries_count || 0)
  end

  def retry_job(options)
    @retries_count = (retries_count || 0) + 1
    super(options)
  end
end
