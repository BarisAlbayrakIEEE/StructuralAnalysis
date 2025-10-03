CREATE TABLE EO_Panel (
    EO_Panel_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(99) NOT NULL UNIQUE,
    thickness  FLOAT NOT NULL,
    width_a    FLOAT NOT NULL,
    width_b    FLOAT NOT NULL
);
CREATE TABLE SC_Stifener (
    SC_Stifener_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(99) NOT NULL UNIQUE,
    EO_Stiffener    INT NOT NULL,
    EO_Panel__side_1 INT NOT NULL,
    EO_Panel__side_2 INT NOT NULL
);
