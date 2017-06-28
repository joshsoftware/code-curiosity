# Overrides the deserialize method to pass retry count during subsequent retries of failed job
if ActiveJob::Base.method_defined?(:deserialize)  
  fail 'This no longer needed.'
else  
  module ActiveJob
    class Base
      def self.deserialize(job_data)
        job = job_data['job_class'].constantize.new
        job.deserialize(job_data)
        job
      end

      def deserialize(job_data)
        self.job_id               = job_data['job_id']
        self.queue_name           = job_data['queue_name']
        self.serialized_arguments = job_data['arguments']
      end
    end
  end
end  
