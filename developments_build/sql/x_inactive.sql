-- Tag projects that have been inactive for at least 5 years
UPDATE developments
	SET x_inactive =
		(CASE
			WHEN (CURRENT_DATE - status_date::date)/365 >= 5 THEN TRUE
			ELSE FALSE
		END)
	WHERE
		status <> 'Complete'
		AND status <> 'Complete (demolition)'
		AND status <> 'SIGNED OFF'
		AND status <> 'SIGNED-OFF';

UPDATE developments
	SET x_inactive = FALSE
	WHERE x_inactive IS NULL;