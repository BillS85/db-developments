-- removing leading . in occupancy code value
UPDATE developments
SET occ_init = split_part(occ_init, '.', 2)
WHERE occ_init LIKE '.%';

UPDATE developments
SET occ_prop = split_part(occ_prop, '.', 2)
WHERE occ_prop LIKE '.%';

-- make units null when it doesn't contain only numbers
UPDATE developments a
SET units_prop = NULL 
WHERE a.units_prop ~ '[^0-9]';