Factory.define :user do |user|
  user.email "user@example.com"
  user.password "foobar"
end

Factory.sequence :email do |n|
  "user-#{n}@example.com"
end

Factory.define :country do |country|
  country.name "Test Country"
end