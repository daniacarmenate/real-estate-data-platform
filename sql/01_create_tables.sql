CREATE TABLE brokers (
	broker_id BIGINT PRIMARY KEY
);

CREATE TABLE locations (
	location_id BIGSERIAL PRIMARY KEY,
	street BIGINT,
	city VARCHAR,
	state VARCHAR,
	zip_code VARCHAR,
	UNIQUE (street, city, state, zip_code)
);

CREATE TABLE status (
	status_id BIGSERIAL PRIMARY KEY,
	status VARCHAR NOT NULL UNIQUE CHECK (status IN ('sold', 'for_sale', 'ready_to_build'))
);

CREATE TABLE properties (
	property_id BIGSERIAL PRIMARY KEY,
	broker_id BIGINT,
	location_id BIGINT NOT NULL,
	status_id BIGINT NOT NULL,
	price NUMERIC(12,2) NOT NULL CHECK (price > 0),
	bedrooms INTEGER,
	bathrooms INTEGER,
	acre_lot NUMERIC(12,2),
	house_size INTEGER,
	prev_sold_date DATE,
	price_per_sqft NUMERIC(12,2),
	CONSTRAINT fk_property_broker FOREIGN KEY (broker_id) REFERENCES brokers(broker_id),
	CONSTRAINT fk_property_location FOREIGN KEY (location_id) REFERENCES locations(location_id),
	CONSTRAINT fk_property_status FOREIGN KEY (status_id) REFERENCES status(status_id)
);
	