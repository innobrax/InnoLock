-- ============================================================
-- Inno Lock - Script inicial MySQL
-- Plataforma SaaS multiempresa / multitenant
-- Servidor alvo: Linux Ubuntu + MySQL 8.x
-- Charset: utf8mb4
-- ============================================================

CREATE DATABASE IF NOT EXISTS innolock
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE innolock;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS unlock_events;
DROP TABLE IF EXISTS unlock_tokens;
DROP TABLE IF EXISTS trip_stops;
DROP TABLE IF EXISTS trips;
DROP TABLE IF EXISTS authorized_locations;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS devices;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS user_tenant_access;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS tenant_units;
DROP TABLE IF EXISTS tenants;
DROP TABLE IF EXISTS economic_groups;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE economic_groups (
  ecogr_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  ecogr_name VARCHAR(150) NOT NULL,
  ecogr_document VARCHAR(30) NULL,
  ecogr_status ENUM('ACTIVE','INACTIVE','BLOCKED') NOT NULL DEFAULT 'ACTIVE',
  ecogr_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ecogr_updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (ecogr_id),
  UNIQUE KEY uk_ecogr_document (ecogr_document)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tenants (
  tenan_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenan_ecogr_id BIGINT UNSIGNED NULL,
  tenan_name VARCHAR(150) NOT NULL,
  tenan_trade_name VARCHAR(150) NULL,
  tenan_document VARCHAR(30) NOT NULL,
  tenan_status ENUM('ACTIVE','INACTIVE','BLOCKED') NOT NULL DEFAULT 'ACTIVE',
  tenan_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tenan_updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (tenan_id),
  UNIQUE KEY uk_tenan_document (tenan_document),
  KEY idx_tenan_ecogr_id (tenan_ecogr_id),
  CONSTRAINT fk_tenan_ecogr
    FOREIGN KEY (tenan_ecogr_id) REFERENCES economic_groups (ecogr_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tenant_units (
  tenun_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenun_tenan_id BIGINT UNSIGNED NOT NULL,
  tenun_name VARCHAR(150) NOT NULL,
  tenun_type ENUM('CD','FILIAL','BASE','CLIENTE_ENTREGA','PONTO_AUTORIZADO','POSTO_FISCAL','MANUTENCAO') NOT NULL,
  tenun_address VARCHAR(255) NULL,
  tenun_city VARCHAR(120) NULL,
  tenun_state VARCHAR(2) NULL,
  tenun_zipcode VARCHAR(20) NULL,
  tenun_latitude DECIMAL(10,7) NULL,
  tenun_longitude DECIMAL(10,7) NULL,
  tenun_geofence_radius_meters INT UNSIGNED NOT NULL DEFAULT 100,
  tenun_status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  tenun_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tenun_updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (tenun_id),
  KEY idx_tenun_tenan_id (tenun_tenan_id),
  KEY idx_tenun_type (tenun_type),
  CONSTRAINT fk_tenun_tenan
    FOREIGN KEY (tenun_tenan_id) REFERENCES tenants (tenan_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE users (
  users_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  users_name VARCHAR(150) NOT NULL,
  users_email VARCHAR(180) NOT NULL,
  users_phone VARCHAR(30) NULL,
  users_password_hash VARCHAR(255) NOT NULL,
  users_status ENUM('ACTIVE','INACTIVE','BLOCKED') NOT NULL DEFAULT 'ACTIVE',
  users_last_login_at DATETIME NULL,
  users_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  users_updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (users_id),
  UNIQUE KEY uk_users_email (users_email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE roles (
  roles_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  roles_name VARCHAR(60) NOT NULL,
  roles_description VARCHAR(255) NULL,
  roles_scope ENUM('PLATFORM','GROUP','TENANT','UNIT','DRIVER') NOT NULL DEFAULT 'TENANT',
  roles_status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  PRIMARY KEY (roles_id),
  UNIQUE KEY uk_roles_name (roles_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_tenant_access (
  ustac_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  ustac_users_id BIGINT UNSIGNED NOT NULL,
  ustac_tenan_id BIGINT UNSIGNED NULL,
  ustac_ecogr_id BIGINT UNSIGNED NULL,
  ustac_tenun_id BIGINT UNSIGNED NULL,
  ustac_roles_id BIGINT UNSIGNED NOT NULL,
  ustac_status ENUM('ACTIVE','INACTIVE','REVOKED') NOT NULL DEFAULT 'ACTIVE',
  ustac_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ustac_updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (ustac_id),
  KEY idx_ustac_users_id (ustac_users_id),
  KEY idx_ustac_tenan_id (ustac_tenan_id),
  KEY idx_ustac_ecogr_id (ustac_ecogr_id),
  KEY idx_ustac_tenun_id (ustac_tenun_id),
  KEY idx_ustac_roles_id (ustac_roles_id),
  CONSTRAINT fk_ustac_users
    FOREIGN KEY (ustac_users_id) REFERENCES users (users_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_ustac_tenan
    FOREIGN KEY (ustac_tenan_id) REFERENCES tenants (tenan_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ustac_ecogr
    FOREIGN KEY (ustac_ecogr_id) REFERENCES economic_groups (ecogr_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ustac_tenun
    FOREIGN KEY (ustac_tenun_id) REFERENCES tenant_units (tenun_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ustac_roles
    FOREIGN KEY (ustac_roles_id) REFERENCES roles (roles_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE vehicles (
  vehic_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  vehic_tenan_id BIGINT UNSIGNED NOT NULL,
  vehic_plate VARCHAR(20) NOT NULL,
  vehic_fleet_code VARCHAR(50) NULL,
  vehic_description VARCHAR(150) NULL,
  vehic_status ENUM('ACTIVE','INACTIVE','MAINTENANCE','BLOCKED') NOT NULL DEFAULT 'ACTIVE',
  vehic_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vehic_updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (vehic_id),
  UNIQUE KEY uk_vehic_tenant_plate (vehic_tenan_id, vehic_plate),
  KEY idx_vehic_tenan_id (vehic_tenan_id),
  CONSTRAINT fk_vehic_tenan
    FOREIGN KEY (vehic_tenan_id) REFERENCES tenants (tenan_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE devices (
  devic_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  devic_tenan_id BIGINT UNSIGNED NOT NULL,
  devic_vehic_id BIGINT UNSIGNED NULL,
  devic_mac VARCHAR(12) NOT NULL,
  devic_ble_name VARCHAR(40) NOT NULL,
  devic_firmware_version VARCHAR(30) NULL,
  devic_secret_hash VARCHAR(255) NULL,
  devic_pairing_status ENUM('UNPAIRED','PAIRING','PAIRED','REVOKED') NOT NULL DEFAULT 'UNPAIRED',
  devic_status ENUM('ACTIVE','INACTIVE','BLOCKED','MAINTENANCE') NOT NULL DEFAULT 'ACTIVE',
  devic_last_seen_at DATETIME NULL,
  devic_paired_at DATETIME NULL,
  devic_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  devic_updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (devic_id),
  UNIQUE KEY uk_devic_mac (devic_mac),
  KEY idx_devic_tenan_id (devic_tenan_id),
  KEY idx_devic_vehic_id (devic_vehic_id),
  CONSTRAINT fk_devic_tenan
    FOREIGN KEY (devic_tenan_id) REFERENCES tenants (tenan_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_devic_vehic
    FOREIGN KEY (devic_vehic_id) REFERENCES vehicles (vehic_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE drivers (
  drive_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  drive_tenan_id BIGINT UNSIGNED NOT NULL,
  drive_users_id BIGINT UNSIGNED NOT NULL,
  drive_document VARCHAR(30) NULL,
  drive_license_number VARCHAR(40) NULL,
  drive_status ENUM('ACTIVE','INACTIVE','BLOCKED') NOT NULL DEFAULT 'ACTIVE',
  drive_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  drive_updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (drive_id),
  UNIQUE KEY uk_drive_tenant_user (drive_tenan_id, drive_users_id),
  KEY idx_drive_tenan_id (drive_tenan_id),
  KEY idx_drive_users_id (drive_users_id),
  CONSTRAINT fk_drive_tenan
    FOREIGN KEY (drive_tenan_id) REFERENCES tenants (tenan_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_drive_users
    FOREIGN KEY (drive_users_id) REFERENCES users (users_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE authorized_locations (
  autlo_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  autlo_tenan_id BIGINT UNSIGNED NOT NULL,
  autlo_tenun_id BIGINT UNSIGNED NULL,
  autlo_name VARCHAR(150) NOT NULL,
  autlo_type ENUM('CD','ENTREGA','BASE','POSTO_FISCAL','CLIENTE','MANUTENCAO','OUTRO') NOT NULL,
  autlo_address VARCHAR(255) NULL,
  autlo_city VARCHAR(120) NULL,
  autlo_state VARCHAR(2) NULL,
  autlo_latitude DECIMAL(10,7) NOT NULL,
  autlo_longitude DECIMAL(10,7) NOT NULL,
  autlo_geofence_radius_meters INT UNSIGNED NOT NULL DEFAULT 100,
  autlo_status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  autlo_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  autlo_updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (autlo_id),
  KEY idx_autlo_tenan_id (autlo_tenan_id),
  KEY idx_autlo_tenun_id (autlo_tenun_id),
  KEY idx_autlo_type (autlo_type),
  CONSTRAINT fk_autlo_tenan
    FOREIGN KEY (autlo_tenan_id) REFERENCES tenants (tenan_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_autlo_tenun
    FOREIGN KEY (autlo_tenun_id) REFERENCES tenant_units (tenun_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE trips (
  trips_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  trips_tenan_id BIGINT UNSIGNED NOT NULL,
  trips_vehic_id BIGINT UNSIGNED NOT NULL,
  trips_drive_id BIGINT UNSIGNED NULL,
  trips_origin_autlo_id BIGINT UNSIGNED NULL,
  trips_destination_autlo_id BIGINT UNSIGNED NULL,
  trips_code VARCHAR(60) NULL,
  trips_status ENUM('PLANNED','IN_PROGRESS','FINISHED','CANCELLED','BLOCKED') NOT NULL DEFAULT 'PLANNED',
  trips_planned_start_at DATETIME NULL,
  trips_planned_end_at DATETIME NULL,
  trips_started_at DATETIME NULL,
  trips_finished_at DATETIME NULL,
  trips_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  trips_updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (trips_id),
  KEY idx_trips_tenan_id (trips_tenan_id),
  KEY idx_trips_vehic_id (trips_vehic_id),
  KEY idx_trips_drive_id (trips_drive_id),
  KEY idx_trips_status (trips_status),
  CONSTRAINT fk_trips_tenan
    FOREIGN KEY (trips_tenan_id) REFERENCES tenants (tenan_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_trips_vehic
    FOREIGN KEY (trips_vehic_id) REFERENCES vehicles (vehic_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_trips_drive
    FOREIGN KEY (trips_drive_id) REFERENCES drivers (drive_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_trips_origin_autlo
    FOREIGN KEY (trips_origin_autlo_id) REFERENCES authorized_locations (autlo_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_trips_destination_autlo
    FOREIGN KEY (trips_destination_autlo_id) REFERENCES authorized_locations (autlo_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE trip_stops (
  trpst_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  trpst_trips_id BIGINT UNSIGNED NOT NULL,
  trpst_autlo_id BIGINT UNSIGNED NOT NULL,
  trpst_sequence INT UNSIGNED NOT NULL,
  trpst_unlock_allowed TINYINT(1) NOT NULL DEFAULT 1,
  trpst_planned_arrival_at DATETIME NULL,
  trpst_planned_departure_at DATETIME NULL,
  trpst_arrived_at DATETIME NULL,
  trpst_departed_at DATETIME NULL,
  trpst_status ENUM('PENDING','ARRIVED','FINISHED','SKIPPED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  trpst_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  trpst_updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (trpst_id),
  UNIQUE KEY uk_trpst_trip_sequence (trpst_trips_id, trpst_sequence),
  KEY idx_trpst_trips_id (trpst_trips_id),
  KEY idx_trpst_autlo_id (trpst_autlo_id),
  CONSTRAINT fk_trpst_trips
    FOREIGN KEY (trpst_trips_id) REFERENCES trips (trips_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_trpst_autlo
    FOREIGN KEY (trpst_autlo_id) REFERENCES authorized_locations (autlo_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE unlock_tokens (
  unlto_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  unlto_tenan_id BIGINT UNSIGNED NOT NULL,
  unlto_devic_id BIGINT UNSIGNED NOT NULL,
  unlto_trips_id BIGINT UNSIGNED NULL,
  unlto_users_id BIGINT UNSIGNED NOT NULL,
  unlto_autlo_id BIGINT UNSIGNED NULL,
  unlto_type ENUM('DELIVERY_UNLOCK','CD_UNLOCK','REMOTE_EXCEPTION','MAINTENANCE_UNLOCK','EMERGENCY_UNLOCK') NOT NULL,
  unlto_token_hash VARCHAR(255) NOT NULL,
  unlto_nonce VARCHAR(80) NOT NULL,
  unlto_counter BIGINT UNSIGNED NULL,
  unlto_valid_from DATETIME NOT NULL,
  unlto_valid_until DATETIME NOT NULL,
  unlto_used_at DATETIME NULL,
  unlto_status ENUM('CREATED','USED','EXPIRED','REVOKED','DENIED') NOT NULL DEFAULT 'CREATED',
  unlto_reason VARCHAR(255) NULL,
  unlto_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (unlto_id),
  UNIQUE KEY uk_unlto_nonce (unlto_nonce),
  KEY idx_unlto_tenan_id (unlto_tenan_id),
  KEY idx_unlto_devic_id (unlto_devic_id),
  KEY idx_unlto_trips_id (unlto_trips_id),
  KEY idx_unlto_users_id (unlto_users_id),
  KEY idx_unlto_autlo_id (unlto_autlo_id),
  KEY idx_unlto_status (unlto_status),
  CONSTRAINT fk_unlto_tenan
    FOREIGN KEY (unlto_tenan_id) REFERENCES tenants (tenan_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_unlto_devic
    FOREIGN KEY (unlto_devic_id) REFERENCES devices (devic_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_unlto_trips
    FOREIGN KEY (unlto_trips_id) REFERENCES trips (trips_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_unlto_users
    FOREIGN KEY (unlto_users_id) REFERENCES users (users_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_unlto_autlo
    FOREIGN KEY (unlto_autlo_id) REFERENCES authorized_locations (autlo_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE unlock_events (
  unlev_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  unlev_tenan_id BIGINT UNSIGNED NOT NULL,
  unlev_devic_id BIGINT UNSIGNED NOT NULL,
  unlev_vehic_id BIGINT UNSIGNED NULL,
  unlev_trips_id BIGINT UNSIGNED NULL,
  unlev_users_id BIGINT UNSIGNED NULL,
  unlev_unlto_id BIGINT UNSIGNED NULL,
  unlev_autlo_id BIGINT UNSIGNED NULL,
  unlev_type ENUM('DELIVERY_UNLOCK','CD_UNLOCK','REMOTE_EXCEPTION','MAINTENANCE_UNLOCK','EMERGENCY_UNLOCK','STATUS_CHECK') NOT NULL,
  unlev_result ENUM('SUCCESS','AUTH_INVALID','EXPIRED_TOKEN','REPLAY_DETECTED','FEEDBACK_TIMEOUT','DENIED_BY_GEOFENCE','DENIED_BY_CENTRAL','DEVICE_ERROR','UNKNOWN_ERROR') NOT NULL,
  unlev_requested_latitude DECIMAL(10,7) NULL,
  unlev_requested_longitude DECIMAL(10,7) NULL,
  unlev_executed_latitude DECIMAL(10,7) NULL,
  unlev_executed_longitude DECIMAL(10,7) NULL,
  unlev_gps_accuracy_meters DECIMAL(8,2) NULL,
  unlev_distance_from_authorized_meters DECIMAL(10,2) NULL,
  unlev_lock_feedback ENUM('UNKNOWN','LOCKED','UNLOCKED','TIMEOUT','ERROR') NOT NULL DEFAULT 'UNKNOWN',
  unlev_app_timestamp DATETIME NULL,
  unlev_device_timestamp DATETIME NULL,
  unlev_server_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  unlev_raw_response TEXT NULL,
  unlev_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (unlev_id),
  KEY idx_unlev_tenan_id (unlev_tenan_id),
  KEY idx_unlev_devic_id (unlev_devic_id),
  KEY idx_unlev_vehic_id (unlev_vehic_id),
  KEY idx_unlev_trips_id (unlev_trips_id),
  KEY idx_unlev_users_id (unlev_users_id),
  KEY idx_unlev_unlto_id (unlev_unlto_id),
  KEY idx_unlev_autlo_id (unlev_autlo_id),
  KEY idx_unlev_type_result (unlev_type, unlev_result),
  KEY idx_unlev_created_at (unlev_created_at),
  CONSTRAINT fk_unlev_tenan
    FOREIGN KEY (unlev_tenan_id) REFERENCES tenants (tenan_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_unlev_devic
    FOREIGN KEY (unlev_devic_id) REFERENCES devices (devic_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_unlev_vehic
    FOREIGN KEY (unlev_vehic_id) REFERENCES vehicles (vehic_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_unlev_trips
    FOREIGN KEY (unlev_trips_id) REFERENCES trips (trips_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_unlev_users
    FOREIGN KEY (unlev_users_id) REFERENCES users (users_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_unlev_unlto
    FOREIGN KEY (unlev_unlto_id) REFERENCES unlock_tokens (unlto_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_unlev_autlo
    FOREIGN KEY (unlev_autlo_id) REFERENCES authorized_locations (autlo_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE audit_logs (
  audlo_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  audlo_tenan_id BIGINT UNSIGNED NULL,
  audlo_users_id BIGINT UNSIGNED NULL,
  audlo_entity VARCHAR(80) NOT NULL,
  audlo_entity_id BIGINT UNSIGNED NULL,
  audlo_action VARCHAR(80) NOT NULL,
  audlo_ip_address VARCHAR(45) NULL,
  audlo_user_agent VARCHAR(255) NULL,
  audlo_old_data JSON NULL,
  audlo_new_data JSON NULL,
  audlo_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (audlo_id),
  KEY idx_audlo_tenan_id (audlo_tenan_id),
  KEY idx_audlo_users_id (audlo_users_id),
  KEY idx_audlo_entity (audlo_entity, audlo_entity_id),
  KEY idx_audlo_created_at (audlo_created_at),
  CONSTRAINT fk_audlo_tenan
    FOREIGN KEY (audlo_tenan_id) REFERENCES tenants (tenan_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_audlo_users
    FOREIGN KEY (audlo_users_id) REFERENCES users (users_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO roles (roles_name, roles_description, roles_scope) VALUES
('SUPER_ADMIN', 'Administrador geral da plataforma SaaS', 'PLATFORM'),
('GROUP_ADMIN', 'Administrador de grupo econômico', 'GROUP'),
('TENANT_ADMIN', 'Administrador da empresa cliente', 'TENANT'),
('CENTRAL_MONITORAMENTO', 'Operador da central de monitoramento', 'TENANT'),
('OPERADOR_LOGISTICO', 'Operador logístico da empresa', 'TENANT'),
('RESPONSAVEL_CD', 'Responsável por centro de distribuição', 'UNIT'),
('MOTORISTA', 'Motorista autorizado a operar app móvel', 'DRIVER'),
('TECNICO_MANUTENCAO', 'Técnico de manutenção autorizado', 'TENANT'),
('AUDITOR', 'Usuário com acesso de auditoria e consulta', 'TENANT');

-- ============================================================
-- Fim do script inicial
-- ============================================================
