class Document < ActiveRecord::Base
  attr_accessible :name, :sections_attributes, :state
  
  has_many :sections
  accepts_nested_attributes_for :sections
  
  include Workflow

  workflow_column :state

  workflow do
    state :select_sections do
      event :next_step, :transitions_to => :position_sections
    end
    state :position_sections do
      event :previous_step, :transitions_to => :select_sections
      event :next_step, :transitions_to => :select_template
    end
    state :select_template do
      event :previous_step, :transitions_to => :position_sections
      event :submit, :transitions_to => :completed
    end
    state :completed
  end

  include Workflow::Helper
  workflow_add_can_helpers
end
