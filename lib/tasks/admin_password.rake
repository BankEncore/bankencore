# lib/tasks/admin_password.rake
require "io/console"

namespace :admin do
  desc "Set password for admin@example.com (creates user if missing)"
  task set_password: :environment do
    email = "admin@example.com"

    print "New password: "
    pw1 = STDIN.noecho(&:gets).to_s.strip
    puts
    print "Confirm password: "
    pw2 = STDIN.noecho(&:gets).to_s.strip
    puts

    abort("Passwords do not match.") unless pw1 == pw2
    abort("Password cannot be blank.") if pw1.empty?

    user = User.find_or_initialize_by(email_address: email)
    if user.new_record?
      user.first_name = "Admin"
      user.last_name  = "User"
    end

    user.password = pw1
    user.password_confirmation = pw2
    user.save!

    puts "Password set for #{email}."
  rescue => e
    warn "Error: #{e.class}: #{e.message}"
    exit 1
  end
end
