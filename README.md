-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               12.1.2-MariaDB - MariaDB Server
-- Server OS:                    Win64
-- HeidiSQL Version:             12.11.0.7065
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for drug_tracking_system
CREATE DATABASE IF NOT EXISTS `drug_tracking_system` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci */;
USE `drug_tracking_system`;

-- Dumping structure for table drug_tracking_system.audit_logs
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `action` enum('CREATE','UPDATE','DELETE','LOGIN','LOGOUT') NOT NULL,
  `table_name` varchar(100) NOT NULL,
  `record_id` int(11) DEFAULT NULL,
  `old_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_data`)),
  `new_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_data`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`log_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_table_record` (`table_name`,`record_id`),
  CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `mas_users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.audit_logs: ~0 rows (approximately)

-- Dumping structure for table drug_tracking_system.mas_drugs
CREATE TABLE IF NOT EXISTS `mas_drugs` (
  `drug_id` int(11) NOT NULL AUTO_INCREMENT,
  `manufacturer_id` int(11) NOT NULL,
  `drug_name` varchar(150) NOT NULL,
  `composition` text NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `is_narcotic` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `dosage_form` varchar(50) NOT NULL,
  `strength` varchar(50) NOT NULL,
  `master_drug_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`drug_id`),
  UNIQUE KEY `unique_drug` (`manufacturer_id`,`drug_name`,`strength`,`dosage_form`),
  KEY `idx_drug_name` (`drug_name`),
  CONSTRAINT `fk_manufacturer` FOREIGN KEY (`manufacturer_id`) REFERENCES `mas_manufacturers` (`manufacturer_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.mas_drugs: ~4 rows (approximately)
INSERT INTO `mas_drugs` (`drug_id`, `manufacturer_id`, `drug_name`, `composition`, `category`, `is_narcotic`, `created_at`, `dosage_form`, `strength`, `master_drug_id`) VALUES
	(1, 4, 'Morphine', 'Morphine', 'Opioid', 1, '2026-06-11 10:04:08', 'Injection', '10mg/ml', 13),
	(2, 4, 'Buprenorphine/Naloxone', 'Buprenorphine + Naloxone', 'Opioid', 1, '2026-06-11 10:05:13', 'Tablet', '2/0.5mg', 12),
	(3, 5, 'Morphine', 'Morphine', 'Opioid', 1, '2026-06-11 11:44:13', 'Injection', '10mg/ml', 13),
	(4, 5, 'Buprenorphine/Naloxone', 'Buprenorphine + Naloxone', 'Opioid', 1, '2026-06-11 11:45:48', 'Tablet', '2/0.5mg', 12),
	(5, 4, 'Alprazolam', 'Alprazolam', 'Benzodiazepine', 1, '2026-06-12 16:18:08', 'Tablet', '0.25mg', 23);

-- Dumping structure for table drug_tracking_system.mas_drugs_master
CREATE TABLE IF NOT EXISTS `mas_drugs_master` (
  `drug_id` int(11) NOT NULL AUTO_INCREMENT,
  `drug_name` varchar(150) NOT NULL,
  `composition` text NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `is_narcotic` tinyint(1) DEFAULT 0,
  `dosage_form` varchar(50) NOT NULL,
  `strength` varchar(100) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `item_brand_id` varchar(50) NOT NULL,
  `schedule_type` varchar(20) DEFAULT NULL,
  `abuse_risk` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`drug_id`),
  UNIQUE KEY `unique_item_brand` (`item_brand_id`),
  UNIQUE KEY `unique_master_drug` (`drug_name`,`strength`,`dosage_form`),
  KEY `idx_master_drug_name` (`drug_name`),
  KEY `idx_master_category` (`category`),
  KEY `idx_master_narcotic` (`is_narcotic`),
  KEY `fk_master_drug_user` (`created_by`),
  FULLTEXT KEY `ft_drug_search` (`drug_name`,`composition`),
  CONSTRAINT `fk_master_drug_user` FOREIGN KEY (`created_by`) REFERENCES `mas_users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.mas_drugs_master: ~18 rows (approximately)
INSERT INTO `mas_drugs_master` (`drug_id`, `drug_name`, `composition`, `category`, `is_narcotic`, `dosage_form`, `strength`, `status`, `created_by`, `created_at`, `updated_at`, `item_brand_id`, `schedule_type`, `abuse_risk`) VALUES
	(12, 'Buprenorphine/Naloxone', 'Buprenorphine + Naloxone', 'Opioid', 1, 'Tablet', '2/0.5mg', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10106646', NULL, 0),
	(13, 'Morphine', 'Morphine', 'Opioid', 1, 'Injection', '10mg/ml', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10100156', NULL, 0),
	(14, 'Diazepam', 'Diazepam', 'Benzodiazepine', 1, 'Injection', '5mg/ml', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10100082', NULL, 0),
	(15, 'Clonazepam', 'Clonazepam', 'Benzodiazepine', 1, 'Tablet', '0.5mg', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10100066', NULL, 0),
	(16, 'Ketamine Hydrochloride', 'Ketamine Hydrochloride', 'Anesthetic', 1, 'Injection', '50mg/ml', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10107136', NULL, 0),
	(17, 'Diazepam', 'Diazepam', 'Benzodiazepine', 1, 'Tablet', '5mg', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10100083', NULL, 0),
	(18, 'Pentazocine Lactate', 'Pentazocine Lactate', 'Opioid', 1, 'Injection', '30mg/ml', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10100184', NULL, 0),
	(19, 'Buprenorphine + Naloxone', 'Buprenorphine + Naloxone', 'Opioid', 1, 'Tablet', '0.4mg + 0.1mg', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10107257', NULL, 0),
	(20, 'Codeine Phosphate', 'Codeine Phosphate + CPM', 'Opioid', 1, 'Syrup', '10mg/5ml', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10100332', NULL, 0),
	(21, 'Clonazepam', 'Clonazepam', 'Benzodiazepine', 1, 'Tablet', '1mg', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10100067', NULL, 0),
	(22, 'Tramadol', 'Tramadol', 'Opioid', 1, 'Tablet', '50mg', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10100227', NULL, 0),
	(23, 'Alprazolam', 'Alprazolam', 'Benzodiazepine', 1, 'Tablet', '0.25mg', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10107585', NULL, 0),
	(24, 'Ketamine Hydrochloride', 'Ketamine Hydrochloride', 'Anesthetic', 1, 'Injection', '10mg/ml', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10100130', NULL, 0),
	(25, 'Tramadol', 'Tramadol', 'Opioid', 1, 'Injection', '50mg/ml', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10100226', NULL, 0),
	(26, 'Clonazepam', 'Clonazepam', 'Benzodiazepine', 1, 'Tablet', '2mg', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10106754', NULL, 0),
	(27, 'Nitrazepam', 'Nitrazepam', 'Benzodiazepine', 1, 'Tablet', '5mg', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10100166', NULL, 0),
	(28, 'Nitrazepam', 'Nitrazepam', 'Benzodiazepine', 1, 'Tablet', '10mg', 'active', NULL, '2026-05-23 04:10:01', '2026-05-23 04:10:01', '10100165', NULL, 0),
	(31, 'Paracetamol', 'Paracetamol', 'Analgesic', 0, 'Oral', '100mg', 'active', NULL, '2026-06-11 09:37:36', '2026-06-11 09:37:36', 'PCM100MG', NULL, 0);

-- Dumping structure for table drug_tracking_system.mas_inspectors
CREATE TABLE IF NOT EXISTS `mas_inspectors` (
  `inspector_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `department` varchar(100) DEFAULT 'Food and Drug Administration',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`inspector_id`),
  UNIQUE KEY `unique_user` (`user_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `fk_inspector_user` FOREIGN KEY (`user_id`) REFERENCES `mas_users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.mas_inspectors: ~4 rows (approximately)
INSERT INTO `mas_inspectors` (`inspector_id`, `user_id`, `department`, `created_at`) VALUES
	(1, 23, 'Food and Drug Administration', '2026-05-02 07:07:01'),
	(2, 32, 'Food and Drug Administration', '2026-06-02 15:03:06'),
	(3, 33, 'Food and Drug Administration', '2026-06-05 04:31:20'),
	(4, 34, 'Food and Drug Administration', '2026-06-07 10:24:33'),
	(5, 36, 'Food and Drug Administration', '2026-06-09 04:12:34'),
	(6, 43, 'Food and Drug Administration', '2026-06-11 04:32:50');

-- Dumping structure for table drug_tracking_system.mas_manufacturers
CREATE TABLE IF NOT EXISTS `mas_manufacturers` (
  `manufacturer_id` int(11) NOT NULL AUTO_INCREMENT,
  `company_name` varchar(150) NOT NULL,
  `gstin` varchar(50) NOT NULL,
  `drug_license_no` varchar(100) NOT NULL,
  `pan_no` varchar(50) DEFAULT NULL,
  `cin_no` varchar(50) DEFAULT NULL,
  `address` text NOT NULL,
  `created_by` int(11) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `website` varchar(150) DEFAULT NULL,
  `product_info` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`manufacturer_id`),
  UNIQUE KEY `unique_gstin` (`gstin`),
  KEY `fk_manufacturer_created_by` (`created_by`),
  CONSTRAINT `fk_manufacturer_created_by` FOREIGN KEY (`created_by`) REFERENCES `mas_users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.mas_manufacturers: ~0 rows (approximately)
INSERT INTO `mas_manufacturers` (`manufacturer_id`, `company_name`, `gstin`, `drug_license_no`, `pan_no`, `cin_no`, `address`, `created_by`, `phone`, `email`, `website`, `product_info`, `created_at`) VALUES
	(4, 'Sunlife Pharma Pvt Ltd', '22ABCDE1234F1X6', 'DL-CG-2024-56789', 'ABCDE1234F', 'U24230CG2020PTC012345', 'Plot No. 45, Industrial Area Phase 2,\nUrla, Raipur, Chhattisgarh - 493221', 21, '9876543210', 'info@sunlifepharma.com', 'www.sunlifepharma.com', 'Paracetamol Tablets, Amoxicillin Capsules, Cough Syrup', '2026-04-30 08:38:30'),
	(5, 'Aditya Pharma company MP', '22ABCDE1234A1Z7', 'MP-BHOPAL-WH-2024-0004', 'ABCDE1234A', 'U24230CG2020PTC012341', 'BHOPAL ROAD CIVIL LINE', 45, '9165645204', 'aaditya@gmail.com', 'adityapharma.com', 'it makes all type of product. for medicals', '2026-06-11 04:57:14');

-- Dumping structure for table drug_tracking_system.mas_retailers
CREATE TABLE IF NOT EXISTS `mas_retailers` (
  `retailer_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `shop_name` varchar(150) NOT NULL,
  `gstin` varchar(50) DEFAULT NULL,
  `drug_license_no` varchar(100) NOT NULL,
  `address` text NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`retailer_id`),
  UNIQUE KEY `unique_user` (`user_id`),
  UNIQUE KEY `unique_gstin` (`gstin`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `fk_retailer_user` FOREIGN KEY (`user_id`) REFERENCES `mas_users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.mas_retailers: ~4 rows (approximately)
INSERT INTO `mas_retailers` (`retailer_id`, `user_id`, `shop_name`, `gstin`, `drug_license_no`, `address`, `phone`, `email`, `created_at`) VALUES
	(1, 22, 'Meghshankar medical shop raipur', '22ABCDE1234F1Y6', 'CG/DRUG/2023/12346', 'Shop No. 13, Medical Complex, Raipur, Chhattisgarh', '9754313582', 'megh@gmail.com', '2026-04-30 07:13:03'),
	(2, 31, 'Subhash Medical Store', '22ABCDE1234F1S1', 'CG/DRUG/2023/12302', 'Doma raipur', '9754313502', 'subhash@gmail.com', '2026-06-02 15:01:26'),
	(3, 41, 'Magan Medical shop', '22ABCDE1234F1Z9', 'CG-RAIPUR-WH-2026-004', 'Near Bus Stand, Shankar Nagar,\nRaipur, Chhattisgarh - 492001', '8435772664', 'magan@gmail.com', '2026-06-10 10:31:25'),
	(4, 44, 'Chandraprakash medical store raipur', '22ABCDE1234F1Z1', 'CG-RAIPUR-WH-2026-0001', 'bharat mata chauk,raipur', '9165645202', 'chandu@gmail.com', '2026-06-11 04:40:03');

-- Dumping structure for table drug_tracking_system.mas_roles
CREATE TABLE IF NOT EXISTS `mas_roles` (
  `role_id` int(11) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.mas_roles: ~4 rows (approximately)
INSERT INTO `mas_roles` (`role_id`, `role_name`) VALUES
	(1, 'admin'),
	(3, 'wholesaler'),
	(4, 'retailer'),
	(5, 'inspector');

-- Dumping structure for table drug_tracking_system.mas_users
CREATE TABLE IF NOT EXISTS `mas_users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `mobile` varchar(15) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role_id` int(11) NOT NULL,
  `status` enum('active','inactive','blocked') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `last_login` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `unique_mobile` (`mobile`),
  KEY `idx_users_role` (`role_id`),
  KEY `idx_users_status` (`status`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `mas_roles` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.mas_users: ~23 rows (approximately)
INSERT INTO `mas_users` (`user_id`, `name`, `email`, `mobile`, `password`, `role_id`, `status`, `created_at`, `last_login`) VALUES
	(2, 'Admin', 'admin@gmail.com', '9754313585', '$2b$10$WA9Z1mwQLaDLOHL8iIaAVerbYBFp7iT3yW0eF50H.M7wn0O7Nyzxq', 1, 'active', '2026-04-21 07:18:46', '2026-06-14 19:07:57'),
	(21, 'Tikeshwar sahu', 'tikesh@gmail.com', '7945489681', '$2b$10$CJuploxlfQ4FrG3boMLCge2H8eS.2IMXZbSy6z/wcqBjlIhY74X4q', 3, 'active', '2026-04-30 05:35:02', '2026-06-14 12:38:59'),
	(22, 'Meghshankar sahu', 'megh@gmail.com', '9754313582', '$2b$10$R1vL8bDhvl34Tk9Vpq9.x.vsgcuI3zk5LrB7MJUpUVvCQ.fmRm8Lu', 4, 'active', '2026-04-30 07:01:36', '2026-06-13 05:43:15'),
	(23, 'jay', 'jay@gmail.com', '9865321478', '$2b$10$FgWLYMU.XI9/VT4McFjtqu8IP5pzsvMoBYFzbZAkClBajp4I24ZCa', 5, 'active', '2026-05-02 07:07:01', '2026-06-13 05:44:54'),
	(27, 'sattu', 'sattu@gmail.com', '9857425874', '$2b$10$GlqKBxb//g8wxkQpjpTqmOs9R4p.40Ob5oyWHI/wPJi2wVV9PX7pC', 3, 'active', '2026-05-17 07:34:17', '2026-06-10 08:55:25'),
	(28, 'kundan khutiyare', 'kundan@gmail.com', '8435772660', '$2b$10$oJ1Uzz5XHSNvyYRq5wrIG.JLJKfbg3CU/QF8qJN6c0VdwI2gaDV.G', 4, 'active', '2026-05-26 11:11:16', '2026-06-10 08:34:25'),
	(29, 'namrata verma', 'namu@gmail.com', '6265354274', '$2b$10$wjPwqbFUUEltQzlGa1pEVudLAY08UasnY3SZHExlEAJeFrAOIznGy', 4, 'active', '2026-05-26 11:22:43', '2026-05-29 14:50:52'),
	(30, 'Mehul Sinha', 'mehul@gmail.com', '9754313501', '$2b$10$yAmhA1/yRvE2ibgchmmz6e/KKyt6Z5vNnVl8gMNa7h2vkmb2NCCq6', 3, 'active', '2026-06-02 14:48:28', '2026-06-08 15:43:43'),
	(31, 'Subhash sahu', 'subhash@gmail.com', '9754313502', '$2b$10$ctruwpT7AoJDdZOhsO3EFeQC8iV1zJdC7Lh6jjFSOZttRG5Xn2tES', 4, 'active', '2026-06-02 14:54:49', '2026-06-05 17:54:11'),
	(32, 'Komal Sing Sahu', 'komal@gmail.com', '9754313503', '$2b$10$Xg8XOvLx9EwTwM8UUpHB8.k6P8ckC3A9HFzRagwkTYmnRyYnwqqIC', 5, 'active', '2026-06-02 15:03:06', '2026-06-08 14:45:25'),
	(33, 'Janak Sahu', 'janak@gmail.com', '9754313500', '$2b$10$PisXM4Pdjp4R2xFUe17ys.HgexcaC0jt9LTz8MVLExWurOw95cnJy', 5, 'active', '2026-06-05 04:31:20', NULL),
	(34, 'Aditya kumar', 'aadiv@gmail.com', '9754013585', '$2b$10$Gl.rrnZv0lSU0VZpUvH9me44nUVEfRUn6G2dBK29/iKA7ShUz54.O', 5, 'active', '2026-06-07 10:24:33', NULL),
	(35, 'kumar aditya', 'kumar@gmail.com', '9754313544', '$2b$10$iCJzui0UhvoCf9aYFrdLbOKN3BEAZyo.J9KVTFvHIIDK3AFNelhca', 4, 'active', '2026-06-08 09:18:20', '2026-06-08 09:19:13'),
	(36, 'pokemon', 'pokemon@gmail.com', '9754313575', '$2b$10$IOWx8gWxFYo1/wOhPQnKC.isSBWjzKNyjQznvyNtzoBZcn2MZOo76', 5, 'active', '2026-06-09 04:12:34', NULL),
	(37, 'Avinash banjare', 'avinash@gmail.com', '9751313585', '$2b$10$nkUIL0bDhIwAa.UU1h2ZTOIjCTwHlBXzrQ5mIrD.7UvC2qKWW1kwK', 3, 'active', '2026-06-10 09:27:08', '2026-06-10 10:07:19'),
	(38, 'Ashish banjare', 'ashish@gmail.com', '9752313585', '$2b$10$QONHBDo7YNjhNsXNfoiNF.zpBiNQRfU3b1C.S9B486if1CRkhYgDy', 4, 'active', '2026-06-10 09:28:48', NULL),
	(39, 'pranjal Singh rajput', 'pranjal3452@gmail.com', '9875431632', '$2b$10$QkNmpsxLDMUaoxhvFJRj9uhf667DNzyUyHU2rKsyxDEpNNIvphobm', 4, 'active', '2026-06-10 09:46:58', NULL),
	(40, 'jagan', 'jagan@gmail.com', '8435772661', '$2b$10$S1EIU6eFwTEb3u7ikRyjN.WDiuCHZRSe9QqvvfW09VAQKqqcksq5G', 3, 'active', '2026-06-10 09:53:44', NULL),
	(41, 'magan', 'magan@gmail.com', '8435772664', '$2b$10$KCxnZMKTQ4J87FMSPjl9M.ZqNq6p8dvqcjc2PukOhVuxoOmNoI7KK', 4, 'active', '2026-06-10 09:57:58', '2026-06-12 18:20:51'),
	(42, 'lagan', 'lagan@gmail.com', '8435222669', '$2b$10$3WYii61b/MhvT9a/Vm6fV.EHqZTBccPNhv.mJWEqN726nXfoR1COq', 3, 'active', '2026-06-10 10:05:10', '2026-06-10 10:12:04'),
	(43, 'Vaibhav Singh Chouhan', 'vaibhav@gmail.com', '9165645201', '$2b$10$cms0kDzg8LKyROm/VTdDdeWGSOksxMTRSY4wZ23kGkf38XmUookMu', 5, 'active', '2026-06-11 04:32:50', '2026-06-11 12:03:27'),
	(44, 'Chandraprakash sinha', 'chandu@gmail.com', '9165645202', '$2b$10$JD506cihF7Lgzol3F9IxYufEK0uuFJyrtu4ZvwFXyW78bdBWXG9ty', 4, 'active', '2026-06-11 04:34:48', '2026-06-12 16:31:18'),
	(45, 'Shekhar Sahu', 'sekhar@gmail.com', '9165645203', '$2b$10$Jxmm4jn8jLiHT2P2LTafAu1XQPCJjxTwsu.vWAYETZanw0El6TFWu', 3, 'active', '2026-06-11 04:50:39', '2026-06-13 03:18:44');

-- Dumping structure for table drug_tracking_system.mas_wholesalers
CREATE TABLE IF NOT EXISTS `mas_wholesalers` (
  `wholesaler_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `company_name` varchar(150) NOT NULL,
  `gstin` varchar(50) NOT NULL,
  `drug_license_no` varchar(100) NOT NULL,
  `address` text NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`wholesaler_id`),
  UNIQUE KEY `unique_user` (`user_id`),
  UNIQUE KEY `unique_gstin` (`gstin`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `fk_wholesaler_user` FOREIGN KEY (`user_id`) REFERENCES `mas_users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.mas_wholesalers: ~5 rows (approximately)
INSERT INTO `mas_wholesalers` (`wholesaler_id`, `user_id`, `company_name`, `gstin`, `drug_license_no`, `address`, `phone`, `email`, `created_at`) VALUES
	(1, 21, 'Tikeshwar Parma Medical shop', '22ABCDE1234F1Z5', 'CG/DRUG/2023/12345', 'Shop No. 12, Medical Complex, Raipur, Chhattisgarh', '7945489681', 'tikesh@gmail.com', '2026-04-30 06:51:22'),
	(2, 30, 'Mehul Pharma WareHouse Dhamtari', '22ABCDE1234F1M1', 'CG/DRUG/2023/12301', 'Dhamtari main road', '9754313501', 'mehul@gmail.com', '2026-06-02 14:51:02'),
	(4, 37, 'Avinash Pharma Distributors', '22ABCDE1234A1Z5', 'CG-RAIPUR-WH-2026-001', 'Near Bus Stand, Shankar Nagar,\nRaipur, Chhattisgarh - 492001', '9751313585', 'avinash@gmail.com', '2026-06-10 10:09:45'),
	(5, 42, 'Lagan Pharma Distributors', '22ABCDE1234L1Z5', 'CG-RAIPUR-WH-2026-002', 'Near Bus Stand, Shankar Nagar,\nRaipur, Chhattisgarh - 492001', '8435222669', 'lagan@gmail.com', '2026-06-10 10:13:08'),
	(6, 45, 'Shekhar Pharma supply durg', '22ABCDE1234S1Z9', 'CG-RAIPUR-WH-2026-0002', 'gadhi chauk durg,bhamtri road', '9165645203', 'sekhar@gmail.com', '2026-06-11 04:54:00');

-- Dumping structure for table drug_tracking_system.notifications
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `type` enum('invoice','stock','inspection','system') DEFAULT 'system',
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `fk_notification_user` FOREIGN KEY (`user_id`) REFERENCES `mas_users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.notifications: ~0 rows (approximately)

-- Dumping structure for table drug_tracking_system.trx_batches
CREATE TABLE IF NOT EXISTS `trx_batches` (
  `batch_id` int(11) NOT NULL AUTO_INCREMENT,
  `drug_id` int(11) NOT NULL,
  `batch_no` varchar(100) NOT NULL,
  `manufacture_date` date NOT NULL,
  `expiry_date` date NOT NULL,
  `stock_receive_date` date NOT NULL DEFAULT curdate(),
  `mrp` decimal(10,2) NOT NULL,
  `purchase_price` decimal(10,2) NOT NULL,
  `status` enum('active','expired','blocked') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `created_by` int(11) NOT NULL,
  PRIMARY KEY (`batch_id`),
  UNIQUE KEY `unique_batch` (`drug_id`,`batch_no`),
  KEY `idx_drug_id` (`drug_id`),
  KEY `idx_batch_no` (`batch_no`),
  CONSTRAINT `fk_batch_drug` FOREIGN KEY (`drug_id`) REFERENCES `mas_drugs` (`drug_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_dates` CHECK (`expiry_date` > `manufacture_date`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.trx_batches: ~4 rows (approximately)
INSERT INTO `trx_batches` (`batch_id`, `drug_id`, `batch_no`, `manufacture_date`, `expiry_date`, `stock_receive_date`, `mrp`, `purchase_price`, `status`, `created_at`, `created_by`) VALUES
	(1, 1, 'MORPH10', '2026-06-09', '2027-06-23', '2026-06-11', 50.00, 20.00, 'active', '2026-06-11 10:04:08', 21),
	(2, 2, 'BUPER2', '2026-06-07', '2028-06-11', '2026-06-11', 60.00, 23.00, 'active', '2026-06-11 10:05:13', 21),
	(3, 3, 'MORPH10', '2026-06-01', '2028-06-11', '2026-06-11', 50.00, 30.00, 'active', '2026-06-11 11:44:13', 45),
	(4, 4, 'buper21', '2026-06-11', '2027-06-11', '2026-06-11', 67.00, 34.00, 'active', '2026-06-11 11:45:48', 45),
	(5, 5, 'Alprazolam0.25', '2026-06-07', '2028-06-12', '2026-06-12', 100.00, 50.00, 'active', '2026-06-12 16:18:08', 21);

-- Dumping structure for table drug_tracking_system.trx_documents
CREATE TABLE IF NOT EXISTS `trx_documents` (
  `doc_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `doc_type` enum('gst','drug_license','pan','other') NOT NULL,
  `file_url` text NOT NULL,
  `status` enum('pending','verified','rejected') DEFAULT 'pending',
  `uploaded_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`doc_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `fk_document_user` FOREIGN KEY (`user_id`) REFERENCES `mas_users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.trx_documents: ~0 rows (approximately)

-- Dumping structure for table drug_tracking_system.trx_inspections
CREATE TABLE IF NOT EXISTS `trx_inspections` (
  `inspection_id` int(11) NOT NULL AUTO_INCREMENT,
  `inspector_id` int(11) NOT NULL,
  `target_user_id` int(11) NOT NULL,
  `inspection_type` enum('retailer','wholesaler') NOT NULL,
  `inspection_date` datetime NOT NULL DEFAULT current_timestamp(),
  `completed_at` datetime DEFAULT NULL,
  `status` enum('draft','in_progress','completed','verified','discrepancy','rejected') DEFAULT 'draft',
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `total_system_qty` int(11) DEFAULT 0,
  `total_physical_qty` int(11) DEFAULT 0,
  `inspection_mode` enum('total','batch') DEFAULT 'total',
  PRIMARY KEY (`inspection_id`),
  KEY `idx_inspector` (`inspector_id`),
  KEY `idx_target` (`target_user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_date` (`inspection_date`),
  CONSTRAINT `fk_inspection_inspector` FOREIGN KEY (`inspector_id`) REFERENCES `mas_users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_inspection_target` FOREIGN KEY (`target_user_id`) REFERENCES `mas_users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_inspection_user` CHECK (`inspector_id` <> `target_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.trx_inspections: ~5 rows (approximately)
INSERT INTO `trx_inspections` (`inspection_id`, `inspector_id`, `target_user_id`, `inspection_type`, `inspection_date`, `completed_at`, `status`, `remarks`, `created_at`, `updated_at`, `total_system_qty`, `total_physical_qty`, `inspection_mode`) VALUES
	(1, 23, 21, 'wholesaler', '2026-06-11 15:42:18', '2026-06-11 15:42:18', 'verified', 'very doog ,you well manage your stocks', '2026-06-11 10:12:18', '2026-06-11 10:12:18', 220, 220, 'total'),
	(2, 23, 22, 'retailer', '2026-06-11 15:42:44', '2026-06-11 15:42:44', 'verified', 'very well!!', '2026-06-11 10:12:44', '2026-06-11 10:12:44', 77, 77, 'total'),
	(3, 43, 44, 'retailer', '2026-06-11 17:35:40', '2026-06-11 17:35:40', 'discrepancy', 'mis-manage product', '2026-06-11 12:05:40', '2026-06-11 12:05:40', 10, 8, 'total'),
	(4, 43, 45, 'wholesaler', '2026-06-11 17:36:03', '2026-06-11 17:36:03', 'verified', 'good', '2026-06-11 12:06:03', '2026-06-11 12:06:03', 113, 113, 'total'),
	(5, 23, 44, 'retailer', '2026-06-12 22:04:42', '2026-06-12 22:04:42', 'verified', 'Good 👍', '2026-06-12 16:34:42', '2026-06-12 16:34:42', 19, 19, 'total');

-- Dumping structure for table drug_tracking_system.trx_inspection_checks
CREATE TABLE IF NOT EXISTS `trx_inspection_checks` (
  `check_id` int(11) NOT NULL AUTO_INCREMENT,
  `inspection_id` int(11) NOT NULL,
  `check_name` varchar(100) NOT NULL,
  `check_value` enum('yes','no','pass','fail') DEFAULT 'yes',
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`check_id`),
  KEY `idx_inspection` (`inspection_id`),
  CONSTRAINT `fk_check_inspection` FOREIGN KEY (`inspection_id`) REFERENCES `trx_inspections` (`inspection_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.trx_inspection_checks: ~20 rows (approximately)
INSERT INTO `trx_inspection_checks` (`check_id`, `inspection_id`, `check_name`, `check_value`, `remarks`, `created_at`) VALUES
	(1, 1, 'License Valid', 'yes', NULL, '2026-06-11 10:12:18'),
	(2, 1, 'Document Verified', 'yes', NULL, '2026-06-11 10:12:18'),
	(3, 1, 'Storage Condition OK', 'yes', NULL, '2026-06-11 10:12:18'),
	(4, 1, 'Stock Verified', 'yes', NULL, '2026-06-11 10:12:18'),
	(5, 2, 'License Valid', 'yes', NULL, '2026-06-11 10:12:44'),
	(6, 2, 'Document Verified', 'yes', NULL, '2026-06-11 10:12:44'),
	(7, 2, 'Storage Condition OK', 'yes', NULL, '2026-06-11 10:12:44'),
	(8, 2, 'Stock Verified', 'yes', NULL, '2026-06-11 10:12:44'),
	(9, 3, 'License Valid', 'yes', NULL, '2026-06-11 12:05:40'),
	(10, 3, 'Document Verified', 'yes', NULL, '2026-06-11 12:05:40'),
	(11, 3, 'Storage Condition OK', 'yes', NULL, '2026-06-11 12:05:40'),
	(12, 3, 'Stock Verified', 'yes', NULL, '2026-06-11 12:05:40'),
	(13, 4, 'License Valid', 'yes', NULL, '2026-06-11 12:06:03'),
	(14, 4, 'Document Verified', 'yes', NULL, '2026-06-11 12:06:03'),
	(15, 4, 'Storage Condition OK', 'yes', NULL, '2026-06-11 12:06:03'),
	(16, 4, 'Stock Verified', 'yes', NULL, '2026-06-11 12:06:03'),
	(17, 5, 'License Valid', 'yes', NULL, '2026-06-12 16:34:42'),
	(18, 5, 'Document Verified', 'yes', NULL, '2026-06-12 16:34:42'),
	(19, 5, 'Storage Condition OK', 'yes', NULL, '2026-06-12 16:34:42'),
	(20, 5, 'Stock Verified', 'yes', NULL, '2026-06-12 16:34:42');

-- Dumping structure for table drug_tracking_system.trx_inspection_items
CREATE TABLE IF NOT EXISTS `trx_inspection_items` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `inspection_id` int(11) NOT NULL,
  `drug_id` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL,
  `system_qty` int(11) NOT NULL,
  `physical_qty` int(11) NOT NULL DEFAULT 0,
  `difference_qty` int(11) GENERATED ALWAYS AS (`physical_qty` - `system_qty`) STORED,
  `status` enum('match','mismatch') GENERATED ALWAYS AS (case when `physical_qty` = `system_qty` then 'match' else 'mismatch' end) STORED,
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`item_id`),
  UNIQUE KEY `unique_inspection_batch` (`inspection_id`,`batch_id`),
  KEY `idx_inspection` (`inspection_id`),
  KEY `idx_drug` (`drug_id`),
  KEY `idx_batch` (`batch_id`),
  KEY `idx_inspection_status` (`inspection_id`,`status`),
  CONSTRAINT `fk_inspection_item_batch` FOREIGN KEY (`batch_id`) REFERENCES `trx_batches` (`batch_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_inspection_item_drug` FOREIGN KEY (`drug_id`) REFERENCES `mas_drugs` (`drug_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_inspection_item_inspection` FOREIGN KEY (`inspection_id`) REFERENCES `trx_inspections` (`inspection_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_physical_qty` CHECK (`physical_qty` >= 0),
  CONSTRAINT `chk_system_qty` CHECK (`system_qty` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.trx_inspection_items: ~11 rows (approximately)
INSERT INTO `trx_inspection_items` (`item_id`, `inspection_id`, `drug_id`, `batch_id`, `system_qty`, `physical_qty`, `remarks`, `created_at`) VALUES
	(1, 1, 1, 1, 70, 70, NULL, '2026-06-11 10:12:18'),
	(2, 1, 2, 2, 150, 150, NULL, '2026-06-11 10:12:18'),
	(3, 2, 1, 1, 29, 29, NULL, '2026-06-11 10:12:44'),
	(4, 2, 2, 2, 48, 48, NULL, '2026-06-11 10:12:44'),
	(5, 3, 3, 3, 6, 6, NULL, '2026-06-11 12:05:40'),
	(6, 3, 4, 4, 4, 2, NULL, '2026-06-11 12:05:40'),
	(7, 4, 3, 3, 73, 73, NULL, '2026-06-11 12:06:03'),
	(8, 4, 4, 4, 40, 40, NULL, '2026-06-11 12:06:03'),
	(9, 5, 3, 3, 6, 6, NULL, '2026-06-12 16:34:42'),
	(10, 5, 4, 4, 4, 4, NULL, '2026-06-12 16:34:42'),
	(11, 5, 5, 5, 9, 9, NULL, '2026-06-12 16:34:42');

-- Dumping structure for table drug_tracking_system.trx_invoices
CREATE TABLE IF NOT EXISTS `trx_invoices` (
  `invoice_id` int(11) NOT NULL AUTO_INCREMENT,
  `invoice_number` varchar(100) NOT NULL,
  `invoice_date` timestamp NOT NULL,
  `total_amount` decimal(10,2) DEFAULT 0.00,
  `status` enum('pending','accepted','rejected','paid') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  PRIMARY KEY (`invoice_id`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  KEY `idx_sender` (`sender_id`),
  KEY `idx_receiver` (`receiver_id`),
  CONSTRAINT `fk_invoice_receiver` FOREIGN KEY (`receiver_id`) REFERENCES `mas_users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_invoice_sender` FOREIGN KEY (`sender_id`) REFERENCES `mas_users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_sender_receiver` CHECK (`sender_id` <> `receiver_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.trx_invoices: ~3 rows (approximately)
INSERT INTO `trx_invoices` (`invoice_id`, `invoice_number`, `invoice_date`, `total_amount`, `status`, `created_at`, `sender_id`, `receiver_id`) VALUES
	(1, 'INV-1781172371458', '2026-06-11 10:06:11', 3050.00, 'accepted', '2026-06-11 10:06:11', 21, 22),
	(2, 'INV-1781178407476', '2026-06-11 11:46:47', 200.00, 'rejected', '2026-06-11 11:46:47', 45, 44),
	(3, 'INV-1781178447011', '2026-06-11 11:47:27', 505.00, 'accepted', '2026-06-11 11:47:27', 45, 44),
	(4, 'INV-1781281831793', '2026-06-12 16:30:31', 600.00, 'accepted', '2026-06-12 16:30:31', 21, 44);

-- Dumping structure for table drug_tracking_system.trx_invoice_items
CREATE TABLE IF NOT EXISTS `trx_invoice_items` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `invoice_id` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`item_id`),
  UNIQUE KEY `unique_invoice_batch` (`invoice_id`,`batch_id`),
  KEY `idx_invoice` (`invoice_id`),
  KEY `idx_batch` (`batch_id`),
  CONSTRAINT `fk_invoice_item_batch` FOREIGN KEY (`batch_id`) REFERENCES `trx_batches` (`batch_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_invoice_item_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `trx_invoices` (`invoice_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_quantity` CHECK (`quantity` > 0),
  CONSTRAINT `chk_price` CHECK (`price` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.trx_invoice_items: ~5 rows (approximately)
INSERT INTO `trx_invoice_items` (`item_id`, `invoice_id`, `batch_id`, `quantity`, `price`, `created_at`) VALUES
	(1, 1, 1, 30, 35.00, '2026-06-11 10:06:11'),
	(2, 1, 2, 50, 40.00, '2026-06-11 10:06:11'),
	(3, 2, 3, 5, 40.00, '2026-06-11 11:46:47'),
	(4, 3, 4, 5, 45.00, '2026-06-11 11:47:27'),
	(5, 3, 3, 7, 40.00, '2026-06-11 11:47:27'),
	(6, 4, 5, 10, 60.00, '2026-06-12 16:30:31');

-- Dumping structure for table drug_tracking_system.trx_sales
CREATE TABLE IF NOT EXISTS `trx_sales` (
  `sale_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `total_amount` decimal(12,2) GENERATED ALWAYS AS (`quantity` * `price`) STORED,
  `patient_name` varchar(100) NOT NULL,
  `patient_mobile` varchar(15) DEFAULT NULL,
  `doctor_name` varchar(100) DEFAULT NULL,
  `movement_id` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `payment_mode` enum('Cash','Online','Card') NOT NULL DEFAULT 'Cash',
  `abha_id` varchar(50) NOT NULL,
  PRIMARY KEY (`sale_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_batch_id` (`batch_id`),
  KEY `idx_movement_id` (`movement_id`),
  KEY `idx_abha_id` (`abha_id`),
  CONSTRAINT `fk_sales_batch` FOREIGN KEY (`batch_id`) REFERENCES `trx_batches` (`batch_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sales_movement` FOREIGN KEY (`movement_id`) REFERENCES `trx_stock_movement` (`movement_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_sales_user` FOREIGN KEY (`user_id`) REFERENCES `mas_users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.trx_sales: ~5 rows (approximately)
INSERT INTO `trx_sales` (`sale_id`, `user_id`, `batch_id`, `quantity`, `price`, `patient_name`, `patient_mobile`, `doctor_name`, `movement_id`, `created_at`, `payment_mode`, `abha_id`) VALUES
	(1, 22, 1, 1, 45.00, 'kundan khutiyare', '9754310014', 'Aditya kumar', 7, '2026-06-11 10:09:00', 'Cash', '97-5431-0014-2536'),
	(2, 22, 2, 2, 55.00, 'kundan khutiyare', '9754310014', 'Aditya kumar', 8, '2026-06-11 10:09:00', 'Cash', '97-5431-0014-2536'),
	(3, 44, 3, 1, 49.00, 'Yogesh verma', '8815751236', 'Subham panda', 15, '2026-06-11 11:51:38', 'Cash', '88-1575-1236-5487'),
	(4, 44, 4, 1, 67.00, 'Yogesh verma', '8815751236', 'Subham panda', 16, '2026-06-11 11:51:38', 'Cash', '88-1575-1236-5487'),
	(5, 44, 5, 1, 79.00, 'Namush', '8435772669', 'Balram verma', 20, '2026-06-12 16:33:05', 'Cash', '84-3577-2669-9754');

-- Dumping structure for table drug_tracking_system.trx_stock
CREATE TABLE IF NOT EXISTS `trx_stock` (
  `stock_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 0,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`stock_id`),
  UNIQUE KEY `unique_stock` (`user_id`,`batch_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_batch` (`batch_id`),
  CONSTRAINT `fk_stock_batch` FOREIGN KEY (`batch_id`) REFERENCES `trx_batches` (`batch_id`),
  CONSTRAINT `fk_stock_user` FOREIGN KEY (`user_id`) REFERENCES `mas_users` (`user_id`),
  CONSTRAINT `chk_stock_qty` CHECK (`quantity` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.trx_stock: ~10 rows (approximately)
INSERT INTO `trx_stock` (`stock_id`, `user_id`, `batch_id`, `quantity`, `last_updated`) VALUES
	(1, 21, 1, 70, '2026-06-11 10:07:14'),
	(2, 21, 2, 150, '2026-06-11 10:07:14'),
	(3, 22, 1, 29, '2026-06-11 10:09:00'),
	(4, 22, 2, 48, '2026-06-11 10:09:00'),
	(5, 45, 3, 73, '2026-06-11 11:48:48'),
	(6, 45, 4, 40, '2026-06-11 11:48:48'),
	(7, 44, 3, 6, '2026-06-11 11:51:38'),
	(8, 44, 4, 4, '2026-06-11 11:51:38'),
	(9, 21, 5, 40, '2026-06-12 16:31:42'),
	(10, 44, 5, 9, '2026-06-12 16:33:05');

-- Dumping structure for table drug_tracking_system.trx_stock_movement
CREATE TABLE IF NOT EXISTS `trx_stock_movement` (
  `movement_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL,
  `change_qty` int(11) NOT NULL,
  `movement_type` enum('IN','OUT') NOT NULL,
  `reference_id` int(11) NOT NULL,
  `reference_type` enum('batch','invoice','sale','manual','transfer') NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`movement_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_batch` (`batch_id`),
  KEY `idx_ref` (`reference_id`,`reference_type`),
  CONSTRAINT `fk_movement_batch` FOREIGN KEY (`batch_id`) REFERENCES `trx_batches` (`batch_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_movement_user` FOREIGN KEY (`user_id`) REFERENCES `mas_users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_change_qty` CHECK (`change_qty` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table drug_tracking_system.trx_stock_movement: ~19 rows (approximately)
INSERT INTO `trx_stock_movement` (`movement_id`, `user_id`, `batch_id`, `change_qty`, `movement_type`, `reference_id`, `reference_type`, `created_at`) VALUES
	(1, 21, 1, 100, 'IN', 1, 'batch', '2026-06-11 10:04:08'),
	(2, 21, 2, 200, 'IN', 2, 'batch', '2026-06-11 10:05:13'),
	(3, 21, 1, 30, 'OUT', 1, 'invoice', '2026-06-11 10:07:14'),
	(4, 22, 1, 30, 'IN', 1, 'invoice', '2026-06-11 10:07:14'),
	(5, 21, 2, 50, 'OUT', 1, 'invoice', '2026-06-11 10:07:14'),
	(6, 22, 2, 50, 'IN', 1, 'invoice', '2026-06-11 10:07:14'),
	(7, 22, 1, 1, 'OUT', 1, 'sale', '2026-06-11 10:09:00'),
	(8, 22, 2, 2, 'OUT', 2, 'sale', '2026-06-11 10:09:00'),
	(9, 45, 3, 80, 'IN', 3, 'batch', '2026-06-11 11:44:13'),
	(10, 45, 4, 45, 'IN', 4, 'batch', '2026-06-11 11:45:48'),
	(11, 45, 3, 7, 'OUT', 3, 'invoice', '2026-06-11 11:48:48'),
	(12, 44, 3, 7, 'IN', 3, 'invoice', '2026-06-11 11:48:48'),
	(13, 45, 4, 5, 'OUT', 3, 'invoice', '2026-06-11 11:48:48'),
	(14, 44, 4, 5, 'IN', 3, 'invoice', '2026-06-11 11:48:48'),
	(15, 44, 3, 1, 'OUT', 3, 'sale', '2026-06-11 11:51:38'),
	(16, 44, 4, 1, 'OUT', 4, 'sale', '2026-06-11 11:51:38'),
	(17, 21, 5, 50, 'IN', 5, 'batch', '2026-06-12 16:18:08'),
	(18, 21, 5, 10, 'OUT', 4, 'invoice', '2026-06-12 16:31:42'),
	(19, 44, 5, 10, 'IN', 4, 'invoice', '2026-06-12 16:31:42'),
	(20, 44, 5, 1, 'OUT', 5, 'sale', '2026-06-12 16:33:05');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
