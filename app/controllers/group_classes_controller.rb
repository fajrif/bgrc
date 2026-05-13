class GroupClassesController < ApplicationController
  def index
    @group_classes = GroupClass.available.includes(:sport)
    @group_classes = @group_classes.where(sport_id: params[:sport_id]) if params[:sport_id].present?
    @sports = Sport.where.not(name: "Golf").order(:name)
  end

  def show
    @group_class = GroupClass.available.find(params[:id])
    @sport = @group_class.sport
    @upcoming_sessions = @group_class.upcoming_sessions if @group_class.is_prescheduled?
  end
end
