class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :edit]

  def index
    district = [" "]
    cat = [" "]
    age = [" "]
    Activity.all.each do |activity|
      district << activity.address
      cat << activity.category
      age << activity.age_group
    end
    @activities = Activity.all
    @activities = @activities.where("category ILIKE ?", params[:category]) unless (params[:category].blank? || !cat.include?(params[:category]))
    @activities = @activities.where(age_group: params[:age_group]) unless (params[:age_group].blank? || !age.include?(params[:age_group]))
    @activities = @activities.where("district ILIKE ?", params[:district]) unless params[:district].blank?
    titles = params[:title].split(' ') unless params[:title].blank?
    @activities = @activities.where((["title ILIKE ?"] * titles.size).join(' OR '), *titles.map { |title| "%#{title}%" }) unless titles.blank?
    addr = params[:address].split(' ') unless params[:address].blank?
    @activities = @activities.where((["address ILIKE ?"] * addr.size).join(' OR '), *addr.map { |address| "%#{address}%" }) unless addr.blank?
    @activities = @activities.where.not(latitude: nil, longitude: nil) unless params[:address].blank?
    @markers = @activities.map do |activity|
      next if activity.latitude.nil?
      {
        lat: activity.latitude,
        lng: activity.longitude#,
        # infoWindow: { content: render_to_string(partial: "/activities/map_box", locals: { activity: activity }) }
      }
    end
    @markers = @markers.compact
    p @markers
  end

  def new
    @activity = Activity.new
  end

  def show
    @events = @activity.events
   #authorize @activity
   #if @activity.latitude && @activity.longitude
   # @markers = [{
   #   lat: @activity.latitude,
   #   lng: @activity.longitude
   #   }]
   #end
  end

  def create
    @activity = Activity.new(activity_params)
    @activity.user = current_user
    #authorize @activity
    if @activity.save
      redirect_to  new_activity_event_path(@activity)
    else
      render :new
    end
  end

  def edit
    #authorize @activity
  end

  def update
    @activity.update(activity_params)
    #authorize @activity
    redirect_to activity_path(@activity)
  end

  def destroy
    @activity.destroy
    redirect_to activities_path
  end

  private

  def activity_params
    params.require(:activity).permit(:title, :description, :price, :address, :district, :category, :age_group, photos: [])
  end

  def set_activity
    @activity = Activity.find(params[:id])
  end
end


