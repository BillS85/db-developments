-- populate the status field using the housing_input_lookup_status lookup table
UPDATE developments a
SET status = b.dcpstatus
FROM housing_input_lookup_status b
WHERE a.status=b.dobstatus;

-- update status to 'Complete (demolition)' where dob_type ='DM' AND dcp_status = 'Complete' or 'Permit issued'
UPDATE developments a
SET status =
	(CASE
		WHEN job_type = 'Demolition' AND status IN ('Complete','Permit issued') THEN 'Complete (demolition)'
		ELSE status
	END);

-- set the status to withdrawn based on the x_withdrawal attribute value
UPDATE developments
SET status = 'Withdrawn'
WHERE x_withdrawal = 'W' OR x_withdrawal = 'C';

ALTER TABLE developments
DROP COLUMN x_withdrawal;