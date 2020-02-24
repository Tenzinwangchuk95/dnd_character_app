require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    set :views, Proc.new { File.join(root, "../views/") }
    enable :sessions
    set :session_secret, "secret"
  end

  get '/' do
    erb :login
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    @user = User.find_by(:email => params[:email])
    if @user != nil && @user.password == params[:password]
      session[:user_id] = @user.id
      
      redirect to '/index'
    end
    erb :error
  end

  get '/signup' do

    erb :signup
  end

  post '/signup' do
    if User.exists?(email: params["email"])
      erb :taken
    else
    @user = User.new(email: params["email"], password: params["password"])
    @user.save
    session[:user_id] = @user.id
    redirect to '/login'
    end
  end

  get '/index' do
    @characters = Character.all
    @current_user = User.find(session[:user_id])
    if @current_user
      erb :index
    else
      erb :error
    end
  end

  get '/logout' do
    session.clear
    redirect to '/'
  end

  get '/create' do
    @current_user = User.find(session[:user_id])
    if @current_user
      erb :create
    else
      erb :error
    end
  end

  post '/create' do
    @character = Character.new(params)
    @current_user = User.find(session[:user_id])
    @character.user = @current_user
    @character.save
    redirect to '/index'
  end

  get "/edit/:id" do
    @current_user = User.find(session[:user_id])
    if @current_user
      @character = Character.find(params[:id])
      erb :edit
    else
      erb :error
    end
  end

  patch '/index/:id' do
    @character = Character.find(params[:id])
    @character.update(params[:character])
    redirect to '/index'
  end

  delete "/delete/:id" do
    Character.destroy(params[:id])
    redirect to '/index'
  end


end

