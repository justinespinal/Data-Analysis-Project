CREATE TABLE taxi_zone_lookup (
    locationid INT PRIMARY KEY,
    borough VARCHAR,
    zone VARCHAR,
    service_zone VARCHAR
);

-- Replace the path with the path for your dataset.
copy taxi_zone_lookup FROM 'C:/dataset/pj/look_up/taxi_zone_lookup.csv' WITH (FORMAT csv, HEADER);

CREATE TABLE fhv_trip (
    dispatching_base_num VARCHAR,
    pickup_datetime TIMESTAMP,
    dropoff_datetime TIMESTAMP,
    pulocationid INT,
    dolocationid INT,
    sr_flag BOOLEAN,
    affiliated_base_number VARCHAR,
    FOREIGN KEY (pulocationid) REFERENCES taxi_zone_lookup(locationid),
    FOREIGN KEY (dolocationid) REFERENCES taxi_zone_lookup(locationid)
);


drop table fhv_trip;

-- Replace the path with the path for your dataset.
COPY fhv_trip FROM 'C:/dataset/pj/fhv_trip/fhv_trip_all.csv' WITH (FORMAT csv, HEADER);



select * from fhv_trip;
select * from taxi_zone_lookup;


SELECT COUNT(*)
FROM fhv_trip ft
WHERE ft.pulocationid IS NULL;

SELECT COUNT(*)
FROM fhv_trip ft
WHERE ft.dolocationid IS NULL;

SELECT COUNT(*)
FROM fhv_trip ft;

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


-- Trip duration (in minutes):
SELECT
  MIN(EXTRACT(EPOCH FROM dropoff_datetime - pickup_datetime) / 60) AS min_duration_min,
  MAX(EXTRACT(EPOCH FROM dropoff_datetime - pickup_datetime) / 60) AS max_duration_min,
  AVG(EXTRACT(EPOCH FROM dropoff_datetime - pickup_datetime) / 60) AS avg_duration_min,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM dropoff_datetime - pickup_datetime) / 60) AS median_duration_min
FROM fhv_trip
WHERE dropoff_datetime > pickup_datetime
AND EXTRACT(EPOCH FROM dropoff_datetime - pickup_datetime) / 60 BETWEEN 1 AND 180;

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