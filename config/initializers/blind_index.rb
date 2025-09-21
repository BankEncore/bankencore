# config/initializers/blind_index.rb
require "base64"

raw =
  Rails.application.credentials.dig(:blind_index, :master_key) ||
  ENV["BLIND_INDEX_MASTER_KEY"] ||
  ""

raw = raw.to_s.strip

key =
  if raw.match?(/\A[0-9a-fA-F]{64}\z/)        # 64 hex → 32 bytes
    [raw].pack("H*")
  elsif raw.start_with?("b64:")               # optional base64 support
    Base64.strict_decode64(raw.delete_prefix("b64:"))
  else
    raw                                       # assume raw 32-byte string
  end

if key.bytesize != 32
  warn "[blind_index] invalid key length=#{key.bytesize.inspect}. " \
       "Provide 64 hex chars in credentials at blind_index.master_key " \
       "or set BLIND_INDEX_MASTER_KEY."
  # In dev/test, fall back so you can boot:
  if Rails.env.development? || Rails.env.test?
    key = "\x00" * 32
    warn "[blind_index] using DEV fallback key (DO NOT USE IN PROD)"
  else
    raise "BlindIndex master key missing/invalid"
  end
end

BlindIndex.master_key = key
