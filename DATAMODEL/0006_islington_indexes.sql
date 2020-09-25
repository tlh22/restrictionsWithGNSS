# Islington data loaded via Astun loader. This is to add indexes as required

CREATE INDEX idx_street_name
ON highways_network.street(name);