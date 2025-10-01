-- Columns: code (PK), name
INSERT INTO ref_party_group_types (code, name) VALUES
  ('household',        'Household'),
  ('corporate_family', 'Corporate family'),
  ('trust',            'Trust'),
  ('estate',           'Estate'),
  ('org_unit',         'Organization unit'),
  ('association',      'Association or club'),
  ('customer_segment', 'Customer segment')
ON DUPLICATE KEY UPDATE name=VALUES(name);
