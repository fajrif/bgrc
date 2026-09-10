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
  },
  {
    key: "disclaimer",
    title: "Disclaimer",
    content: <<~HTML
      <h3>1. General Information</h3>
      <p>All content provided on this website is for informational and entertainment purposes only. We make every effort to provide accurate and up-to-date information about our facilities, courts, events and services. However, Bali Beach Country Club makes no guarantees regarding the accuracy, completeness, or timeliness of any information published, and reserves the right to add, remove, or modify content on the Site at any time without prior notice.</p>
      <h3>2. Not Professional Advice</h3>
      <p>The content on this website, including training tips, fitness advice, and coaching programme descriptions, is not intended to substitute for professional advice. Always consult a coach, trainer, or medical professional before beginning any training programme, fitness regime, or new sporting activity.</p>
      <p>We are not responsible for any injury, health issue, or other problem that may result from following advice or recommendations found on this Site.</p>
      <h3>3. Health and Physical Activity Disclaimer</h3>
      <p>Participation in sports and fitness activities involves inherent risks, including the risk of injury. By using our facilities, you acknowledge that you do so voluntarily and at your own risk. Bali Beach Country Club shall not be held liable for any injuries, damages, or losses sustained through use of the Site or participation in any activity referenced on it.</p>
      <h3>4. External Links Disclaimer</h3>
      <p>Our website may contain links to third-party websites or services that are not owned or controlled by us, including our coaching partner MITS Academy. These links are provided for your convenience only.</p>
      <p>We do not assume any responsibility for the content, privacy policies, or practices of any third-party websites. You acknowledge and agree that we are not liable, directly or indirectly, for any damage or loss caused by or in connection with the use of such external content or services.</p>
      <h3>5. Affiliate and Sponsorship Disclosure</h3>
      <p>Bali Beach Country Club partners with select brands and organisations, including MITS Academy for coaching programmes. Where a section of the Site is produced in partnership with a third party, it will be clearly identified as such.</p>
      <h3>6. Testimonials and User Content</h3>
      <p>Testimonials and reviews on this website reflect individual experiences and are not guaranteed to be typical for all users. We may also feature user-submitted content such as photos or stories from events. We are not responsible for the accuracy of this content and reserve the right to remove any content at our discretion.</p>
      <h3>7. No Guarantees</h3>
      <p>While we strive to provide useful and accurate content, Bali Beach Country Club makes no guarantees or warranties of any kind, express or implied, about the completeness, accuracy, reliability, or availability of any content, services, or products offered on or through this website. Your reliance on any information provided by the Site is solely at your own risk.</p>
      <h3>8. Intellectual Property</h3>
      <p>All content, images, videos, and designs on the Site are protected by copyright and intellectual property laws. You may not copy, reproduce, republish, upload, or distribute any content from this website without prior written permission.</p>
      <h3>9. Limitation of Liability</h3>
      <p>To the fullest extent permitted by applicable law, Bali Beach Country Club, its owners, affiliates, employees, and agents disclaim all liability for any damages arising out of or in connection with your use of the Site. This includes, but is not limited to, direct, indirect, incidental, punitive, and consequential damages.</p>
      <h3>10. Contact Us</h3>
      <p>If you have any questions or concerns about this disclaimer, please contact us at #{configatron.admin_email}.</p>
    HTML
  },
  {
    key: "privacy_policy",
    title: "Privacy Policy",
    content: <<~HTML
      <h3>1. Information We Collect</h3>
      <p>When you create an account, make a booking, or purchase a package at Bali Beach Country Club, we collect information such as your name, email address, phone number, and payment details necessary to process your request. If you sign in with Google, we receive your name, email address, and profile photo from your Google account.</p>
      <h3>2. How We Use Your Information</h3>
      <p>We use your information to process bookings and purchases, send booking confirmations and payment reminders, respond to enquiries submitted through our contact form, and keep you informed about your account and reservations.</p>
      <h3>3. Payment Processing</h3>
      <p>Payments made on this website are processed securely by Xendit, our third-party payment gateway. We do not store your full card details on our servers &mdash; all payment information is handled directly by Xendit in accordance with their own security standards and privacy policy.</p>
      <h3>4. Cookies and Site Security</h3>
      <p>We use cookies to keep you signed in and to remember your preferences while browsing the Site. Our contact form is protected by Google reCAPTCHA to help prevent spam and abuse; use of reCAPTCHA is subject to Google's own Privacy Policy and Terms of Service.</p>
      <h3>5. Sharing of Information</h3>
      <p>We do not sell your personal information. We share information only with trusted service providers who help us operate the Site &mdash; such as our payment processor and email delivery provider &mdash; and only to the extent necessary for them to provide their services to us.</p>
      <h3>6. Data Retention</h3>
      <p>We retain your account and booking information for as long as your account is active or as needed to provide our services, comply with our legal obligations, resolve disputes, and enforce our agreements.</p>
      <h3>7. Your Rights</h3>
      <p>You may access, update, or request deletion of your personal information at any time by contacting us using the details below, or by updating your details from your account page.</p>
      <h3>8. Changes to This Policy</h3>
      <p>We may update this Privacy Policy from time to time. Any changes will be posted on this page.</p>
      <h3>9. Contact Us</h3>
      <p>If you have any questions about this Privacy Policy or how your information is handled, please contact us at #{configatron.admin_email}.</p>
    HTML
  }
].each do |attrs|
  snippet = Snippet.find_or_initialize_by(key: attrs[:key])
  snippet.title = attrs[:title]
  snippet.content = attrs[:content]
  snippet.save!
  puts "  - #{attrs[:key]}"
end

puts "Snippets created."
