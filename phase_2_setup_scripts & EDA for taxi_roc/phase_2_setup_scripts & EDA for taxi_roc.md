#  For-Hire Vehicle Trip Records — Jan to Dec 2023  
## PostgreSQL Setup Scripts: Import Raw Data, Create Schema, Define Types
---
### tables Created

#### 1. `fhv_trip`

This table stores trip-level records for For-Hire Vehicles (FHV), including pickup/dropoff timestamps and zone identifiers.
```sql
CREATE TABLE fhv_trip (
    dispatching_base_num VARCHAR,
    pickup_datetime TIMESTAMP,  --timestamp using data and time: ‘2023-01-01 01:00:00’
    dropoff_datetime TIMESTAMP,
    pulocationid INT,
    dolocationid INT,
    sr_flag BOOLEAN,
    affiliated_base_number VARCHAR,
    FOREIGN KEY (pulocationid) REFERENCES taxi_zone_lookup(locationid),
    FOREIGN KEY (dolocationid) REFERENCES taxi_zone_lookup(locationid)
);
```
pulocationid and dolocationid are foreign keys referencing the taxi_zone_lookup table to identify the pickup and dropoff zones.

#### 2. `taxi_zone_lookup`
This lookup table provides descriptive information about each zone ID, including borough and service type.

```sql
CREATE TABLE taxi_zone_lookup (
    locationid INT PRIMARY KEY,
    borough VARCHAR,
    zone VARCHAR,
    service_zone VARCHAR
);
```
-----------------------
## Exploratory Data Analysis (EDA) 
##### These two tables' based information.
```sql
select * from fhv_trip ft;
```
![FHV](https://github.com/user-attachments/assets/d83bd7d3-b96f-4c84-85b2-9b20354ff1c0)

```sql
select * from taxi_zone_lookup;
```
![taxi_zooe_lookup](https://github.com/user-attachments/assets/5fa4a86f-e2b4-4ef3-96d4-5c1100ec70c1)




### Check for missing (null) values in each column of the dataset.
```sql
-- Null counts per column:
SELECT
  COUNT(*) FILTER (WHERE dispatching_base_num IS NULL) AS null_dispatching_base_num,
  COUNT(*) FILTER (WHERE pickup_datetime IS NULL) AS null_pickup_datetime,
  COUNT(*) FILTER (WHERE dropoff_datetime IS NULL) AS null_dropoff_datetime,
  COUNT(*) FILTER (WHERE pulocationid IS NULL) AS null_pulocationid,
  COUNT(*) FILTER (WHERE dolocationid IS NULL) AS null_dolocationid,
  COUNT(*) FILTER (WHERE sr_flag IS NULL) AS null_sr_flag,
  COUNT(*) FILTER (WHERE affiliated_base_number IS NULL) AS null_affiliated_base_number
FROM fhv_trip;
```
![fhv_null-V](https://github.com/user-attachments/assets/8b0b6b03-06b4-4ebc-8b95-ff199987dd01)


### check for the most common pickup and drop off zones
```sql
-- Most common pickup zones (by ID)
SELECT 
    ft.pulocationid, 
    COUNT(*) AS pickup_count, 
    tzl.borough, 
    tzl.zone
FROM fhv_trip ft
JOIN taxi_zone_lookup tzl 
    ON ft.pulocationid = tzl.locationid
WHERE ft.pulocationid IS NOT NULL
GROUP BY ft.pulocationid, tzl.borough, tzl.zone
ORDER BY pickup_count DESC
LIMIT 10;
```
![MCPu](https://github.com/user-attachments/assets/250a2540-64c2-49b5-956b-56b11053b83d)

```sql
-- Most common drop-off zones (by ID)
SELECT 
    ft.dolocationid , 
    COUNT(*) AS drop_off_count, 
    tzl.borough, 
    tzl.zone
FROM fhv_trip ft
JOIN taxi_zone_lookup tzl 
    ON ft.dolocationid = tzl.locationid
WHERE ft.dolocationid IS NOT NULL
GROUP BY ft.dolocationid, tzl.borough, tzl.zone
ORDER BY drop_off_count DESC
LIMIT 10;
```
![MCDO](https://github.com/user-attachments/assets/d98294f1-5444-4971-94b0-fedfa82d5028)

### the trip duration
```sql
-- Trip duration (in minutes):
SELECT
  MIN(EXTRACT(EPOCH FROM dropoff_datetime - pickup_datetime) / 60) AS min_duration_min,
  MAX(EXTRACT(EPOCH FROM dropoff_datetime - pickup_datetime) / 60) AS max_duration_min,
  AVG(EXTRACT(EPOCH FROM dropoff_datetime - pickup_datetime) / 60) AS avg_duration_min,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM dropoff_datetime - pickup_datetime) / 60) AS median_duration_min
FROM fhv_trip
WHERE dropoff_datetime > pickup_datetime
AND EXTRACT(EPOCH FROM dropoff_datetime - pickup_datetime) / 60 BETWEEN 1 AND 180;
```
![trip_duration](https://github.com/user-attachments/assets/5a0c2186-9aa1-4546-80ef-11577bde970b)

in the sql, the **EXTRACT(EPOCH FROM dropoff_datetime - pickup_datetime)/ 60** meaning:
dropoff_datetime - pickup_datetime calculates the time interval between the pickup and dropoff.
- EXTRACT(EPOCH FROM interval) converts that interval into the total number of seconds.
- For example:
TIMESTAMP '2023-01-01 01:00:00' - TIMESTAMP '2023-01-01 00:00:00'
results in an interval of 1 hour, which is 3600 seconds.
Dividing by 60 converts the result from seconds to minutes.
```sql
TIMESTAMP '2023-01-01 01:00:00' - TIMESTAMP '2023-01-01 00:00:00' = 3600 seconds = 60 minutes
```








