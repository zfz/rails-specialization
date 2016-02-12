module Api
  class RacesController < ApplicationController 
    def index
      puts params
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
      end
    end

    def create
      if !request.accept || request.accept == "*/*" 
        render plain: "#{params[:race][:name]}", status: :ok
      else
      #real implementation
      end
    end
  end
end
