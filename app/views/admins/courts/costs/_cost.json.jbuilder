json.extract! cost, :id, :day_code, :day_name, :start_time, :end_time, :price
json.url admins_court_cost_url(cost.court.id, cost, format: :json)
