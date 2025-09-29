# app/services/party_lookup.rb
class PartyLookup
  def self.by_tax_id(raw)
    norm = Party::Identifier.normalize(raw, guess_type(raw))
    bidx = BlindIndex.generate_bidx(norm, key: BlindIndex.master_key)
    # preferred: via identifiers
    p = Party::Party.joins(:identifiers)
      .where(party_identifiers: { id_type_code: %w[ssn itin ein foreign_tin], value_bidx: bidx })
      .first
    return p if p

    # fallback during migration window
    Party::Party.find_by(tax_id_bidx: bidx)
  end

  def self.guess_type(raw)
    s = raw.to_s.gsub(/\D/, "")
    return "ein" if s.length == 9 && raw.to_s.include?("-")
    return "ssn" if s.length == 9
    "foreign_tin"
  end
end
