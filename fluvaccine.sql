/*
Objective: Create a flu shots dashboard for 2022 that does the following

1.) Total % of patients getting flu shots stratified by
	a) Age
	b) Race
	c) County (on a map)
	d) Overall
2.) Running Total of Flu Shots over the course of 2022
3.) Total # of of flu shots given in 2022
4.) A list of patients that show whether or not they received the flu shots

Requirements:
Patients must have been *Active* at the hospital
*/

with active_patients as
(
	select patient
	from encounters as en
	join patients as pt
	on en.patient = pt.id
	where start between '2020-01-01 00:00' and '2022-12-31 23:59'
	and pt.deathdate is null
	and extract (month from age('2022-12-31', pt.birthdate)) >= 6
),

flu_shot_2022 as
(
select patient, min(date) as earliest_flu_shot_2022
from immunizations
where code = '5302' --seasonal flu vaccine
	and date between '2022-01-01 00:00' and '2022-12-31 23:59'
group by patient
)

select pt.birthdate
      ,pt.race
	  ,pt.county
	  ,pt.id
	  ,pt.first
	  ,pt.last
	  ,flu.earliest_flu_shot_2022
	  ,flu.patient
	  , extract(YEAR FROM age('12-31-2022', birthdate)) as age
	  , case when flu.patient is not null then 1
	  else 0
	  end as flu_shot_2022
from patients as pt
left join flu_shot_2022 as flu
	on pt.id = flu.patient
where 1 = 1
	and pt.id in (select patient from active_patients);

