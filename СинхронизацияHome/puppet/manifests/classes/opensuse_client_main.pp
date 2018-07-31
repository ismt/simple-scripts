class opensuse_start {
	file { "/etc/zypp":
                source  => "puppet:///files/opensuse_client_profile/etc/zypp",
		owner => root,
		group => root,
		recurse => true,
		ensure => directory,
		purge => true,
		force => true
        }
	file { "/etc/squid":
                source  => "puppet:///files/opensuse_client_profile/etc/squid",
		owner => root,
		group => root,
		recurse => true,
		ensure => directory,
		purge => true,
		force => true,
		backup => false,
		notify => Service["squid"]
        }

	file { "/etc/nilfs_cleanerd.conf":
                source  => "puppet:///files/opensuse_client_profile/etc/nilfs_cleanerd.conf",
		owner => root,
		group => root,
        }

        file { "Комплект скриптов":
                path => "/root/scripts",
                source  => "puppet:///files/opensuse_client_profile/root/scripts",
		ensure => directory,
		show_diff => no,
		recurse => true,
		purge => true,
		force => true,
		owner => root,
		group => root,
		mode => 'u+rwx,g-rwx,o-rwx',
		backup => false
        }

	file { "Конфиг samba":
                path => "/etc/samba/smb.conf",
                source  => "puppet:///files/opensuse_client_profile/etc/samba/smb.conf",
		mode => 644,
		owner => root,
		group => root,
		notify => service["smb"]
        }

	file { "Ключи ssh":
                path => "/root/.ssh",
                source  => "puppet:///files/opensuse_client_profile/root/.ssh",
		ensure => directory,
		owner => root,
		group => root,
		mode => 600,
		recurse => true,
		purge => true
        }

	file { "/etc/crontab":
                source  => "puppet:///files/opensuse_client_profile/etc/crontab",
                owner => root,
		group => root,
		mode => 600,
		notify => Service["cron"]
             }

        file { "/etc/systemd/journald.conf":
                source  => "puppet:///files/opensuse_client_profile/etc/systemd/journald.conf",
                owner => root,
		group => root,
		mode => 644,
		notify => Service["systemd-journald"]
             }

	file { "/etc/tmpfiles.d":
                source  => "puppet:///files/opensuse_client_profile/etc/tmpfiles.d",
                owner => root,
		group => root,
		recurse => true,
		purge => true,
		ensure => directory,
		mode => 644,
             }

	file { "Отключение автологина":
                path => "/etc/sysconfig/displaymanager",
                source  => "puppet:///files/opensuse_client_profile/etc/sysconfig/displaymanager",
		owner => root,
		group => root,
		mode => 644
        }
	file { "Прокси":
                path => "/etc/sysconfig/proxy",
                source  => "puppet:///files/opensuse_client_profile/etc/sysconfig/proxy",
		owner => root,
		group => root,
		mode => 644
        }

        file { "Принтер чеков права COM port":
                path => "/etc/udev/rules.d/85-datecs.rules",
                source  => "puppet:///files/opensuse_client_profile/etc/udev/rules.d/85-datecs.rules",
		owner => root,
		group => root,
		mode => 644
        }

	file { "Коррекция входа КДЕ":
                path => "/usr/share/kde4/config/kdm",
                source  => "puppet:///files/opensuse_client_profile/usr/share/kde4/config/kdm",
		ensure => directory,
		recurse => true,
		owner => root,
		group => root,
        }
	file { "Xsetup":
                path => "/etc/X11/xdm/Xsetup",
                source  => "puppet:///files/opensuse_client_profile/etc/X11/xdm/Xsetup",
		mode => 755,
		owner => root,
		group => root,
        }

        file { "/etc/pam.d/common-auth-pc":
                path => "/etc/pam.d/common-auth-pc",
                source  => 'puppet:///files/opensuse_client_profile/etc/pam.d/common-auth-pc',
		mode => 644,
		owner => root,
		group => root,
        }

        file { "/etc/pam.d/common-session-pc":
                path => "/etc/pam.d/common-session-pc",
                source  => 'puppet:///files/opensuse_client_profile/etc/pam.d/common-session-pc',
		mode => 644,
		owner => root,
		group => root,
        }

        file {"/etc/init.d/boot.local":
               source  => "puppet:///files/opensuse_client_profile/etc/init.d/boot.local",
               mode => 744,
               owner => root,
               group => root,
        }

	tidy {"Удаляем не нужные логи":
	       path => '/var/log',
	       recurse => 1,
	       backup => no,
	       matches => ["puppet_*.*"]
	}

        require opensuse_13_2_users

}

