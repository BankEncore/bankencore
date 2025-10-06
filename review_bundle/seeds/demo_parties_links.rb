# Minimal demo data to exercise UI. No PII.
ActiveRecord::Base.transaction do
  # Parties
  person = Party::Person.find_or_create_by!(public_id: '00000000-0000-0000-0000-000000000001') do |p|
    p.first_name = 'Alex'; p.last_name = 'Demo'; p.primary = true
  end
  org = Party::Organization.find_or_create_by!(public_id: '00000000-0000-0000-0000-000000000010') do |o|
    o.legal_name = 'Demo Org LLC'; o.primary = true
  end

  # Ensure reference link types exist if seeds not run
  plt = Ref::PartyLinkType.find_by(code: 'employer_of') || Ref::PartyLinkType.create!(
    code: 'employer_of', name: 'Employer Of', symmetric: false,
    allowed_from_party_types: %w[organization],
    allowed_to_party_types: %w[person]
  )
  inverse = Ref::PartyLinkType.find_by(code: 'employee_of') || Ref::PartyLinkType.create!(
    code: 'employee_of', name: 'Employee Of', symmetric: false,
    inverse_code: 'employer_of',
    allowed_from_party_types: %w[person],
    allowed_to_party_types: %w[organization]
  )
  plt.update!(inverse_code: 'employee_of') if plt.inverse_code != 'employee_of'

  # Link
  Party::Link.find_or_create_by!(from_party: org, to_party: person, link_type_code: 'employer_of') do |l|
    l.started_on = Date.new(2020, 1, 1)
  end
end
