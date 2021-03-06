class CountriesController < ApplicationController
  
  def show
    @country = Country.find(params[:id])
    scott_numbers = Array.new
    @country.items.sell.each do |item|
      scott_numbers.push(item.scott_number)
    end
    @scott_numbers_sorted = scott_numbers.natural_sort
    @title = @country.name
  end
  
  def buy_list
    @country = Country.find(params[:id])
    scott_numbers = Array.new
    @country.items.buy.each do |item|
      scott_numbers.push(item.scott_number)
    end
    @scott_numbers_sorted = scott_numbers.natural_sort
    @title = "Buy List: #{@country.name}"
  end

end
