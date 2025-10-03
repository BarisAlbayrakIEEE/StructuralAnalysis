CREATE TABLE mat1 (
    mat1_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(99) NOT NULL UNIQUE,
    E   FLOAT NOT NULL,    -- Young’s modulus
    G   FLOAT NOT NULL,    -- Shear modulus
    nu  FLOAT NOT NULL     -- Poisson’s ratio
);
