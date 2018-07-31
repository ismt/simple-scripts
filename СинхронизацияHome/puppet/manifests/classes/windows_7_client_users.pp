class windows_7_client_users {
        # С русскими символами глюки, лучше переименовать группу Пользователи на машине на Users
        # wmic group where name='Пользователь' rename Users
        user { 'client':        ensure => present, managehome => true, password   => 'tttttt', groups => ['Users'] }
        user { 'client1':       ensure => absent , managehome => true, password   => 'tttttt', groups => ['Users'] }

}

#https://docs.puppetlabs.com/references/3.7.latest/type.html