class opensuse_install_1
{
	require opensuse_start
	exec { "Обновление пакетов": #Если выдает ошибку в первый раз, обновитесь через yast с репозиториями по умолчанию
                path => "/usr/local/bin:/usr/bin:/sbin:/usr/sbin:/bin",
                command => "zypper clean ; ionice -c3 zypper --non-interactive --non-interactive-include-reboot-patches update --auto-agree-with-licenses", #--no-gpg-checks Нехорошо
		timeout => 0
             }

}

class opensuse_install_2
{
	require opensuse_install_1

	package {"mc" :                                     provider => zypper, allow_virtual => false, ensure => installed }
	package {"sshpass" :                                provider => zypper, allow_virtual => false, ensure => installed }
	package {"MozillaThunderbird" :                     provider => zypper, allow_virtual => false, ensure => installed }
	package {"MozillaThunderbird-translations-common" : provider => zypper, allow_virtual => false, ensure => installed }
	package {"libfreerdp-1_0-plugins" :                 provider => zypper, allow_virtual => false, ensure => installed }
	package {"htop" :                                   provider => zypper, allow_virtual => false, ensure => installed }
	package {"iotop" :                                  provider => zypper, allow_virtual => false, ensure => installed }
	package {"psi" :                                    provider => zypper, allow_virtual => false, ensure => installed }
	package {"unrar" :                                  provider => zypper, allow_virtual => false, ensure => installed }
	package {"hplip" :                                  provider => zypper, allow_virtual => false, ensure => installed }
	package {"p7zip" :                                  provider => zypper, allow_virtual => false, ensure => installed }
	package {"pv" :                                     provider => zypper, allow_virtual => false, ensure => installed }
	package {"sqlite3" :                                provider => zypper, allow_virtual => false, ensure => installed }
	package {"squid" :                                  provider => zypper, allow_virtual => false, ensure => installed }
	package {"quota" :                                  provider => zypper, allow_virtual => false, ensure => installed }
	package {"x11vnc" :                                 provider => zypper, allow_virtual => false, ensure => installed }
	package {"xorg-x11" :                               provider => zypper, allow_virtual => false, ensure => installed }
	package {"midori" :                                 provider => zypper, allow_virtual => false, ensure => installed }
	package {"kopete" :                                 provider => zypper, allow_virtual => false, ensure => installed }
	package {"prelink" :                                provider => zypper, allow_virtual => false, ensure => installed }
	package {"fetchmsttfonts" :                         provider => zypper, allow_virtual => false, ensure => installed }
	package {"psi+" :                                   provider => zypper, allow_virtual => false, ensure => installed }
	package {"gparted" :                                provider => zypper, allow_virtual => false, ensure => installed }
	# Чтоб работало видео в Firefox
	package {"gstreamer-plugins-libav" :    source => "/root/scripts/rpm_pack/gstreamer-plugins-libav-1.4.5-1.2.i586.rpm",   provider => rpm, allow_virtual => false, ensure => installed }

}

class opensuse_clean {
	require  opensuse_install_2
	exec { "Удаление ненужных пакетов":
                path => "/usr/local/bin:/usr/bin:/sbin:/usr/sbin:/bin",
                command => "zypper --no-refresh --non-interactive rm apper PackageKit PackageKit-backend-zypp PackageKit-branding-openSUSE PackageKit-browser-plugin \
                                    PackageKit-gstreamer-plugin PackageKit-gtk3-module marble marble-data marble-doc plasma-addons-marble graphviz digikam-doc digikam \
                                    flash-player-kde4 pullin-flash-player flash-player bluedevil bluez snapper yast2-snapper",
		returns => 0,
             }

        exec { "Блокировка пакетов":
                path => "/usr/local/bin:/usr/bin:/sbin:/usr/sbin:/bin",
                command => "zypper addlock apper PackageKit PackageKit-backend-zypp PackageKit-branding-openSUSE PackageKit-browser-plugin PackageKit-gstreamer-plugin PackageKit-gtk3-module",
             }

	package {"wireless-tools" :                         provider => zypper, allow_virtual => false, ensure => absent    }
	package {"btrfsmaintenance" :                       provider => zypper, allow_virtual => false, ensure => absent    }
	package {"k3b" :                                    provider => zypper, allow_virtual => false, ensure => absent    }
	package {"kaddressbook" :                           provider => zypper, allow_virtual => false, ensure => absent    }
	package {"kmail" :                                  provider => zypper, allow_virtual => false, ensure => absent    }
	package {"ktorrent" :                               provider => zypper, allow_virtual => false, ensure => absent    }
	package {"knotes" :                                 provider => zypper, allow_virtual => false, ensure => absent    }
	package {"hugin" :                                  provider => zypper, allow_virtual => false, ensure => absent    }
	package {"kontact" :                                provider => zypper, allow_virtual => false, ensure => absent    }
	package {"korganizer" :                             provider => zypper, allow_virtual => false, ensure => absent    }

}

