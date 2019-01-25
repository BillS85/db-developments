DELETE FROM developments a
USING housing_input_removals b
WHERE a.job_number=b.job_number;