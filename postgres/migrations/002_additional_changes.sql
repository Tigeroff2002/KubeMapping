\c logistic_db

BEGIN;

CREATE TYPE point_type AS ENUM ('start', 'end');

CREATE TABLE path_points(
    id bigint GENERATED ALWAYS AS IDENTITY,
    user_id bigint NOT NULL,
    point_type point_type NOT NULL,
    width double precision NOT NULL,
    height double precision NOT NULL,
    is_classified boolean NOT NULL,
    request_id bigint NOT NULL,
    CONSTRAINT pk_path_points PRIMARY KEY (id),
    CONSTRAINT fk_path_points_request_id FOREIGN KEY (request_id) REFERENCES requests (id) ON DELETE CASCADE);

CREATE TYPE day_of_week AS ENUM (
    'monday', 
    'tuesday', 
    'wednesday', 
    'thursday', 
    'friday', 
    'saturday', 
    'sunday');

CREATE TYPE area_type AS ENUM (
    'small', --area lesser than 30m
    'medium',  -- area on range [30, 100]m
    'complex'); -- area on range over 100m

CREATE TABLE favorite_points(
    id bigint GENERATED ALWAYS AS IDENTITY,
    user_id bigint NOT NULL,
    area_type area_type NOT NULL,
    width double precision NOT NULL,
    height double precision NOT NULL,
    started_history bigint[] NOT NULL DEFAULT '{}',
    end_history bigint[] NOT NULL DEFAULT '{}',
    CONSTRAINT pk_favorite_points PRIMARY KEY (id));

CREATE TABLE time_of_day_directory(
    id bigint GENERATED ALWAYS AS IDENTITY,
    start_range INTERVAL NOT NULL,
    end_range INTERVAL NOT NULL,
	CONSTRAINT pk_time_of_day_directory PRIMARY KEY (id));

INSERT INTO time_of_day_directory (start_range, end_range) VALUES ('1 hours'::interval, '6 hours'::interval);
INSERT INTO time_of_day_directory (start_range, end_range) VALUES ('6 hours'::interval, '9 hours'::interval);
INSERT INTO time_of_day_directory (start_range, end_range) VALUES ('9 hours'::interval, '12 hours'::interval);
INSERT INTO time_of_day_directory (start_range, end_range) VALUES ('12 hours'::interval, '14 hours'::interval);
INSERT INTO time_of_day_directory (start_range, end_range) VALUES ('14 hours'::interval, '16 hours 30 minutes'::interval);
INSERT INTO time_of_day_directory (start_range, end_range) VALUES ('16 hours 30 minutes'::interval, '19 hours'::interval);
INSERT INTO time_of_day_directory (start_range, end_range) VALUES ('19 hours'::interval, '22 hours'::interval);
INSERT INTO time_of_day_directory (start_range, end_range) VALUES ('22 hours'::interval, '1 hours'::interval);

CREATE TABLE finalized_requests(
    id bigint GENERATED ALWAYS AS IDENTITY,
    user_id bigint NOT NULL,
    request_id bigint NOT NULL,
    time_of_day_directory_id bigint NOT NULL,
    day_of_week day_of_week NOT NULL,
    start_point_id bigint NOT NULL,
    end_point_id bigint NOT NULL,
    expected_duration interval NOT NULL,
    actual_duration interval NOT NULL,
    CONSTRAINT pk_finalized_requests PRIMARY KEY (id),
    CONSTRAINT fk_finalized_requests_request_id FOREIGN KEY (request_id) REFERENCES requests (id) ON DELETE CASCADE,
    CONSTRAINT fk_finalized_requests_time_of_day_directory_id FOREIGN KEY (time_of_day_directory_id) REFERENCES time_of_day_directory (id));

CREATE TABLE request_commands_v2_outbox (
    id bigint GENERATED ALWAYS AS IDENTITY,
    data text NOT NULL,
    timestamp bigint NOT NULL,
    CONSTRAINT pk_request_commands_v2_outbox PRIMARY KEY (id));

COMMIT;