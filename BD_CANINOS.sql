CREATE DATABASE IF NOT EXISTS exposicion_canina;
USE exposicion_canina;
-- Razas de los perros
CREATE TABLE Razas (
ID_Raza INT PRIMARY KEY AUTO_INCREMENT,
Nombre_Raza VARCHAR(50) UNIQUE NOT NULL,
Descripcion_Raza TEXT
);
INSERT INTO Razas (Nombre_Raza, Descripcion_Raza) VALUES
('Labrador', 'Perro amigable y leal, ideal para familias'),
('Bulldog', 'Perro con carácter relajado y afectuoso'),
('Golden Retriever', 'Perro inteligente y amigable con niños'),
('Beagle', 'Perro enérgico con gran sentido del olfato'),
('Pastor Alemán', 'Perro leal y protector, comúnmente usado como perro de trabajo');

-- Tabla de perros
CREATE TABLE Perros (
    ID_Perro INT PRIMARY KEY AUTO_INCREMENT,
    Nombre VARCHAR(50) UNIQUE NOT NULL,
    ID_Raza INT,
    Edad INT NOT NULL CHECK (Edad >= 0),
    Puntos INT NOT NULL CHECK (Puntos >= 0),
    Foto BLOB,
    FOREIGN KEY (ID_Raza) REFERENCES Razas(ID_Raza)
);

ALTER TABLE Perros
MODIFY Nombre VARCHAR(50) NOT NULL DEFAULT 'Desconocido';

-- Perros de la exposicion
INSERT INTO Perros (Nombre, ID_Raza, Edad, Puntos, Foto) VALUES
('Max', 1, 5, 85, NULL),           -- Labrador
('Bella', 2, 3, 90, NULL),         -- Bulldog
('Charlie', 3, 4, 95, NULL),       -- Golden Retriever
('Daisy', 4, 2, 70, NULL),         -- Beagle
('Rex', 5, 6, 60, NULL);           -- Pastor Alemán

-- Exposiciones que se realizan
CREATE TABLE Eventos (
    ID_Evento INT PRIMARY KEY AUTO_INCREMENT,
    Nombre_Evento VARCHAR(50) NOT NULL,
    Fecha DATE NOT NULL,
    Ubicacion VARCHAR(100),
    Descripcion_Evento TEXT
);

-- Inserción de exposiciones
INSERT INTO Eventos (Nombre_Evento, Fecha, Ubicacion, Descripcion_Evento) VALUES
('Exposición Canina Primavera', '2024-05-15', 'Parque Central', 'Desfile canino de primavera en el parque central'),
('Exposición Canina Otoño', '2024-10-20', 'Centro de Exposiciones', 'Desfile canino anual en el centro de exposiciones');

-- Tabla de calificacion de los perros
CREATE TABLE Participaciones (
    ID_Participacion INT PRIMARY KEY AUTO_INCREMENT,
    ID_Perro INT NOT NULL,
    ID_Evento INT NOT NULL,
    Puntos_Obtenidos INT NOT NULL,
    Clasificacion VARCHAR(20),
    FOREIGN KEY (ID_Perro) REFERENCES Perros(ID_Perro),
    FOREIGN KEY (ID_Evento) REFERENCES Eventos(ID_Evento)
);

-- Calificaciones
INSERT INTO Participaciones (ID_Perro, ID_Evento, Puntos_Obtenidos, Clasificacion) VALUES
(1, 1, 85, 'Primer Lugar'),
(2, 1, 80, 'Segundo Lugar'),
(3, 1, 75, 'Tercer Lugar'),
(4, 2, 90, 'Primer Lugar'),
(5, 2, 85, 'Segundo Lugar');

-- Nombres de los tres jueces
CREATE TABLE Jueces (
    ID_Juez INT PRIMARY KEY AUTO_INCREMENT,
    Nombre_Juez VARCHAR(50) NOT NULL,
    Experiencia INT CHECK (Experiencia >= 0),
    Especialidad VARCHAR(50)
);
-- Inserción de Jueces
INSERT INTO Jueces (Nombre_Juez, Experiencia, Especialidad) VALUES
('Carlos Ramirez', 10, 'Juez de raza'),
('Ana Lopez', 8, 'Juez de obediencia'),
('Jorge Santos', 12, 'Juez de presentación');

-- Tabla Evaluaciones
CREATE TABLE Evaluaciones (
    ID_Evaluacion INT PRIMARY KEY AUTO_INCREMENT,
    ID_Juez INT NOT NULL,
    ID_Participacion INT NOT NULL,
    Comentarios TEXT,
    Puntos_Otorgados INT NOT NULL CHECK (Puntos_Otorgados >= 0),
    FOREIGN KEY (ID_Juez) REFERENCES Jueces(ID_Juez),
    FOREIGN KEY (ID_Participacion) REFERENCES Participaciones(ID_Participacion)
);

-- Puntos de cada perro
INSERT INTO Evaluaciones (ID_Juez, ID_Participacion, Comentarios, Puntos_Otorgados) VALUES
(1, 1, 'Excelente presentación y comportamiento', 85),
(2, 1, 'Muy buena obediencia y control', 80),
(3, 1, 'Gran participación, pero un poco tímido', 75),
(1, 2, 'Muy buen desempeño en general', 90),
(2, 2, 'Gran presentación y estilo', 85);

