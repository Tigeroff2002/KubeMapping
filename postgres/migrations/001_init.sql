\c logistic_db

BEGIN;

CREATE TYPE role AS ENUM ('user', 'admin');
CREATE TYPE request_status AS ENUM ('created', 'calculated', 'accepted', 'followed', 'unfollowed', 'closed');
CREATE TYPE segment_type AS ENUM ('expected', 'overcomed');
--CREATE TYPE payment_status AS ENUM ('pending', 'waiting_for_capture', 'succeeded', 'canceled', 'authorized', 'partially_refunded', 'refunded', 'failed');

CREATE TABLE users (
    id bigint GENERATED ALWAYS AS IDENTITY,
    email text NOT NULL,
    role role NOT NULL,
    CONSTRAINT pk_users PRIMARY KEY (id));

-- builder domain
CREATE TABLE requests (
    id bigint GENERATED ALWAYS AS IDENTITY,
    guid text NOT NULL,
    user_id bigint NOT NULL,
    status request_status NOT NULL,
    start_width double precision NOT NULL,
    start_height double precision NOT NULL,
    creation_date timestamp with time zone NOT NULL,
    last_update timestamp with time zone NOT NULL,
    CONSTRAINT pk_requests PRIMARY KEY (id),
    CONSTRAINT fk_requests_users_user_id 
        FOREIGN KEY (user_id) 
        REFERENCES users (id) ON DELETE CASCADE);

CREATE TABLE requests_parts (
    id bigint GENERATED ALWAYS AS IDENTITY,
    request_id bigint NOT NULL,
    sequence_number smallint DEFAULT 1,
    start_width double precision NOT NULL,
    start_height double precision NOT NULL,
    end_width double precision NOT NULL,
    end_height double precision NOT NULL,
    total_length double precision NOT NULL,
    expected_duration interval NOT NULL,
    actual_duration interval DEFAULT NULL,
    last_update timestamp with time zone NOT NULL,
    CONSTRAINT pk_requests_parts PRIMARY KEY(id),
    CONSTRAINT fk_requests_parts_request_id 
        FOREIGN KEY (request_id)
        REFERENCES requests (id) ON DELETE CASCADE);

CREATE OR REPLACE FUNCTION update_last_update_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_update = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_last_update
AFTER UPDATE ON requests
FOR EACH ROW
EXECUTE FUNCTION update_last_update_column();

CREATE TABLE segments (
    id bigint GENERATED ALWAYS AS IDENTITY,
    request_part_id bigint NOT NULL,
    type segment_type NOT NULL,
    start_width double precision NOT NULL,
    start_height double precision NOT NULL,
    end_width double precision NOT NULL,
    end_height double precision NOT NULL,
    sequence_number integer NOT NULL,
    length double precision NOT NULL,
    CONSTRAINT pk_segments PRIMARY KEY (id),
    CONSTRAINT fk_segments_requests_parts_request_part_id 
        FOREIGN KEY (request_part_id) 
        REFERENCES requests_parts (id) ON DELETE CASCADE);

-- payment domain
CREATE TABLE payments (
    id bigint GENERATED ALWAYS AS IDENTITY,
    guid text NOT NULL,
    url text DEFAULT NULL,
    user_id bigint NOT NULL,
    status text NOT NULL,
    amount decimal NOT NULL,
    creation_date timestamp with time zone NOT NULL,
    last_update timestamp with time zone NOT NULL,
    CONSTRAINT pk_payments PRIMARY KEY (id),
    CONSTRAINT fk_payments_users_user_id 
        FOREIGN KEY (user_id) 
        REFERENCES users (id) ON DELETE CASCADE);

CREATE TABLE user_balances(
    user_id bigint NOT NULL PRIMARY KEY,
    balance NUMERIC NOT NULL DEFAULT 0,
    CONSTRAINT fk_users_balance_user_id 
        FOREIGN KEY (user_id) 
        REFERENCES users (id) ON DELETE CASCADE);

CREATE TABLE subscriptions (
    id bigint GENERATED ALWAYS AS IDENTITY,
    user_id bigint NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    CONSTRAINT pk_subscriptions PRIMARY KEY (id),
    CONSTRAINT fk_subscriptions_users_user_id 
        FOREIGN KEY (user_id) 
        REFERENCES users (id) ON DELETE CASCADE);

CREATE TABLE request_commands_outbox (
    id bigint GENERATED ALWAYS AS IDENTITY,
    data text NOT NULL,
    timestamp bigint NOT NULL,
    CONSTRAINT pk_request_commands_outbox PRIMARY KEY (id));

CREATE TABLE payment_commands_outbox (
    id bigint GENERATED ALWAYS AS IDENTITY,
    data text NOT NULL,
    timestamp bigint NOT NULL,
    CONSTRAINT pk_payment_commands_outbox PRIMARY KEY (id));

COMMIT;