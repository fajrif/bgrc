class Admins::RecurringEventsController < Admins::BaseController
  before_action :set_recurring_event, except: [:index, :new, :create, :check_overlaps]

  def index
    criteria = RecurringEvent.all
    if params[:court_id].present?
      criteria = criteria.joins(:recurring_event_courts).where(recurring_event_courts: { court_id: params[:court_id] })
    end
    @recurring_events = criteria.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @recurring_event = RecurringEvent.new
    @courts = Court.all
  end

  def create
    @recurring_event = RecurringEvent.new(params_recurring_event)
    if @recurring_event.save
      redirect_to admins_recurring_event_path(@recurring_event), :notice => "Successfully created recurring event"
    else
      @courts = Court.all
      render :action => 'new'
    end
  end

  def edit
    @courts = Court.all
  end

  def update
    if @recurring_event.update(params_recurring_event)
      redirect_to admins_recurring_event_path(@recurring_event), :notice => "Successfully updated recurring event"
    else
      @courts = Court.all
      render :action => 'edit'
    end
  end

  def destroy
    @recurring_event.destroy
    redirect_to admins_recurring_events_url, :notice => "Successfully destroyed recurring event"
  end

  def check_overlaps
    court_ids  = params[:court_ids].to_a.reject(&:blank?).map(&:to_i)
    start_time = params[:start_time]
    end_time   = params[:end_time]
    exclude_id = params[:exclude_id].presence&.to_i

    return render json: { overlaps: [] } if court_ids.empty? || start_time.blank? || end_time.blank?

    if params[:specific_date].present?
      check_start = Date.parse(params[:specific_date])
      check_end   = params[:end_date].present? ? Date.parse(params[:end_date]) : check_start
    else
      dow         = params[:day_of_week].to_i
      check_start = Date.today
      check_end   = Date.today + 28.days
    end

    overlaps = []
    Court.where(id: court_ids).each do |court|
      court.group_class_schedules.includes(:group_class).each do |gcs|
        next unless (check_start..check_end).any? { |d| d.wday == gcs.day_of_week }
        if times_overlap?(start_time, end_time, gcs.start_time, gcs.end_time)
          overlaps << { type: "Group Class", name: gcs.group_class.name,
                        day: "Every #{Date::DAYNAMES[gcs.day_of_week]}", time: "#{gcs.start_time}–#{gcs.end_time}" }
        end
      end

      court.recurring_events.where(active: true).each do |re|
        next if exclude_id && re.id == exclude_id
        hit = if re.one_time?
          (check_start..check_end).any? { |d| (re.specific_date..re.effective_end_date).cover?(d) } &&
          times_overlap?(start_time, end_time, re.start_time, re.end_time)
        else
          (check_start..check_end).any? { |d| d.wday == re.day_of_week } &&
          times_overlap?(start_time, end_time, re.start_time, re.end_time)
        end
        if hit
          overlaps << { type: "Event", name: re.title.presence || "(hidden block)",
                        day: re.one_time? ? re.specific_date.strftime("%d %b %Y") : "Every #{re.day_name}",
                        time: "#{re.start_time}–#{re.end_time}" }
        end
      end
    end

    render json: { overlaps: overlaps.uniq }
  end

  private

  def params_recurring_event
    params.require(:recurring_event).permit(
      :title, :day_of_week, :specific_date, :end_date, :start_time, :end_time,
      :description, :short_description, :capacity, :image, :active, :hide,
      court_ids: []
    )
  end

  def set_recurring_event
    @recurring_event = RecurringEvent.find(params[:id])
  end

  def times_overlap?(s1, e1, s2, e2)
    Time.parse(s1) < Time.parse(e2) && Time.parse(e1) > Time.parse(s2)
  end
end
