class Country < ActiveRecord::Base
  attr_accessible :name
  
  validates :name, :presence => true, 
                   :uniqueness => {:case_sensitve => false}
                   
  has_many :items, :dependent => :destroy
  
  scope :active, :include => :items, :conditions => ['items.id IS NOT NULL'], :order => ['(countries.name = "Specials"), countries.name']
  scope :no_specials, :conditions => ['countries.name != "Specials"'], :order => ['countries.name']
end
