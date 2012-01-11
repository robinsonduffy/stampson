class ActualCountryValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << "must be a valid country" if Country.find_by_id(value.to_i).nil?
  end
end


class Item < ActiveRecord::Base
  attr_accessible :scott_number, :country_id, :description
  
  validates :scott_number, :presence => true,
                           :uniqueness => {:scope => :country_id}
  
  validates :country_id, :presence => true, 
                         :actual_country => true
  
end
