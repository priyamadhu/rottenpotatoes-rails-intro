class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    
    if params[:sort_title] == "title"
 	    session[:title_class]="hilite"
 	    @movies = Movie.order("title")
 	    session[:release_class]=""
    elsif params[:sort_release_date] == "release"
      session[:title_class]=""
      session[:release_class]="hilite"
      @movies = Movie.order("release_date")
    else
 	    @movies = Movie.all
    end
    
    @all_ratings = Movie.distinct.pluck(:rating)
    
    if params[:ratings] != nil
      session[:clicked_box]=params[:ratings]
    end
    
    if session[:clicked_box] == nil
       session[:clicked_box] = Hash.new()
       @all_ratings.each do |rating|
        session[:clicked_box][rating]=1
       end
    end
     
     @movies = @movies.where({rating: session[:clicked_box].keys})
     
    if session[:title_class]=="hilite" && params[:sort_title]==nil 
      params[:sort_title] = "title"
      redirect_to movies_path(params)
    elsif session[:release_class]=="hilite" && params[:sort_release_date]==nil
      params[:sort_release_date] = "release"
      redirect_to movies_path(params)
    elsif params[:ratings]==nil && session[:clicked_box]!=nil
      params[:ratings]=session[:clicked_box]
      redirect_to movies_path(params)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end