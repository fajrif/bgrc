# Six-digit email codes for accounts created or signed into from the payment modal. The guest
# verifies without leaving the page they are paying on, so their order and its countdown stay in
# front of them. Only a keyed digest of the code is stored.
module EmailVerificationCode
  extend ActiveSupport::Concern

  MAX_ATTEMPTS = 5
  RESEND_COOLDOWN = 60.seconds

  class_methods do
    def verification_code_ttl
      Integer(ENV.fetch("VERIFICATION_CODE_TTL_MINUTES", 10)).minutes
    end
  end

  # Emails a fresh code. Returns false, sending nothing, while the previous one is under a minute old.
  def send_verification_code!
    return false if verification_resend_wait.positive?

    code = format("%06d", SecureRandom.random_number(1_000_000))
    update_columns(
      verification_code_digest: verification_digest(code),
      verification_code_sent_at: Time.current,
      verification_attempts: 0,
    )
    UserMailer.with(user: self, code: code).verification_code.deliver_now
    true
  end

  # Seconds until another code may be sent.
  def verification_resend_wait
    return 0 if verification_code_sent_at.blank?

    [(verification_code_sent_at + RESEND_COOLDOWN - Time.current).ceil, 0].max
  end

  # Returns :verified, :invalid, :locked (too many wrong tries) or :expired (no live code).
  def verify_code!(code)
    if verification_code_digest.blank? || verification_code_sent_at < self.class.verification_code_ttl.ago
      return :expired
    end
    return :locked if verification_attempts >= MAX_ATTEMPTS

    given = verification_digest(code.to_s.gsub(/\D/, ""))
    unless ActiveSupport::SecurityUtils.secure_compare(given, verification_code_digest)
      increment!(:verification_attempts)
      return verification_attempts >= MAX_ATTEMPTS ? :locked : :invalid
    end

    transaction do
      confirm unless confirmed?
      update_columns(verification_code_digest: nil, verification_code_sent_at: nil, verification_attempts: 0)
    end
    :verified
  end

  private

  def verification_digest(code)
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, "#{id}:#{code}")
  end
end
