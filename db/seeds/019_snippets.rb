puts "Creating Snippets..."

[
  {
    key: "cancellation_policy",
    title: "Cancellation Policy",
    content: "Bookings cannot be canceled or refunded within 24 hours of your reserved court time. Cancellations made more than 24 hours in advance will receive a full refund."
  },
  {
    key: "refund_policy",
    title: "Refund Policy",
    content: "Refunds will be processed within 7-14 business days to the original payment method. No refunds will be issued for no-shows or late arrivals."
  },
  {
    key: "terms_and_conditions",
    title: "Terms & Conditions",
    content: "By completing this payment, you agree to the terms and conditions of Bali Beach Country Club. All bookings are subject to availability. Management reserves the right to reschedule or cancel bookings due to unforeseen circumstances, in which case a full refund will be provided."
  }
].each do |attrs|
  snippet = Snippet.find_or_initialize_by(key: attrs[:key])
  snippet.title = attrs[:title]
  snippet.content = attrs[:content]
  snippet.save!
  puts "  - #{attrs[:key]}"
end

puts "Snippets created."
