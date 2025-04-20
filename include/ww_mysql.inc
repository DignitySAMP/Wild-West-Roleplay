#tryinclude <a_samp>
#tryinclude <a_mysql>

new mysql;

// MySQL info
#if defined SERVER_DEV
new SQL_HOST [ 36 ] = "localhost",
	SQL_USER [ 36 ] = "sysadmin",
	SQL_DATA [ 36 ] = "wwrp",
	SQL_PASS [ 36 ] = "password" ;
#endif

#if !defined SERVER_DEV
new SQL_HOST [ 36 ] = "localhost",
	SQL_USER [ 36 ] = "sysadmin",
	SQL_DATA [ 36 ] = "wwrp",
	SQL_PASS [ 36 ] = "password" ;
#endif


MySQL_Init(database[]) {
    mysql_log(LOG_ERROR | LOG_WARNING, LOG_TYPE_HTML);

/*
	#if defined MAPPING_SERVER
		SQL_DATA [ 0 ] = EOS ;
		strcat(SQL_DATA, "mapping", 8) ;
	#endif

	#if defined DEBUG_SERVER
		SQL_DATA [ 0 ] = EOS ;
		strcat(SQL_DATA, "debug", 8) ;
	#endif		
*/

	SQL_DATA [ 0 ] = EOS ;
	strcat(SQL_DATA, database) ;
    mysql = mysql_connect ( SQL_HOST, SQL_USER, SQL_DATA, SQL_PASS ) ;

    if(mysql_errno(mysql) != 0) return print(" * [SQL] Could not connect to database!\n");
	return print(" * [SQL] Connected to database ");
}

stock Float:cache_get_field_float(row, const field_name[]) {
	new str[16], g_iHandle = mysql;

	cache_get_field_content(row, field_name, str, g_iHandle, sizeof(str));
	return floatstr(str);
}

stock cache_get_field_int(row, const field_name[]) {
	new str[12], g_iHandle = mysql;

	cache_get_field_content(row, field_name, str, g_iHandle, sizeof(str));
	return strval(str);
}

public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
	switch(errorid)
	{
		case CR_SERVER_GONE_ERROR:
		{
			printf(" * [SQL] Lost connection to server, trying reconnect...");
			mysql_reconnect(connectionHandle);
		}
		case ER_SYNTAX_ERROR:
		{
			printf(" * [SQL] Something is wrong in your syntax, query: %s",query);
		}
	}
	return 1;
}