CREATE TABLE RF__SC_Panel__Panel_Buckling__partitioned (
    SC_id INT NOT NULL,
    LC_id INT NOT NULL,
    app_Nxx FLOAT, -- applied loading - Nxx
    app_Nxy FLOAT, -- applied loading - Nxy
    app_Nyy FLOAT, -- applied loading - Nyy
    all_Nxx FLOAT, -- allowable loading - Nxx
    all_Nxy FLOAT, -- allowable loading - Nxy
    all_Nyy FLOAT, -- allowable loading - Nyy
    RF FLOAT,
    PRIMARY KEY (SC_id, LC_id)
);
PARTITION BY HASH(SC_id) PARTITIONS 1000;

CREATE TABLE RF__SC_Panel__Panel_Buckling__indexed (
    SC_id INT NOT NULL,
    LC_id INT NOT NULL,
    app_Nxx FLOAT, -- applied loading - Nxx
    app_Nxy FLOAT, -- applied loading - Nxy
    app_Nyy FLOAT, -- applied loading - Nyy
    all_Nxx FLOAT, -- allowable loading - Nxx
    all_Nxy FLOAT, -- allowable loading - Nxy
    all_Nyy FLOAT, -- allowable loading - Nyy
    RF FLOAT,
    PRIMARY KEY (SC_id, LC_id),
    FOREIGN KEY (SC_id) REFERENCES SC_Panel(SC_id),
    FOREIGN KEY (LC_id) REFERENCES SCL_Panel_Buckling(LC_id)
);



CREATE TABLE RF__SC_Panel__Panel_Pressure__partitioned (
    SC_id INT NOT NULL,
    LC_id INT NOT NULL,
    app_P FLOAT, -- applied pressure
    all_P FLOAT, -- allowable pressure
    RF FLOAT,
    PRIMARY KEY (SC_id, LC_id)
);
PARTITION BY HASH(SC_id) PARTITIONS 1000;

CREATE TABLE RF__SC_Panel__Panel_Pressure__indexed (
    SC_id INT NOT NULL,
    LC_id INT NOT NULL,
    app_P FLOAT, -- applied pressure
    all_P FLOAT, -- allowable pressure
    RF FLOAT,
    PRIMARY KEY (SC_id, LC_id),
    FOREIGN KEY (SC_id) REFERENCES SC_Panel(SC_id),
    FOREIGN KEY (LC_id) REFERENCES SCL_Panel_Buckling(LC_id)
);



CREATE TABLE RF__SC_Stiffener__Strength__partitioned (
    SC_id INT NOT NULL,
    LC_id INT NOT NULL,
    app_Fxx FLOAT,
    app_Myy FLOAT,
    app_Mzz FLOAT,
    all_Fxx FLOAT,
    all_Myy FLOAT,
    all_Mzz FLOAT,
    RF FLOAT,
    PRIMARY KEY (SC_id, LC_id)
);
PARTITION BY HASH(SC_id) PARTITIONS 1000;

CREATE TABLE RF__SC_Stiffener__Strength__indexed (
    SC_id INT NOT NULL,
    LC_id INT NOT NULL,
    app_Fxx FLOAT,
    app_Myy FLOAT,
    app_Mzz FLOAT,
    all_Fxx FLOAT,
    all_Myy FLOAT,
    all_Mzz FLOAT,
    RF FLOAT,
    PRIMARY KEY (SC_id, LC_id),
    FOREIGN KEY (SC_id) REFERENCES SC_Panel(SC_id),
    FOREIGN KEY (LC_id) REFERENCES SCL_Panel_Buckling(LC_id)
);
