raw = begin
  Rails.application.config_for(:risk_scoring)
rescue StandardError
  {}
end
RISK_SCORING = (raw.presence || {}).deep_symbolize_keys
