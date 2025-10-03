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
    EO_Stiffener_id     INT NOT NULL,
    EO_Panel_id__side_1 INT NOT NULL,
    EO_Panel_id__side_2 INT NOT NULL
    FOREIGN KEY (EO_Stiffener_id)     REFERENCES EO_Stiffener(EO_Stiffener_id),
    FOREIGN KEY (EO_Panel_id__side_1) REFERENCES EO_Panel(EO_Panel_id__side_1),
    FOREIGN KEY (EO_Panel_id__side_2) REFERENCES EO_Panel(EO_Panel_id__side_2),
);
