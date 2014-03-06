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

  end

  def update

  end

end
