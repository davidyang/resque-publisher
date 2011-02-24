require 'json'
require 'resque/time_stat'
require 'resque/plugins/stats_keeper'

module Resque
  module Plugins
    module Publisher
      extend Resque::Plugins::StatsKeeper

      def after_enqueue_publish(*args)
        Resque.redis.publish :publisher, { :event => :enqueued,
          :pid => job_pid,
          :host => hostname,
                                           :queue => @queue,
                                           :id => self.object_id,
                                           :args => args }.to_json
      end

      def before_perform_publish(*args)
        Resque.redis.publish :publisher, { :event => :started,
                                           :queue => @queue,
          :pid => job_pid,
          :host => hostname,
                                           :id => self.object_id,
                                           :args => args }.to_json
      end

      def after_perform_publish(*args)
        Resque.redis.publish :publisher, { :event => :finished,
                                           :queue => @queue,
          :pid => job_pid,
          :host => hostname,
                                           :id => self.object_id,
                                           :args => args }.to_json
      end

      def on_failure_publish(message, *args)
        Resque.redis.publish :publisher, { :event => :failed,
                                           :queue => @queue,
                                           :id => self.object_id,
          :pid => job_pid,
          :host => hostname,
                                           :message => message,
                                           :args => args }.to_json
      end

      def log_publish(message)
        Resque.redis.publish :publisher, { :event => :log,
          :queue => @queue,
          :id => self.object_id,
          :host => hostname,
          :pid => job_pid,
          :message => message }.to_json

      end

      def job_pid
        $$.to_s
      end
      def hostname
        `hostname`.chomp
      end
    end
  end
end
