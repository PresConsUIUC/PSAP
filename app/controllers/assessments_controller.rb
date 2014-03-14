class AssessmentsController < ApplicationController

  before_action :signed_in_user

  def create
    @assessment = Assessment.new(assessment_params)
    if @assessment.save
      flash[:success] = 'Assessment created.'
      redirect_to @assessment
    else
      render 'new'
    end
  end

  def destroy
    Assessment.find(params[:id]).destroy
    flash[:success] = 'Assessment deleted.'
    redirect_to assessments_url
  end

  def edit
  end

  def index
    @assessments = Assessment.order(:name).paginate(page: params[:page],
                                                    per_page: 30)
  end

  def new
    @assessment = Assessment.new
  end

  def show
    @assessment = Assessment.find(params[:id])
  end

  def update
    @assessment = Assessment.find(params[:id])
    if @assessment.update_attributes(assessment_params)
      flash[:success] = 'Assessment updated.'
      redirect_to @assessment
    else
      render 'edit'
    end
  end

  private

  def assessment_params
    params.require(:assessment).permit(:name)
  end

end