CREATE INDEX idx_nombre_perro ON Perros(Nombre);
CREATE INDEX idx_id_raza_perro ON Perros(ID_Raza);
CREATE INDEX idx_fecha_evento ON Eventos(Fecha);
CREATE INDEX idx_id_perro_participacion ON Participaciones(ID_Perro);
CREATE INDEX idx_id_evento_participacion ON Participaciones(ID_Evento);

CREATE VIEW Vista_Perros_Eventos AS
SELECT
    p.ID_Perro,
    p.Nombre AS Nombre_Perro,
    r.Nombre_Raza AS Raza,
    p.Edad,
    p.Puntos AS Puntos_Iniciales,
    e.Nombre_Evento,
    e.Fecha,
    e.Ubicacion,
    pa.Puntos_Obtenidos,
    pa.Clasificacion
FROM
    Perros p
JOIN
    Razas r ON p.ID_Raza = r.ID_Raza
JOIN
    Participaciones pa ON p.ID_Perro = pa.ID_Perro
JOIN
    Eventos e ON pa.ID_Evento = e.ID_Evento;
-- Crear procedimientos almacenados

-- Procedimiento para listar todos los perros
DELIMITER //
CREATE PROCEDURE ListarPerros()
BEGIN
    SELECT p.ID_Perro, p.Nombre, r.Nombre_Raza AS Raza, p.Edad, p.Puntos, p.Foto
    FROM Perros p
    LEFT JOIN Razas r ON p.ID_Raza = r.ID_Raza
    ORDER BY r.Nombre_Raza, p.Puntos, p.Edad;
END //
DELIMITER ;

-- Procedimiento para mostrar información de un perro específico
DELIMITER //
CREATE PROCEDURE MostrarPerro(IN perroNombre VARCHAR(50))
BEGIN
    SELECT * FROM Perros WHERE Nombre = perroNombre;
END //
DELIMITER ;

-- Procedimiento para registrar un nuevo perro
DELIMITER //
CREATE PROCEDURE RegistrarPerro(IN nombre VARCHAR(50), IN id_raza INT, IN edad INT, IN puntos INT)
BEGIN
    INSERT INTO Perros (Nombre, ID_Raza, Edad, Puntos) VALUES
    (IFNULL(nombre, 'Desconocido'), id_raza, edad, puntos);
END //
DELIMITER ;

-- Procedimiento para buscar el perro ganador
DELIMITER //
CREATE PROCEDURE BuscarGanador()
BEGIN
    SELECT * FROM Perros ORDER BY Puntos DESC LIMIT 1;
END //
DELIMITER ;

-- Procedimiento para buscar el perro con el menor puntaje
DELIMITER //
CREATE PROCEDURE BuscarMenorPuntaje()
BEGIN
    SELECT * FROM Perros ORDER BY Puntos ASC LIMIT 1;
END //
DELIMITER ;

-- Procedimiento para buscar el perro más viejo
DELIMITER //
CREATE PROCEDURE BuscarMasViejo()
BEGIN
    SELECT * FROM Perros ORDER BY Edad DESC LIMIT 1;
END //
DELIMITER ;

-- Crear el menú principal
DELIMITER $$
CREATE PROCEDURE menu()
BEGIN
    DECLARE opcion INT DEFAULT -1;

    -- Menú principal
    SELECT '
        ====== MENÚ PRINCIPAL - EXPOSICIÓN CANINA ======
        1. Listar todos los perros registrados
        2. Mostrar información de un perro específico
        3. Registrar un nuevo perro
        4. Localizar un perro por su nombre
        5. Buscar el perro ganador de la exposición
        6. Buscar el perro con el menor puntaje
        7. Buscar el perro más viejo
        0. Salir' INTO @menu;

    -- Asignar la opción directamente para probar
    SET opcion = 1; -- Cambia este valor para probar otras opciones

    AppMenuLoop: LOOP
        CASE opcion
            WHEN 1 THEN
                -- Mostrar todos los perros
                CALL ListarPerros();
            WHEN 2 THEN
                -- Mostrar información de un perro específico
                SET @nombre_perro = 'Luna'; -- Cambia el valor para probar
                CALL MostrarPerro(@nombre_perro);
            WHEN 3 THEN
                -- Registrar un nuevo perro
                SET @nombre = 'Max';
                SET @id_raza = 2; -- Cambia el ID de raza según lo necesites
                SET @edad = 4;
                SET @puntos = 85;
                CALL RegistrarPerro(@nombre, @id_raza, @edad, @puntos);
            WHEN 4 THEN
                -- Localizar un perro por su nombre
                SET @nombre_perro = 'Rocky'; -- Cambia el valor para probar
                CALL MostrarPerro(@nombre_perro);
            WHEN 5 THEN
                -- Buscar el perro ganador de la exposición
                CALL BuscarGanador();
            WHEN 6 THEN
                -- Buscar el perro con el menor puntaje
                CALL BuscarMenorPuntaje();
            WHEN 7 THEN
                -- Buscar el perro más viejo
                CALL BuscarMasViejo();
            WHEN 0 THEN
                LEAVE AppMenuLoop;
            ELSE
                SELECT 'Opción no válida. Inténtelo de nuevo.';
        END CASE;
        SET opcion = 0; -- Reiniciar la opción para salir del bucle
    END LOOP AppMenuLoop;
END$$
DELIMITER ;

-- Ejecutar el menú
CALL menu();
