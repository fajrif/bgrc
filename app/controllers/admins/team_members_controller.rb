class Admins::TeamMembersController < Admins::BaseController
	before_action :set_team_member, except: [:index, :new, :create]

  def index
    criteria = TeamMember.where("name ILIKE ?", "%#{params[:search]}%")
		unless params[:department].blank?
			criteria = criteria.where(department: params[:department])
		end

    @team_members = criteria.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @team_members }
      format.js
    end
  end

  def new
    @team_member = TeamMember.new
  end

  def create
    @team_member = TeamMember.new(params_team_member)
    if @team_member.save
			redirect_to admins_team_member_path(@team_member.id), :notice => "Successfully created team member."
    else
      render :action => 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @team_member.update(params_team_member)
			redirect_to admins_team_member_path(@team_member.id), :notice  => "Successfully updated team member."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @team_member.destroy
    redirect_to admins_team_members_url, :notice => "Successfully destroyed team member."
  end

  private

  def params_team_member
    params.require(:team_member).permit(:name, :department, :role, :bio, :position, :photo)
  end

  def set_team_member
		@team_member = TeamMember.find(params[:id])
  end
end
