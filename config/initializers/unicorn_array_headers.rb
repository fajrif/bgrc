# Rack 3 lets a response header hold an Array of values (Rails sends Set-Cookie
# that way). Unicorn 6.1.0 predates that and calls String methods on every header
# value, so each response dies with "undefined method `=~' for an instance of
# Array". Rack 2 joined multiple values with "\n", which Unicorn splits back into
# separate header lines, so the same shape is restored here, outside everything
# else in the stack. Remove once Unicorn supports Rack 3 headers.
class UnicornArrayHeaders
	def initialize(app)
		@app = app
	end

	def call(env)
		status, headers, body = @app.call(env)
		headers.each { |key, value| headers[key] = value.join("\n") if value.is_a?(Array) }
		[status, headers, body]
	end
end

Rails.application.config.middleware.insert_before(0, UnicornArrayHeaders) if Rails.env.production?
