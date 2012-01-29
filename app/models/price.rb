class ActualItemValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << "must be a valid item" if Item.find_by_id(value.to_i).nil?
  end
end

class Price < ActiveRecord::Base
  attr_accessible :condition, :price, :item_id
  
  validates :condition, :presence => true,
                        :uniqueness => {:scope => :item_id}
  
  validates :price, :presence => true,
                    :numericality => true
  
  validates :item_id, :presence => true,
                      :actual_item => true
                      
  belongs_to :item
  
  default_scope :order => 'prices.price DESC'
  scope :sell, :conditions => "prices.condition != 'BUY'"
  scope :buy, :conditions => "prices.condition = 'BUY'"
  
  auto_strip_attributes :condition, :squish => true, :nullify => false
  
end
