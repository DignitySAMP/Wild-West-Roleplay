#if defined _inc_data
	#undef _inc_data
#endif	


enum {
    TRAP_BEAR,
    TRAP_NOOSE
};

enum TrapData{
    trap_id,
    trap_constant,

    trap_object,

    trap_owner,
    trap_deployed,
    trap_bait,

    Float: trap_pos_x,
    Float: trap_pos_y,
    Float: trap_pos_z,

    Float: trap_rot_x,
    Float: trap_rot_y,
    Float: trap_rot_z,

    trap_area,
    DynamicText3D: trap_label
};

#define MAX_TRAPS 50
#define INVALID_TRAP_ID (-1)

new Trap[MAX_TRAPS][TrapData];

Init_Traps(){
        
        mysql_tquery ( mysql, "SELECT * FROM traps", "LoadTrapData", "" ) ; 

        /*
        Note from David

        no need for formatting, no variables need to be accounted for this query

        also, "LoadTrapData(playerid)" isn't the way you do it if there are params in the function/callback
        that would look like `mysql_tquery(mysql,query,"LoadTrapData", "d", playerid)`

        last, you didn't use `playerid` in LoadTrapData so I removed the param
        */
}

/*
CMD:createtrap(playerid, params[]){
		
    new trapid = GetFreeTrapID();

    CreateTrap(playerid,trapid);

    return true;

}
*/

forward LoadTrapData();
public LoadTrapData() {

    new rows, fields ;
    cache_get_data ( rows, fields, mysql ) ;

    if (!rows){
        printf("No traps loaded.");

        return true;
    }

    if (rows){

        for ( new i, j = rows; i < j; i ++ ) {

            Trap[i][trap_id] = cache_get_field_int (i, "trap_id");
            Trap[i][trap_constant] = cache_get_field_int(i, "trap_constant");

            Trap[i][trap_owner] = cache_get_field_int(i, "trap_owner");

            Trap[i][trap_deployed] = cache_get_field_int(i, "trap_deployed_state");
            Trap[i][trap_bait] = cache_get_field_int(i,"trap_bait");

            Trap[i][trap_pos_x] = cache_get_field_float(i, "trap_pos_x");
            Trap[i][trap_pos_y] = cache_get_field_float(i, "trap_pos_y");
            Trap[i][trap_pos_z] = cache_get_field_float(i, "trap_pos_z");

            Trap[i][trap_rot_x] = cache_get_field_float(i, "trap_rot_x");
            Trap[i][trap_rot_y] = cache_get_field_float(i, "trap_rot_y");
            Trap[i][trap_rot_z] = cache_get_field_float(i, "trap_rot_z");

            Trap[i][trap_area] = CreateDynamicCircle(Trap[i][trap_pos_x], Trap[i][trap_pos_y], 1.6);
            //Trap[i][trap_label] = CreateDynamic3DTextLabel(sprintf("TRAP - [ID: %i (DB: %i)]", i, Trap[i][trap_id]), COLOR_BLUE, Trap[i][trap_pos_x], Trap[i][trap_pos_y], Trap[i][trap_pos_z], 15.0);
            Trap[i][trap_object] = CreateDynamicObject(TRAP_FOOTLOCK, Trap [ i ] [ trap_pos_x ], Trap [ i ] [ trap_pos_y ], Trap [ i ] [ trap_pos_z ] + 0.2, Trap[i][trap_rot_x], Trap[i][trap_rot_y], Trap[i][trap_rot_z]);

            printf("loaded a trap with id %i", Trap[i][trap_id]);
        }

    }

    printf("* [TRAP]: Loaded %d traps\n", rows) ;

    return true ;
}

GetFreeTrapID ( ) {

    for ( new i = 0; i < MAX_TRAPS; i ++) {

        if(Trap[i][trap_id] == INVALID_TRAP_ID) {
            return i;
        }
        else continue;
    }
    return INVALID_TRAP_ID;
}