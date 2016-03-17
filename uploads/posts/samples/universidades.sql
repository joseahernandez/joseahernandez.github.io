CREATE DATABASE `universidades`;
USE `universidades`;


CREATE TABLE IF NOT EXISTS `universidades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) COLLATE utf8_spanish_ci NOT NULL,
  `ciudad` varchar(255) COLLATE utf8_spanish_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=1 ;


INSERT INTO `universidades` (`nombre`, `ciudad`) VALUES
('A Coruña', 'A Coruña'),
('Alcalá', 'Madrid'),
('Alfonso X El Sabio', 'Madrid'),
('Alicante', 'Alicante'),
('Almería', 'Almeria'),
('Antonio de Nebrija', 'Madrid'),
('Autónoma de Barcelona', 'Barcelona'),
('Autónoma de Madrid', 'Madrid'),
('Barcelona', 'Barcelona'),
('Burgos', 'Burgos'),
('Cádiz', 'Cadiz'),
('Camilo José Cela', 'Madrid'),
('Cantabria', 'Santander'),
('Cardenal Herrera-CEU', 'Valencia'),
('Carlos III de Madrid', 'Madrid'),
('Castilla-La Mancha', 'Ciudad Real'),
('Católica de Valencia San Vicente Mártir', 'Valencia'),
('Católica San Antonio', 'Murcia'),
('Católica Santa Teresa de Jesús de Avila', 'Avila'),
('Complutense de Madrid', 'Madrid'),
('Córdoba', 'Córdoba'),
('Deusto', 'Bilbao'),
('Europea de Madrid', 'Madrid'),
('Europea Miguel de Cervantes', 'Valladolid'),
('Extremadura', 'Badajoz'),
('Francisco de Vitoria', 'Madrid'),
('Girona', 'Girona'),
('Granada', 'Granada'),
('Huelva', 'Huelva'),
('IE Universidad', 'Segovia'),
('Illes Balears', 'Palma'),
('Internacional de Andalucía', 'Sevilla'),
('Internacional de Catalunya', 'Barcelona'),
('Internacional Isabel I de Castilla', ''),
('Internacional Menéndez Pelayo', 'Madrid'),
('Internacional Valenciana', ''),
('Jaén', 'Jaén'),
('Jaume I de Castellón', 'Castellón'),
('La Laguna', 'Tenerife'),
('La Rioja', 'Logroño'),
('Las Palmas de Gran Canaria', 'Las Palmas'),
('León', 'León'),
('Lleida', 'Lleida'),
('Málaga', 'Málaga'),
('Miguel Hernández de Elche', 'Alicante'),
('Politécnica de Madrid', 'Madrid'),
('Politécnica de Valencia', 'Valencia'),
('Vigo', 'Vigo'),
('Zaragoza', 'Zaragoza');

