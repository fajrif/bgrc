json.extract! business_hour, :id, :day_code, :day_name, :open, :close
json.url admins_court_business_hour_url(business_hour.court.id, business_hour, format: :json)
