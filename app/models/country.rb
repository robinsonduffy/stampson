class Country < ActiveRecord::Base
  attr_accessible :name
  
  validates :name, :presence => true, 
                   :uniqueness => {:case_sensitve => false}
                   
end
