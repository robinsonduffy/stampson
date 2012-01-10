class User < ActiveRecord::Base
  authenticates_with_sorcery!
  attr_accessible :email, :password, :password_confirmation
  
  validates :password, :presence => true,  
                       :length => {:within => 6..40}
                       
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/
  validates :email, :presence => true, 
                    :uniqueness => {:case_sensitve => false},
                    :format => { :with => email_regex }
                    
end
