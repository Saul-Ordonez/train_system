require('sinatra')
require('sinatra/reloader')
require('./lib/city')
require('./lib/train')
require('pry')
also_reload('lib/**/*.rb')
require('pg')

DB = PG.connect({:dbname => 'train_system'})

get('/') do
  erb(:home)
end

get("/cities") do
  if params["search"]
    @cities = City.search(params[:search])
  else
    @cities = City.all
  end
  erb(:cities)
end

get("/user_cities") do
  if params["search"]
    @cities = City.search(params[:search])
  else
    @cities = City.all
  end
  erb(:user_cities)
end

post('/cities') do
  name = params[:city_name]
  city = City.new({:name => name, :id => nil})
  city.save()
  redirect to('/cities')
end

get("/cities/new") do
  erb(:new_city)
end

get('/cities/:id') do
  @city = City.find(params[:id].to_i())
  if @city == nil
    erb(:go_back)
  else
    erb(:city)
  end
end

get('/user_cities/:id') do
  @city = City.find(params[:id].to_i())
  if @city == nil
    erb(:go_back)
  else
    erb(:user_city)
  end
end

get('/cities/:id/edit') do
  @city = City.find(params[:id].to_i())
  erb(:edit_city)
end

patch('/cities/:id') do
  @city = City.find(params[:id].to_i())
  @city.update(params[:name])
  @cities = City.all
  erb(:city)
end

delete('/cities/:id') do
  @city = City.find(params[:id].to_i())
  @city.delete()
  redirect to('/cities')
end

post('/cities/:id/trains') do
  @city = City.find(params[:id].to_i())
  train = Train.new({:destination => params[:destination_input], :city_id => @city.id, :id => nil, :time => params[:time_input], :time2 => params[:time2_input], :time3 => params[:time3_input]})
  train.save()
  erb(:city)
end

get('/cities/:id/trains/:train_id') do
  @train = Train.find(params[:train_id].to_i())
  erb(:train)
end

patch('/cities/:id/trains/:train_id') do
  @city = City.find(params[:id].to_i())
  train = Train.find(params[:train_id].to_i())
  train.update(params[:destination_input], @city.id)
  erb(:city)
end

delete('/cities/:id/trains/:train_id') do
  train = Train.find(params[:train_id].to_i())
  train.delete
  @city = City.find(params[:id].to_i())
  redirect to('/cities/' + params[:id])
end

get('/user_cities/:id/user_trains/:train_id') do
  @train = Train.find(params[:train_id].to_i())
  erb(:user_train)
end

post('/user_cities/:id/user_trains/:train_id/ticket') do
  @city = City.find(params[:id].to_i())
  @trains = Train.new({:destination => params[:destination_input], :city_id => @city.id, :id => nil, :time => params[:user_time_input]})
  @train = Train.find(params[:train_id].to_i())
  binding.pry
  erb(:ticket)
end

get("/destroy") do
  @city = City.clear
  @train = Train.clear
  redirect to('/cities')
end
