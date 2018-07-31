CREATE TABLE `squid` (
	`id` BIGINT(20) NOT NULL AUTO_INCREMENT,
	`ip` VARCHAR(16) NOT NULL DEFAULT '0' COLLATE 'utf8_unicode_ci',
	`tcp_status` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8_unicode_ci',
	`bytes` BIGINT(20) UNSIGNED NOT NULL DEFAULT '0',
	`link` VARCHAR(15000) NOT NULL DEFAULT '' COLLATE 'utf8_unicode_ci',
	`trans` VARCHAR(65) NOT NULL DEFAULT '' COLLATE 'utf8_unicode_ci',
	`time` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
	`user_agent` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8_unicode_ci',
	`insert_date` DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00',
	PRIMARY KEY (`id`),
	INDEX `ip` (`ip`),
	INDEX `tcp_status` (`tcp_status`),
	INDEX `insert_date` (`insert_date`),
	INDEX `time` (`time`)
)
COLLATE='utf8_unicode_ci'
ENGINE=MyISAM
AUTO_INCREMENT=20806
;
