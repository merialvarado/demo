module Workflow::Helper
  
  module WorkflowHelperClassMethods
    def workflow_add_can_helpers
      @workflow_spec.states.values.each do |state|
        state.events.values.each do |event|
          event_name = event.name
          module_eval do
            define_method "can_#{event_name}?" do
              return self.current_state.events.include? event_name
            end
          end
        end
      end
      @original_on_transition_proc = @workflow_spec.on_transition_proc
      @workflow_spec.on_transition_proc = Proc.new do |from, to, triggering_event, *event_args|
        perform_transition(from, to, triggering_event, *event_args) if self.class.workflow_spec.states[from].events[triggering_event].meta[:pfeed]
        instance_exec(from.name, to.name, triggering_event, *event_args, &@original_on_transition_proc) if @original_on_transition_proc
      end
    end
  end
  def self.included(klass)
    #klass.send :include, WorkflowHelperInstanceMethods
    klass.extend WorkflowHelperClassMethods
    #klass.emits_pfeeds :on => [:perform_transition], :for => [:itself, :event_observers]
    #klass.receives_pfeed
  end
end
module ActiveRecord
  class Base
    # Validate that the the objects in +collection+ are unique
    # when compared against all their non-blank +attrs+. If not
    # add +message+ to the base errors.
    def validate_uniqueness_of_in_memory(collection, attrs, message)
      hashes = collection.inject({}) do |hash, record|
        key = attrs.map {|a| record.send(a).to_s }.join
        if key.blank? || record.marked_for_destruction?
          key = record.object_id
        end
        hash[key] = record unless hash[key]
        hash
      end
      if collection.length > hashes.length
        self.errors.add_to_base(message)
      end
    end
  end
end

