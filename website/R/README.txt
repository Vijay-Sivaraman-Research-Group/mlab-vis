##############################################################
#					READ ME				    #
##############################################################


---------------
IP_facet_raw.R
---------------

Input:

	Rscript IP_facet_raw.R <year> <month> <IP_address> <metric to be represented by colour*>

Output:

	1. Raw speed scatter plot facet by (month,day) for a particular year,month (user input) with line representing median aggregated by hour
	2. Raw speed scatter plot facet by (month,hour) for a particular year,month (user input) with line representing median aggregated by hour



-----------------------------
IP_nonfacet_raw_DayVsSpeed.R
-----------------------------

Input:

	Rscript IP_nonfacet_raw_DayVsSpeed.R <year> <month> <IP_address> <metric to be represented by colour*>

*download_speed, AveRTT, or congestion_signals

e.g. Rscript IP_nonfacet_raw_DayVsSpeed.R 2015 3 14.201.217.164 download_speed

Output:

	1. Raw speed scatter plot as a function of day for a particular month,year (user input) with line representing median aggregated by day over a month


------------------------------
IP_nonfacet_raw_HourVsSpeed.R
------------------------------

Input:

	Rscript IP_nonfacet_raw_HourVsSpeed.R <year> <month> <IP_address> <metric to be represented by colour*>

*download_speed, AveRTT, or congestion_signals

e.g. Rscript IP_nonfacet_raw_HourVsSpeed.R 2015 3 14.201.217.164 download_speed

Output:

	1. Raw speed scatter plot as a function of hour for a particular month,year (user input) with line representing median aggregated by day over a month


-------------------------------
IP_nonfacet_raw_MonthVsSpeed.R
-------------------------------

Input:

	Rscript IP_nonfacet_raw_HourVsSpeed.R <year> <IP_address> <metric to be represented by colour*>

*download_speed, AveRTT, or congestion_signals

e.g. Rscript IP_nonfacet_raw_HourVsSpeed.R 2015 14.201.217.164 AveRTT

Output:

	1. Raw speed scatter plot as a function of month for a particular year (user input) with line representing median aggregated by month


-----------------
ISP_facet_norm.R
-----------------

Input:

	Rscript ISP_facet_norm.R <year> <month> <ISP>

e.g. Rscript ISP_facet_norm.R 2015 3 tpg


Output:

	1. Normalised speed scatter plot facet by (month,day) for a particular year,month (user input) with line representing median aggregated by hour over month. Each colour representing each household.
	2. Normalised speed scatter plot facet by (month,hour) for a particular year,month (user input) with line representing median aggregated by hour over month. Each colour representing each household.


----------------
ISP_facet_raw.R
----------------

Input:

	Rscript ISP_facet_raw.R <year> <month> <ISP>

e.g. Rscript ISP_facet_raw.R 2015 3 tpg


Output:

	1. Raw speed scatter plot facet by (month,day) for a particular year,month (user input) with line representing median aggregated by hour over month. Each colour representing each household.
	2. Raw speed scatter plot facet by (month,hour) for a particular year,month (user input) with line representing median aggregated by hour over month. Each colour representing each household.



--------------------------------
ISP_nonfacet_norm_HourVsSpeed.R
--------------------------------

Input:

	Rscript ISP_nonfacet_norm_HourVsSpeed.R <year> <month*> <ISP1> <ISP2> <ISP3> <ISP4> <ISP5> <ISP6>  

*User can optionally use 'all' for month field for information to be aggregated over one year (all months)

e.g. Rscript ISP_nonfacet_norm_HourVsSpeed.R 2015 3 tpg telstra iinet optus

e.g. Rscript ISP_nonfacet_norm_HourVsSpeed.R 2015 all tpg telstra iinet optus

Output:

	1. Norm speed plot as a function of hour for a particular year,month (user input), aggregated by median



---------------------------------
ISP_nonfacet_norm_MonthVsSpeed.R
---------------------------------

Input:

	Rscript ISP_nonfacet_norm_MonthVsSpeed.R <year> <ISP1> <ISP2> <ISP3> <ISP4> <ISP5> <ISP6>  


e.g. Rscript ISP_nonfacet_norm_MonthVsSpeed.R 2015 tpg telstra iinet


Output:

	1. Norm speed plot as a function of month for a particular year(user input), aggregated by median



-------------------------------
ISP_nonfacet_raw_HourVsSpeed.R
-------------------------------

Input:

	Rscript ISP_nonfacet_raw_HourVsSpeed.R <year> <month*> <ISP1> <ISP2> <ISP3> <ISP4> <ISP5> <ISP6>  

*User can optionally use 'all' for month field for information to be aggregated over one year (all months)

e.g. Rscript ISP_nonfacet_raw_HourVsSpeed.R 2015 3 tpg telstra iinet optus

e.g. Rscript ISP_nonfacet_raw_HourVsSpeed.R 2015 all tpg telstra iinet optus

Output:

	1. Raw speed plot as a function of hour for a particular year,month (user input), aggregated by median


--------------------------------
ISP_nonfacet_raw_MonthVsSpeed.R
--------------------------------

Input:

	Rscript ISP_nonfacet_raw_MonthVsSpeed.R <year> <ISP1> <ISP2> <ISP3> <ISP4> <ISP5> <ISP6>  


e.g. Rscript ISP_nonfacet_raw_MonthVsSpeed.R 2015 tpg telstra iinet


Output:

	1. Raw speed plot as a function of month for a particular year(user input), aggregated by median

