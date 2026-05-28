class ActorsController < ApplicationController
  before_action :set_movie
  before_action :set_actor, only: %i[edit update destroy]

  def create
    @actor = @movie.actors.new(actor_params)
    if @actor.save
      redirect_to @movie, notice: 'Актора додано.'
    else
      redirect_to @movie, alert: 'Помилка при додаванні актора.'
    end
  end

  def edit; end

  def update
    if @actor.update(actor_params)
      redirect_to @movie, notice: 'Актора оновлено.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @actor.destroy
    redirect_to @movie, notice: 'Актора видалено.'
  end

  private

  def set_movie
    @movie = Movie.find(params[:movie_id])
  end

  def set_actor
    @actor = @movie.actors.find(params[:id])
  end

  def actor_params
    params.require(:actor).permit(:name)
  end
end
