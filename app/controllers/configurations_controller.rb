
require 'digest'



class ConfigurationsController < ApplicationController


  def index
    render :json => { :configuration => BinConfiguration.all }
  end

  def show
    configuration = BinConfiguration.find(params[:id])
    render json: { configuration: configuration }
  end

  def create
    configuration = BinConfiguration.new(params[:configuration])
    if configuration.save
      render json: { configuration: configuration }
    else
      render json: { errors: configuration.errors }, status: 422
    end
  end

  def update
    configuration = BinConfiguration.find(params[:id])
    if configuration.update_attributes(params[:configuration])
      render json: { configuration: configuration }
    else
      render json: { errors: configuration.errors }, status: 422
    end
  end

  def destroy
    configuration = BinConfiguration.find(params[:id])
    if configuration.delete()
      render json: { configuration: configuration }
    else
      render json: { errors: configuration.errors }, status: 422
    end
  end

end