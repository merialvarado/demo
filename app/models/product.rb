class Product < ActiveRecord::Base
  attr_accessible :author, :available_on, :description, :price, :title
end
