# db/migrate/20250930_add_scoring_to_screenings.rb
class AddScoringToScreenings < ActiveRecord::Migration[7.2]
  def change
    change_table :party_screenings do |t|
      t.integer :normalized_score                         # 0–100
      t.integer :match_strength                           # 0–100 (optional)
      t.text    :risk_notes
    end
    change_table :parties do |t|
      t.integer :party_risk_score                         # 0–100 aggregate
      t.integer :risk_band                                # enum: 0=low,1=medium,2=high
    end
  end
end
