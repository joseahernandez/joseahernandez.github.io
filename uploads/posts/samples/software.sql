-- phpMyAdmin SQL Dump
-- version 3.4.7
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tiempo de generación: 04-11-2011 a las 12:48:03
-- Versión del servidor: 5.5.8
-- Versión de PHP: 5.3.5

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de datos: `software`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `software`
--

CREATE TABLE IF NOT EXISTS `software` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `descripcion` varchar(500) COLLATE utf8_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci AUTO_INCREMENT=5 ;

--
-- Volcado de datos para la tabla `software`
--

INSERT INTO `software` (`id`, `nombre`, `descripcion`) VALUES
(1, 'Windows 7', 'Sistema operativo de Microsoft que salio al mercado en el año 2009'),
(2, 'Photoshop', 'Aplicación para el retoque fotográfico'),
(3, 'Ubuntu', 'Sistema operativo que utiliza el nucleo de Linux y está basado en Debian'),
(4, 'Google Chrome', 'Navegador web desarrollado por Google');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
