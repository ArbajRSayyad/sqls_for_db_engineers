-- for table creation and data insert scripts, refer my another repo
-- Repo : https://github.com/ArbajRSayyad/asset_management_oracleToPostgres/tree/main/PLpgSQL

--1.Report to get details of assets held by accounts.
--Include accounts which don't have assets
-- LEFT JOIN
select act.account_id, act.acct_fullname,
	   aam.business_dt,aa.asset_id,
	   aam.map_from_tmstmp, aam.map_to_tmstmp, aam.update_tmstmp
from accounts act
left join account_asset_map aam
on act.account_id = aam.account_id
left join asset_allocation aa
on aam.acct_ast_map_id = aa.acct_ast_map_id
where act.account_active_ind = 'Y'
order by account_id, map_from_tmstmp,aa.asset_id;

--2.1 Get the account with second highest number of assets on a business date
-- Using window/analytical function
with acct_assets as
(
    select act.account_id, aam.business_dt,count(aa.asset_id) no_of_assets
    from accounts act
    join account_asset_map aam
    on act.account_id = aam.account_id
    and aam.active_ind = 'Y'
    join asset_allocation aa
    on aam.acct_ast_map_id = aa.acct_ast_map_id
    where act.account_active_ind = 'Y'
    group by act.account_id, aam.business_dt
),
acct_rnk as
(   select account_id, business_dt,no_of_assets,
    rank()over(order by no_of_assets desc) rnk
    from acct_assets
)
select account_id,business_dt,no_of_assets
from acct_rnk where rnk=2;

--2.1 Get the account with second highest number of assets on a business date
-- Without using window/analytical function
with acct_assets as
(
    select act.account_id, aam.business_dt,count(aa.asset_id) no_of_assets
    from accounts act
    join account_asset_map aam
    on act.account_id = aam.account_id
    and aam.active_ind = 'Y'
    join asset_allocation aa
    on aam.acct_ast_map_id = aa.acct_ast_map_id
    group by act.account_id, aam.business_dt
),
mx_ast as
(
	select max(no_of_assets) second_max
	from acct_assets
	where no_of_assets<(select max(no_of_assets) from acct_assets)
)
select account_id,business_dt,no_of_assets
from acct_assets join mx_ast
on no_of_assets = second_max;

--3. Get possible asset allocation for all accounts on business date
-- CROSS JOIN
select account_id, asset_id
from accounts acct
cross join assets
where business_dt = '06-OCT-2026';

--4. Get previous day price
-- Using LAG
select asset_id, business_dt, description, usd_price,
coalesce(lag(usd_price)over(partition by asset_id order by business_dt), usd_price) as previous_day_price
from assets
order by asset_id;

--5. Get total value in USD accumulated by each account for each row
-- Running total
select act.account_id, coalesce(aam.business_dt,'01-JAN-1970'),
coalesce(sum(usd_price)over(order by act.account_id),0) as running_total
from accounts act
left join account_asset_map aam
on act.account_id = aam.account_id
and aam.active_ind = 'Y'
left join asset_allocation aa
on aam.acct_ast_map_id = aa.acct_ast_map_id
left join assets ast
on aa.asset_id = ast.asset_id
and aam.business_dt = ast.business_dt;