# lib/tasks/backfill_identifiers.rake
namespace :data do
  desc "Backfill PartyIdentifiers from parties.tax_id"
  task backfill_identifiers: :environment do
    batch = 1000
    total = Party::Party.where.not(tax_id: nil).count
    puts "Backfilling #{total} parties…"
    Party::Party.where.not(tax_id: nil).find_in_batches(batch_size: batch).with_index do |parties, i|
      Party::Identifier.transaction do
        parties.each do |p|
          next if p.tax_id.blank?
          type = p.party_type == "organization" ? "ein" : "ssn"
          next if p.identifiers.exists?(id_type_code: type, is_primary: true)
          Party::Identifier.create!(
            party: p,
            id_type_code: type,
            is_primary: true,
            value: p.tax_id # normalization + encryption run in callbacks
          )
        end
      end
      puts "  batch #{i+1}: #{[ i*batch, total ].min}/#{total}"
    end
    puts "Done."
  end
end
