module Api
  class RacesController < ApplicationController 
    def index
      if !request.accept || request.accept == "*/*"
        render plain: "/api/races, offset=[#{params[:offset]}], limit=[#{params[:limit]}]"
      else
      #real implementation ...
      end
    end

    def show
      if !request.accept || request.accept == "*/*"
        render plain: "/api/races/#{params[:id]}"
      else
      #real implementation ...
        @race = Race.find(params[:id])
        render json: @race
      end
    end

    def create
      if !request.accept || request.accept == "*/*" 
        render plain: "#{params[:race][:name]}", status: :ok
      else
      #real implementation
        @race = Race.new(race_params)
        if @race.save
          render plain: race_params[:name], status: :created
        else
          render json: @race.errors
        end
      end
    end

    def update
      Rails.logger.debug("method=#{request.method}")
      @race = Race.find(params[:id])
      if @race.update(race_params)
        render json: @race
      else
        render json: @race.errors
      end
    end

    def destroy
      @race = Race.find(params[:id])
      @race.destroy
      render :nothing=>true, :status => :no_content
    end

    private
      def race_params
        params.require(:race).permit(:name, :date)
      end
    end
end
