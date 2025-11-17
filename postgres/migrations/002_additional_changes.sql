\c logistic_db

BEGIN;

CREATE TYPE point_type AS ENUM ('start', 'end');

CREATE TABLE path_points(
    id bigint GENERATED ALWAYS AS IDENTITY,
    user_id bigint NOT NULL,
    request_id bigint NOT NULL,
    width double precision NOT NULL,
    height double precision NOT NULL,
    CONSTRAINT pk_path_points PRIMARY KEY (id),
    CONSTRAINT fk_path_points_user_id
        FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_path_points_request_id
        FOREIGN KEY (request_id)
        REFERENCES requests (id) ON DELETE CASCADE);

CREATE TABLE requests_parts_path_points_entries(
    point_id bigint NOT NULL,
    request_part_id bigint NOT NULL,
    point_type point_type NOT NULL,
    CONSTRAINT pk_requests_parts_path_points_entries
        PRIMARY KEY (point_id, request_part_id, point_type),
    CONSTRAINT fk_requests_parts_path_points_entries_point_id
        FOREIGN KEY (point_id)
        REFERENCES path_points (id) ON DELETE CASCADE,
    CONSTRAINT fk_requests_parts_path_points_entries_request_part_id
        FOREIGN KEY (request_part_id)
        REFERENCES requests_parts (id) ON DELETE CASCADE);

CREATE TYPE day_of_week AS ENUM (
    'monday', 
    'tuesday', 
    'wednesday', 
    'thursday', 
    'friday', 
    'saturday', 
    'sunday');

CREATE TYPE month_of_year AS ENUM (
    'january',
    'february',
    'march',
    'april',
    'may',
    'june',
    'july',
    'august',
    'september',
    'october',
    'november',
    'december');

CREATE TYPE area_type AS ENUM (
    'small', --area lesser than 30m
    'medium',  -- area on range [30, 100]m
    'complex'); -- area on range over 100m

CREATE TABLE favorite_areas(
    id bigint GENERATED ALWAYS AS IDENTITY,
    user_id bigint NOT NULL,
    area_type area_type NOT NULL,
    width double precision NOT NULL,
    height double precision NOT NULL,
    CONSTRAINT pk_favorite_areas PRIMARY KEY (id),
    CONSTRAINT fk_favorite_areas_user_id
        FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE CASCADE);

CREATE TABLE favorite_areas_points_entries(
    point_id bigint NOT NULL,
    fav_area_id bigint NOT NULL,
    point_type point_type NOT NULL,
    CONSTRAINT pk_favorite_areas_points_entries 
        PRIMARY KEY (point_id, fav_area_id, point_type),
    CONSTRAINT fk_favorite_areas_points_entries_point_id
        FOREIGN KEY (point_id)
        REFERENCES path_points(id) ON DELETE CASCADE,
    CONSTRAINT fk_favorite_areas_points_entries_fav_area_id
        FOREIGN KEY (fav_area_id)
        REFERENCES favorite_areas(id) ON DELETE CASCADE);

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

CREATE TABLE cities_directory(
    id bigint GENERATED ALWAYS AS IDENTITY,
    name TEXT NOT NULL,
    center_width double precision NOT NULL,
    center_heigth double precision NOT NULL,
    radius double precision NOT NULL,
    CONSTRAINT pk_cities_directory PRIMARY KEY(id));

INSERT INTO cities_directory(name, center_width, center_heigth, radius) 
    VALUES ('Vladimir', 56.140986, 40.404883, 6850);

CREATE TABLE finalized_requests(
    id bigint GENERATED ALWAYS AS IDENTITY,
    user_id bigint NOT NULL,
    request_id bigint NOT NULL,
    total_length double precision NOT NULL,
    cities_directory_id bigint NOT NULL,
    month_of_year month_of_year NOT NULL,
    time_of_day_directory_id bigint NOT NULL,
    day_of_week day_of_week NOT NULL,
    start_point_id bigint NOT NULL,
    end_point_id bigint NOT NULL,
    expected_duration interval NOT NULL,
    actual_duration interval NOT NULL,
    CONSTRAINT pk_finalized_requests PRIMARY KEY (id),
    CONSTRAINT fk_finalized_requests_user_id
        FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_finalized_requests_request_id
        FOREIGN KEY (request_id) 
        REFERENCES requests (id) ON DELETE CASCADE,
    CONSTRAINT fk_finalized_requests_time_of_day_directory_id 
        FOREIGN KEY (time_of_day_directory_id)
        REFERENCES time_of_day_directory (id),
    CONSTRAINT fk_finalized_requests_cities_directory_id
        FOREIGN KEY (cities_directory_id)
        REFERENCES cities_directory (id));

CREATE TABLE request_commands_v2_outbox (
    id bigint GENERATED ALWAYS AS IDENTITY,
    data text NOT NULL,
    timestamp bigint NOT NULL,
    CONSTRAINT pk_request_commands_v2_outbox PRIMARY KEY (id));

CREATE TABLE users_history_directory (
    id bigint GENERATED ALWAYS AS IDENTITY,
    user_id bigint NOT NULL,
    cities_directory_id bigint NOT NULL,
    start_fav_area_id bigint NOT NULL,
    end_fav_area_id bigint NOT NULL,
    month_of_year month_of_year NOT NULL,
    time_of_day_directory_id bigint NOT NULL,
    day_of_week day_of_week NOT NULL,
    number_of_rides smallint NOT NULL,
    average_duration interval NOT NULL,
    CONSTRAINT pk_users_history_directory PRIMARY KEY (id),
    CONSTRAINT fk_users_history_directory
        FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_users_history_directory_cities_directory_id
        FOREIGN KEY (cities_directory_id)
        REFERENCES cities_directory (id),
    CONSTRAINT fk_users_history_directory_start_fav_area_id 
        FOREIGN KEY (start_fav_area_id) 
        REFERENCES favorite_areas (id) ON DELETE CASCADE,
    CONSTRAINT fk_users_history_directory_end_fav_area_id 
        FOREIGN KEY (end_fav_area_id) 
        REFERENCES favorite_areas (id) ON DELETE CASCADE,
    CONSTRAINT fk_users_history_directory_time_of_day_directory_id 
        FOREIGN KEY (time_of_day_directory_id)
        REFERENCES time_of_day_directory (id));

COMMIT;