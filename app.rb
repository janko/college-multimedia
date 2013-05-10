require "sinatra"
require "sinatra/reloader" if development?
require "haml"
require_relative "helpers"

also_reload "helpers.rb"

set :uploads_dir, File.join(settings.public_dir, "uploads")

enable :sessions

get "/" do
  haml :index
end

post "/upload" do
  if params[:image]
    upload_image(params[:image])
    redirect "/process"
  else
    redirect "/"
  end
end

get "/process" do
  @image_filename = image_filename
  @processed_image_filename = processed_image_filename
  haml :process
end

put "/process" do
  apply_effects(params[:effects] || [])
  redirect "/process"
end

delete "/remove" do
  delete_image
  redirect "/"
end
