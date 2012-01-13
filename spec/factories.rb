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

Factory.define :item do |item|
  item.scott_number "100"
  item.description "Test Item"
  item.association :country
end

Factory.define :price do |price|
  price.condition "MNH"
  price.price 1.99
  price.association :item
end