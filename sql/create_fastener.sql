CREATE TABLE fasteners (
    fastener_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(99) NOT NULL UNIQUE,
    type ENUM('bolt','rivet','screw','other') NOT NULL,
    Ptu  FLOAT NOT NULL,   -- Tensile strength
    Psu  FLOAT NOT NULL    -- Shear strength
);
