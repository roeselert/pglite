-- Run this in PostgreSQL. Creates trains, stations, journey tables, a view joining them, and populates with test data.
 BEGIN;

-- 1) Tables

CREATE TABLE trains (id SERIAL PRIMARY KEY,
                    code VARCHAR(20) NOT NULL UNIQUE,
                    TYPE VARCHAR(50),
                    OPERATOR VARCHAR(100),
                    capacity INTEGER, 
                    created_at TIMESTAMPTZ DEFAULT now()
  );


CREATE TABLE stations (id SERIAL PRIMARY KEY,
                       code VARCHAR(10) NOT NULL UNIQUE,
                       name VARCHAR(200) NOT NULL,
                       city VARCHAR(100),
                       latitude NUMERIC(9, 6),
                       longitude NUMERIC(9, 6),
                       created_at TIMESTAMPTZ DEFAULT now()
  );


CREATE TABLE journey (id SERIAL PRIMARY KEY,
                       train_id INTEGER NOT NULL REFERENCES trains(id) ON DELETE CASCADE,
                       station_id INTEGER NOT NULL REFERENCES stations(id) ON DELETE CASCADE,
                       stop_sequence INTEGER NOT NULL,
                       scheduled_arrival TIMESTAMPTZ,
                       scheduled_departure TIMESTAMPTZ,
                       actual_arrival TIMESTAMPTZ,
                       actual_departure TIMESTAMPTZ,
                       platform VARCHAR(10),
                       status VARCHAR(20) NOT NULL DEFAULT 'scheduled',
                       created_at TIMESTAMPTZ DEFAULT now(),
                       UNIQUE (train_id, stop_sequence));

-- Helpful indexes

CREATE INDEX idx_journey_train ON journey(train_id);

CREATE INDEX idx_journey_station ON journey(station_id);

CREATE INDEX idx_journey_sched_arrival ON journey(scheduled_arrival);

-- 2) View joining trains + stations to journey

CREATE VIEW journey_view AS
SELECT j.id AS journey_id,
       t.id AS train_id,
       t.code AS train_code,
       t.type AS train_type,
       t.operator AS train_operator,
       s.id AS station_id,
       s.code AS station_code,
       s.name AS station_name,
       s.city AS station_city,
       j.stop_sequence,
       j.scheduled_arrival,
       j.scheduled_departure,
       j.actual_arrival,
       j.actual_departure,
       j.platform,
       j.status
FROM journey j
JOIN trains t ON j.train_id = t.id
JOIN stations s ON j.station_id = s.id;

-- 3) Test data: trains

INSERT INTO trains (code, TYPE,
                    OPERATOR, capacity)
VALUES ('ICE123', 'Intercity Express', 'DB Fernverkehr', 500),
       ('RE456', 'Regional Express', 'DB Regio', 300),
       ('S1', 'S-Bahn', 'CityRail', 200);

-- 4) Test data: stations

INSERT INTO stations (code, name, city, latitude, longitude)
VALUES ('BER', 'Berlin Hbf', 'Berlin', 52.525084, 13.369402),
       ('LEJ', 'Leipzig Hbf', 'Leipzig',51.339695, 12.373075),
       ('DRE', 'Dresden Hbf', 'Dresden',51.040769, 13.730497),
       ('HAL', 'Halle(Saale) Hbf', 'Halle', 51.481844, 11.969827),
       ('MD', 'Magdeburg Hbf', 'Magdeburg', 52.120533, 11.627623);

-- 5) Test data: journeys (stops for trains) -- ICE123: Berlin -> Leipzig -> Halle -> Dresden

INSERT INTO journey (train_id, station_id, stop_sequence, scheduled_arrival, scheduled_departure, actual_arrival, actual_departure, platform, status)
VALUES ((SELECT id FROM trains WHERE code='ICE123'), (SELECT id FROM stations WHERE code='BER'), 1, '2025-12-22 08:00:00+00', '2025-12-22 08:05:00+00', '2025-12-22 08:00:30+00', '2025-12-22 08:05:30+00', '5', 'departed'),
       ((SELECT id FROM trains WHERE code='ICE123'), (SELECT id FROM stations WHERE code='LEJ'), 2, '2025-12-22 09:15:00+00', '2025-12-22 09:20:00+00', '2025-12-22 09:20:00+00', '2025-12-22 09:25:00+00', '2', 'delayed'),
       ((SELECT id FROM trains WHERE code='ICE123'), (SELECT id FROM stations WHERE code='HAL'), 3, '2025-12-22 10:00:00+00', '2025-12-22 10:05:00+00', NULL, NULL, NULL, 'scheduled'),
       ((SELECT id FROM trains WHERE code='ICE123'), (SELECT id FROM stations WHERE code='DRE'), 4, '2025-12-22 11:30:00+00', '2025-12-22 11:35:00+00', NULL, NULL, NULL, 'scheduled');

-- RE456: Magdeburg -> Halle -> Leipzig -> Berlin

INSERT INTO journey (train_id, station_id, stop_sequence, scheduled_arrival, scheduled_departure, actual_arrival, actual_departure, platform, status)
VALUES ((SELECT id FROM trains WHERE code='RE456'), (SELECT id FROM stations WHERE code='MD'), 1, '2025-12-22 07:00:00+00', '2025-12-22 07:05:00+00', '2025-12-22 07:00:00+00', '2025-12-22 07:05:00+00', '1', 'departed'),
       ((SELECT id FROM trains WHERE code='RE456'), (SELECT id FROM stations WHERE code='HAL'), 2, '2025-12-22 07:50:00+00', '2025-12-22 07:55:00+00', '2025-12-22 07:52:00+00', '2025-12-22 07:58:00+00', '3', 'departed'),
       ((SELECT id FROM trains WHERE code='RE456'), (SELECT id FROM stations WHERE code='LEJ'), 3, '2025-12-22 08:40:00+00', '2025-12-22 08:45:00+00', NULL, NULL, NULL, 'scheduled'),
       ((SELECT id FROM trains WHERE code='RE456'), (SELECT id FROM stations WHERE code='BER'), 4, '2025-12-22 10:00:00+00', NULL, NULL, NULL, NULL, 'scheduled');

-- S1: local S-Bahn with short hops: Berlin -> Magdeburg (example)

INSERT INTO journey (train_id, station_id, stop_sequence, scheduled_arrival, scheduled_departure, actual_arrival, actual_departure, platform, status)
VALUES ((SELECT id FROM trains WHERE code='S1'), (SELECT id FROM stations WHERE code='BER'), 1, '2025-12-22 06:30:00+00', '2025-12-22 06:35:00+00', '2025-12-22 06:30:00+00', '2025-12-22 06:35:00+00', '4', 'departed'),
       ((SELECT id FROM trains WHERE code='S1'), (SELECT id FROM stations WHERE code='MD'), 2, '2025-12-22 08:15:00+00', '2025-12-22 08:20:00+00', NULL, NULL, NULL, 'scheduled');


COMMIT;

-- Example queries: -- 1) See the view: --

SELECT *
FROM journey_view
ORDER BY train_id,
         stop_sequence;

-- 2) Upcoming arrivals at a station: --

SELECT *
FROM journey_view
WHERE station_code = 'LEJ'
  AND scheduled_arrival >= now()
ORDER BY scheduled_arrival
LIMIT 10;

-- 3) All stops for a given train: --

SELECT *
FROM journey_view
WHERE train_code = 'ICE123'
ORDER BY stop_sequence;

-- End of script.
