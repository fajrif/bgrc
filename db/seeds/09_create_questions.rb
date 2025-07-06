Question.delete_all
puts "create all questions"

# FAQ
_title = "How do I book coaching sessions or a court?"
faq = Question.new(title: _title, section: "general")
faq.description = %q{
<p>You can book your coaching sessions or court time by contacting us via WhatsApp at +62 811‑3831‑4769 (Bali Beach Country Club).</p>
<p>Please note that payments should be made only to PT Bali Destinasi Lestari. We are not responsible for any payments made to other bank accounts.</p>
}
faq.save
Mobility.with_locale(:id) {
  faq.title = _title
  faq.description = %q{
    <p>You can book your coaching sessions or court time by contacting us via WhatsApp at +62 811‑3831‑4769 (Bali Beach Country Club).</p>
    <p>Please note that payments should be made only to PT Bali Destinasi Lestari. We are not responsible for any payments made to other bank accounts.</p>
  }
}
faq.save
puts "Create FAQ: #{faq.title}"

_title = "Is there a booking policy?"
faq = Question.new(title: _title, section: "general")
faq.description = "Yes, we have a booking policy to ensure a smooth experience for everyone. Reservations must be made at least 12 hours in advance of your chosen time and date. This allows us to accommodate all clients effectively. If you have any questions, feel free to reach out!"
faq.save
Mobility.with_locale(:id) {
  faq.title = _title
  faq.description = "Yes, we have a booking policy to ensure a smooth experience for everyone. Reservations must be made at least 12 hours in advance of your chosen time and date. This allows us to accommodate all clients effectively. If you have any questions, feel free to reach out!"
}
faq.save
puts "Create FAQ: #{faq.title}"

_title = "Is there a cancellation and refund policy?"
faq = Question.new(title: _title, section: "general")
faq.description = %q{
  <p>Yes, we have a cancellation and refund policy in place:</p>
  <ul>
    <li>Cancel or reschedule up to 24 hours before booking to avoid being charged in full.</li>
    <li>Cancellations or rescheduling can be done in person, via phone, email, or WhatsApp.</li>
    <li>Private coaching lessons canceled within 24 hours will be charged in full and are not eligible for exchange or partial credit toward court hire.</li>
    <li>If you need to cancel due to sickness or injury, please provide a doctor’s certificate to the Tennis Reception within 48 hours of your booking to avoid the penalty.</li>
  </ul>
}
faq.save
Mobility.with_locale(:id) {
  faq.title = _title
  faq.description = %q{
    <p>Yes, we have a cancellation and refund policy in place:</p>
    <ul>
      <li>Cancel or reschedule up to 24 hours before booking to avoid being charged in full.</li>
      <li>Cancellations or rescheduling can be done in person, via phone, email, or WhatsApp.</li>
      <li>Private coaching lessons canceled within 24 hours will be charged in full and are not eligible for exchange or partial credit toward court hire.</li>
      <li>If you need to cancel due to sickness or injury, please provide a doctor’s certificate to the Tennis Reception within 48 hours of your booking to avoid the penalty.</li>
    </ul>
  }
}
faq.save
puts "Create FAQ: #{faq.title}"

_title = "Am I allowed to bring my own tennis coach when I hire a court?"
faq = Question.new(title: _title, section: "general")
faq.description = "No, outside coaching vendors are not allowed. We offer coaching through our exclusive partner, MITS."
faq.save
Mobility.with_locale(:id) {
  faq.title = _title
  faq.description = "No, outside coaching vendors are not allowed. We offer coaching through our exclusive partner, MITS."
}
faq.save
puts "Create FAQ: #{faq.title}"
