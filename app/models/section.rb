class Section < ActiveRecord::Base
  acts_as_list

  attr_accessible :body, :header, :section_type, :document_id
  
  belongs_to :document
  
  TYPES = [
    ["Section", "Section"],
    ["Address", "Address"]
  ]
end
