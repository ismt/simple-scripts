class windows_7_client_start {
        require windows_7_client_users
	file { "Комплект файлов для Windows":
                path => "C:\ProgramData\PuppetLabs\puppet\puppet_files",
                source  => "puppet:///files/windows_7_client/puppet_files",
		source_permissions => ignore,
		ensure => directory,
		recurse => true,
		purge => true,
		force => true,
		backup => false
              }
	package {"7-Zip 9.38":
	         source => "C:\ProgramData\PuppetLabs\puppet\puppet_files\32\7z938.msi",
		 ensure => installed,
		 require => file ["Комплект файлов для Windows"]
	}

	package {"LibreOffice 4.4.3.2":
	         source => "C:\ProgramData\PuppetLabs\puppet\puppet_files\32\LibreOffice_4.4.3_Win_x86.msi",
		 ensure => installed,
		 require => file ["Комплект файлов для Windows"]
	}

	package {"LibreOffice 4.4 Help Pack (Russian)":
	         source => "C:\ProgramData\PuppetLabs\puppet\puppet_files\32\LibreOffice_4.4.3_Win_x86_helppack_ru.msi",
		 ensure => installed,
		 require => file ["Комплект файлов для Windows"]
	}

	package {"Notepad++ 6.7.4":
	         source => 'C:\ProgramData\PuppetLabs\puppet\puppet_files\32\nppinstaller.msi',
		 ensure => installed,
		 require => file ["Комплект файлов для Windows"]
	}

}
