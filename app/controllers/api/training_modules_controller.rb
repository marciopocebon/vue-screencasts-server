class Api::TrainingModulesController < ApplicationController
  before_action :authenticate_user, only: [:create, :update, :destroy]

  def create
    training_module = TrainingModule.create(module_params)
    render_module(training_module)
  end

  def show
    training_module = TrainingModule.find(params[:id])
    render json: TrainingModuleSerializer.new(
        training_module, 
        include: [:training_sections, :'training_sections.training_items'], 
      ).serializable_hash
  end

  def index
    training_modules = TrainingModule.all
    render json: TrainingModuleSerializer.new(
        training_modules, 
        include: [:training_sections, :'training_sections.training_items'],
      ).serializable_hash
  end

  def update
    training_module = TrainingModule.find(params[:id])
    training_module.update_attributes(module_params)
    training_module.save
    render_module(training_module)
  end

  def destroy
    TrainingModule.find(params[:id]).destroy
    head 204
  end

  def render_module(modules)
    render json: TrainingModuleSerializer.new(modules).serializable_hash    
  end

  def module_params
    params.require(:training_module).permit(:name, :week_number, :intro)
  end
end