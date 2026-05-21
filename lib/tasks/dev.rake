namespace :dev do
  desc "Clear all booking and purchase data (development only). Users are preserved."
  task reset_bookings: :environment do
    abort "This task only runs in development." unless Rails.env.development?

    counts = {
      purchases:                 Purchase.count,
      add_ons:                   AddOn.count,
      group_class_registrations: GroupClassRegistration.count,
      bookings:                  Booking.count,
      class_credit_purchases:    ClassCreditPurchase.count
    }

    ActiveRecord::Base.transaction do
      Purchase.delete_all
      AddOn.delete_all
      GroupClassRegistration.delete_all
      Booking.delete_all
      ClassCreditPurchase.delete_all
    end

    puts "Done. Deleted:"
    counts.each { |table, n| puts "  #{table}: #{n} rows" }
  end
end