class opensuse_end {
        require opensuse_clean

	file { "Для монтирования /mnt/bsdbox_fileserver":
                path => "/mnt/bsdbox_fileserver",
		ensure => directory,
		owner => root,
		group => root,
		backup => false
        }

        file { "Для монтирования /mnt/server.vd_pdf":
                path => "/mnt/server.vd_pdf",
		ensure => directory,
		owner => root,
		group => root,
		backup => false
        }

	exec { "Обновление профилей пользователей":
                 cwd => "/root",
                 path => "/root:/usr/local/bin:/usr/bin:/sbin:/usr/sbin:/bin",
                 command => "/root/scripts/update_skel.sh > /var/log/puppet_update_skel.log 2>&1",
		 timeout => 0
        }
        file { "Firefox с ограничениями 1 default_proxy.js":
                path => "/usr/lib/firefox_localhost/defaults/pref/default_proxy.js",
                source  => "puppet:///files/opensuse_client_profile/usr/lib/firefox_localhost/defaults/pref/default_proxy.js",
		ensure => file,
		backup => false,
		mode => 644,
		owner => root,
		group => root,
		show_diff => false,
		require => exec ["Обновление профилей пользователей"]
        }
        file { "Firefox с ограничениями 2 mozilla.cfg":
                path => "/usr/lib/firefox_localhost/mozilla.cfg",
                source  => "puppet:///files/opensuse_client_profile/usr/lib/firefox_localhost/mozilla.cfg",
		ensure => file,
		backup => false,
		mode => 644,
		owner => root,
		group => root,
		show_diff => false,
		require => exec ["Обновление профилей пользователей"]
        }



	file_line { 'Темп в оперативу 1':
            path  => '/etc/fstab',
            line  => '#tmpfs                                     /tmp                 tmpfs      size=50%              0 0',
        }
        file_line { 'Темп в оперативу 2':
            path  => '/etc/fstab',
            line  => '#tmpfs                                     /var/tmp             tmpfs      size=50%              0 0',
            require => file_line["Темп в оперативу 1"]
        }
	file_line { 'Заготовка fstab samba bsdbox':
            path  => '/etc/fstab',
            line  => '#//192.168.120.10/fileserver               /mnt/bsdbox_fileserver cifs     auto,user,iocharset=utf8,_netdev,username=aquarius_5,password=terminal 1 2',
	    require => file_line["Темп в оперативу 2"]
        }
	file_line { 'Заготовка fstab samba pdf':
            path  => '/etc/fstab',
            line  => '#//192.168.120.20/pdf                      /mnt/server.vd_pdf     cifs     auto,user,iocharset=utf8,_netdev,username=aquarius_5,password=terminal 1 2',
	    require => file_line["Заготовка fstab samba bsdbox"]
        }


        

	file { "/etc/cron.monthly":
                path => "/etc/cron.monthly",
                source  => "puppet:///files/opensuse_client_profile/etc/cron.monthly",
		owner => root,
		group => root,
		ensure => directory,
		recurse => true,
		purge => true
        }
        file { "/etc/cron.weekly":
                path => "/etc/cron.weekly",
                source  => "puppet:///files/opensuse_client_profile/etc/cron.weekly",
		owner => root,
		group => root,
		ensure => directory,
		recurse => true,
		purge => true
        }

        service {"ntpd":            ensure => "running", enable => true, provider => systemd  }
        service {"SuSEfirewall2":   ensure => "stopped", enable => false, provider => systemd  }
        service {"wpa_supplicant":  ensure => "stopped", enable => false, provider => systemd  }
        service {"postfix":         ensure => "stopped", enable => false, provider => systemd  }
        service {"iscsi":           ensure => "stopped", enable => false, provider => systemd  }
        service {"sshd":            ensure => "running", enable => true, provider => systemd  }
        service {"squid":           ensure => "running", enable => true, provider => systemd  }
        service {"smb":             ensure => "running", enable => true, provider => systemd  }
        service {"gpm":             ensure => "running", enable => true, provider => systemd  }
        service {"nmb":             ensure => "running", enable => true, provider => systemd  }
        service {"cups":            ensure => "running", enable => true, provider => systemd  }
        service {"cron":            ensure => "running", enable => true, provider => systemd  }
        service {"systemd-journald":ensure => "running", enable => true, provider => systemd  }

}

#https://docs.puppetlabs.com/references/3.7.latest/type.html


