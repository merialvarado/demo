class Category < ActiveRecord::Base
  attr_accessible :ancestry, :name, :parent_id
  
  has_ancestry
  
  def name_for_selects
    "#{'-' * self.depth} #{self.name}"
  end
  
  def parent_name
    self.parent.name rescue nil
  end
  
  def children_names
    name = []
    self.children.each{|c| name << c.name}
    name.join(", ")
  end
end
