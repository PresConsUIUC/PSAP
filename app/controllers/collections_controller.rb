class CollectionsController < ApplicationController

  def create

  end

  def destroy

  end

  def edit

  end

  def index
    @collections = Resource.all # TODO: only collections
  end

  def new
    collection = Resource.new
  end

  def show
    @collection = Resource.find(params[:id]) # TODO: only collections
  end

  def update

  end

end
