class openmrs-sync (
	
	$tomcat_home = hiera('tomcat_home'),
	$ssh_parent_address = hiera('ssh_parent_address'),
	$ssh_user = hiera('ssh_user'),
	$ssh_port = hiera('ssh_port'),
	$openmrs_db = hiera('openmrs_db'),
	$openmrs_db_remote = hiera('openmrs_db_remote'),
	$openmrs_db_user = hiera('openmrs_db_user'),
	$openmrs_db_password = hiera('openmrs_db_password'),
	$mysql_root_user = hiera('mysql_root_user'),
	$mysql_root_password = hiera('mysql_root_password'),
	$parent_mysql_root_user = hiera('parent_mysql_root_user'),
	$parent_mysql_db_password = hiera('parent_mysql_db_password'),
	$sync_admin_email = hiera('sync_admin_email'),
	$sync_parent_uuid = hiera('sync_parent_uuid'),
	$sync_parent_user_name = hiera('sync_parent_user_name'),
	$sync_parent_user_password = hiera('sync_parent_user_password')	,
	$sync_parent_name = hiera('sync_parent_name'),
	$sync_parent_address = hiera('sync_parent_address')

	){

	require pih_java
  	require pih_mysql
  	require pih_tomcat
  	require openmrs
    
    $openmrs_folder = "${tomcat_home}/.OpenMRS"
    $pih_openmrs_modules = "${openmrs_folder}/modules"
    $openmrs_bin_folder = "${openmrs_folder}/bin"
    $openmrs_db_folder = "${openmrs_folder}/db"
    $pih_openmrs_war = "${tomcat_home}/webapps/openmrs.war"
    $child_name = $hostname
    $tomcat_start = "${tomcat_home}/bin/startup.sh"
    $tomcat_catalina = "/var/lib/tomcat6/logs/catalina.out"

	$openmrs_drop_create_db_sql = "${openmrs_bin_folder}/dropAndCreateDb.sql"
	$check_For_Unsynced_Records_sh = "${openmrs_bin_folder}/checkForUnsyncedRecords.sql"
	$remove_unsynced_changes_sh = "${openmrs_bin_folder}/remove_unsynced_changes.sh"
	$get_db_from_parent_sh = "${openmrs_bin_folder}/getDbFromParent.sh"
	$remove_changeloglock_sh = "${openmrs_bin_folder}/remove_changeloglock.sh"
	$delete_sync_tables_sql = "${openmrs_bin_folder}/deleteSyncTables.sql"
	$update_child_server_settings_sql = "${openmrs_bin_folder}/updateChildServerSettings.sql"
	$update_parent_server_settings_sql = "${openmrs_bin_folder}/updateParentServerSettings.sql"

	$server_uuid_text_file = "/tmp/${child_name}-serveruuid.txt" # ${openmrs_folder}/
	$uploaded_child_server_uuid = "/tmp/${child_name}-serveruuid.txt"
	$output_server_uuid = regsubst($server_uuid_text_file, '[\\]', '/', G)
	$ssh_key = "${openmrs_db_folder}/id_rsa"

	$mysql_exe = "/usr/bin/mysql"
	
  	file { $openmrs_bin_folder:
    	ensure  => directory,  
    	mode 	=> '0775',  
  	} ->

	file { $check_For_Unsynced_Records_sh: 
		ensure  => present,	
		content => template('openmrs-sync/checkForUnsyncedRecords.sh.erb'), 	
		mode    => '0755',
	} ->

  	file { $pih_openmrs_war:
    	mode    	=> '0775',  
  	} ->

	file { $openmrs_drop_create_db_sql: 
		ensure  => present,	
		content => template('openmrs/dropAndCreateDb.sql.erb'), 	
		mode    => '0755',
	} ->

	file { $remove_unsynced_changes_sh: 
		ensure  => present,	
		content => template('openmrs-sync/remove_unsynced_changes.sh.erb'), 	
		mode    => '0755',
	} ->

	file { $remove_changeloglock_sh: 
		ensure  => present,	
		content => template('openmrs-sync/remove_changeloglock.sh.erb'), 	
		mode    => '0755',
	} ->

	file { $delete_sync_tables_sql: 
		ensure  => present,	
		source  => "puppet:///modules/openmrs/deleteSyncTables.sql",
		mode    => '0755',
	} ->

	file { $ssh_key: 
		ensure  => present,	
		source  => "puppet:///modules/openmrs-sync/id_rsa",
		mode    => '0600',
	} ->

	file { $get_db_from_parent_sh: 
		ensure  => present,	
		content => template('openmrs-sync/getDbFromParent.sh.erb'), 	
		mode    => '0755',
	} ->
	
	file { $update_child_server_settings_sql: 
		ensure  => present,	
		content => template('openmrs-sync/updateChildServerSettings.sql.erb'), 
		mode    => '0755',
	} ->

	file { $update_parent_server_settings_sql: 
		ensure  => present,	
		content => template('openmrs-sync/updateParentServerSettings.sql.erb'), 
		mode    => '0755',
	} 

	#exec { 'setup-openmrs-war-modules-db':
  	#	cwd     => $openmrs_bin_folder,
  	#	command => "${get_db_from_parent_sh}",    
  	#	logoutput => true, 
  	#	timeout => 0, 
  	#}

}

	