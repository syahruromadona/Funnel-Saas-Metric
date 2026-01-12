-- To standardize data entries

CREATE TABLE std_table as

SELECT
	user_id,
	signup_date,
	source_std,
	plan_selected,
	trial_started_std,
	trial_start_date,
	activated_std,
	activation_days,
	converted_paid_std,
	conversion_date,
	mrr_std,
	country_std,
	churned_30d_std
from (

select 
*,
CASE
	when trial_started IN (true, 'true','TRUE', 'True' ,'yes','YES', 'Yes', '1') THEN true
	WHEN trial_started is NULL then NULL
	ELSE false
end as trial_started_std,

CASE
	WHEN activated IN (true, 'true','TRUE', 'True' ,'yes','YES', 'Yes', '1') then true
	WHEN activated is null then NULL
	else false
end as activated_std,

CASE	
	when converted_paid IN (true, 'true','TRUE', 'True' ,'yes','YES', 'Yes', '1') then true
	when converted_paid is null then NULL
	ELSE false
end as converted_paid_std,

case
	when churned_30d IN (true, 'true','TRUE', 'True' ,'yes','YES', 'Yes', '1') then true
	when churned_30d is null then NULL
	ELSE false
end as churned_30d_std,

CASE
	WHEN source IN ('GAds', 'google ads') THEN 'Google Ads'
	WHEN source IN ('FB Ads') THEN 'FB ads'
	WHEN source IN ('LinkedIn') THEN 'LinkedIn'
	WHEN source IN ('Referral') THEN 'Referral'
	WHEN source IN ('Organic') THEN 'Organic'
	ELSE 'Others'
	end as source_std,

CASE
		WHEN trim(country) IN ('Indonesia') THEN 'Indonesia'
		WHEN Trim(country) IN ('MY', 'Malaysia') THEN 'Malaysia'
		WHEN trim(country) IN ('SG', 'Singapore') THEN 'Singapore'
		ELSE 'Others'
END as country_std,


CAST(coalesce(mrr_usd,0) as INT) as mrr_std

from saas_funnel_dirty_10k

) as std_table

-- Deleting invalide row

DELETE FROM std_table
WHERE user_id is NULL
	OR signup_date is NULL
	OR conversion_date < signup_date
	OR activation_days < 0
	OR (activated_std = true AND trial_start_date IS NULL)
	OR (converted_paid_std = true AND conversion_date IS NULL)
	OR (converted_paid_std = true AND mrr_std = 0)

-- Creating new table after deduplication

CREATE TABLE dedup_table as

SELECT * 
from (
SELECT *,
	row_number() over(
		PARTITION by user_id, signup_date, source_std, plan_selected 
		ORDER by
		converted_paid_std DESC,
		activated_std DESC,
		trial_started_std DESC,
		churned_30d_std ASC
		) as row_num
from std_table
) as dedup_table
where row_num =1;

-- Categorizing user

-- is_trial

ALTER TABLE dedup_table
ADD is_trial BOOLEAN;

update dedup_table
set is_trial =
CASE WHEN 
(trial_started_std = true AND trial_start_date is not null) then true 
else false 
end

-- is_activated

ALTER TABLE dedup_table
ADD is_activated BOOLEAN;

UPDATE dedup_table
set is_activated = 
		CASE 
		WHEN (is_trial = true 
				AND activated_std = true
				AND activation_days is not null) 
				AND activation_days >= 0
				then true
		ELSE false
		END


-- is_converted

ALTER TABLE
ADD is_converted BOOLEAN

update dedup_table
set is_converted = 
	case 
		when is_activated = true
		and converted_paid_std = true
		and conversion_date is not NULL 
		and mrr_std > 0
		then true
	else false
	end;

-- Final table to analyse

SELECT
	source_std,
	count ( case when is_trial = true then 1 end) as trial_users,
	count (case when is_activated = true then 1 end) as activated_users,
	count ( case when is_converted = true then 1 end) as converted_users,
	
	ROUND(
		count(case when is_activated = true then 1 end)*1.0/
		count( case when is_trial = true then 1 end),3)
	as trial_to_activated_pct,
	
	ROUND(
		count(case when is_converted = true then 1 end)*1.0/
		count(case when is_activated=true then 1 end),3)
	as activated_to_converted_pct,
	
	ROUND(AVG(activation_days), 2) AS avg_activation_days,
	
	ROUND(avg(case when is_converted=true then mrr_std end),2) as avg_mrr,
	ROUND(AVG(case when is_converted =true then churned_30d_std END)*100,2) as avg_churned_30
	
from dedup_table

GROUP by source_std
