#define MAX_BODY_PARTS  ( 2 ) // start at 3, end at 9

#define DAMAGE_LEGS     ( 0 )
#define DAMAGE_ARMS     ( 1 )

new bool: PlayerDamage [ MAX_PLAYERS ] [ MAX_BODY_PARTS ] ;
new bool: player_damaged_leg[ MAX_PLAYERS ];
new bool: antiReFall [ MAX_PLAYERS ];

new player_leg_tick [ MAX_PLAYERS ];

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

DamageLegs ( playerid ) {

    if ( ! PlayerDamage [ playerid ] [ DAMAGE_LEGS ] ) {

        PlayerDamage [ playerid ] [ DAMAGE_LEGS ] = true ;
        SendServerMessage ( playerid, "Your legs have been injured. You may experience trouble walking.", MSG_TYPE_INFO ) ;

        SendModeratorWarning ( sprintf("[DMG] (%d) %s's legs have been injured.", playerid, ReturnUserName ( playerid, true ) ), MOD_WARNING_LOW ) ;

        defer LegDamageHandler(playerid);
        return true ;
    }

    return true ;
}

HandleExplosion ( playerid, Float: x, Float: y, Float: z ) {

    new Float: yds = GetPlayerDistanceFromPoint ( playerid, x, y, z ) ;

    if ( yds < 5.0 ) {

        Character [ playerid ] [ character_health ] -= 100.0 ;
        SetCharacterHealth ( playerid, Character [ playerid ] [ character_health ] ) ;
        ToggleDeathMode ( playerid, INVALID_PLAYER_ID ) ;
    }

    else if ( yds >= 5.0 && yds < 10.0 ) {

        Character [ playerid ] [ character_health ] -= 75.0 ;
        SetCharacterHealth ( playerid, Character [ playerid ] [ character_health ] ) ;
        if ( Character [ playerid ] [ character_health ] <= 0.0 ) { ToggleDeathMode ( playerid, INVALID_PLAYER_ID ) ; }

    }

    else if ( yds >= 10.0 && yds < 15.0 ) {

        Character [ playerid ] [ character_health ] -= 50.0 ;
        SetCharacterHealth ( playerid, Character [ playerid ] [ character_health ] ) ;
        if ( Character [ playerid ] [ character_health ] <= 0.0 ) { ToggleDeathMode ( playerid, INVALID_PLAYER_ID ) ; }

    }

    else if ( yds >= 15.0 && yds < 25.0 ) {

        Character [ playerid ] [ character_health ] -= 25.0 ;
        SetCharacterHealth ( playerid, Character [ playerid ] [ character_health ] ) ;
        if ( Character [ playerid ] [ character_health ] <= 0.0 ) { ToggleDeathMode ( playerid, INVALID_PLAYER_ID ) ; }

    }
}

public OnPlayerKeyStateChange (playerid, newkeys, oldkeys) {

    if ( HOLDING ( KEY_SPRINT ) && IsPlayerRunning ( playerid ) && !IsPlayerRidingHorse [ playerid ] ) {

        if ( PlayerDamage [ playerid ] [ DAMAGE_LEGS ] ) {

            player_damaged_leg [ playerid ] = true ;
        }
    }

    if ( newkeys & KEY_JUMP && PlayerDamage [ playerid ] [ DAMAGE_LEGS ] && !IsPlayerRidingHorse [ playerid ] ) {
        
        return ApplyAnimation(playerid, "GYMNASIUM", "gym_jog_falloff", 4.1, 0, 1, 1, 0, 0);
    }
    
    #if defined legs_OnPlayerKeyStateChange
        return legs_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif

#define OnPlayerKeyStateChange legs_OnPlayerKeyStateChange
#if defined legs_OnPlayerKeyStateChange
    forward legs_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

timer LegDamageHandler[1000](playerid) {

////    print("LegDamageHandler timer called (injuries.pwn)");

    if ( IsPlayerRidingHorse [ playerid ] ) {
        defer LegDamageHandler(playerid);
        return false ;
    }

    if ( PlayerDamage [ playerid ] [ DAMAGE_LEGS ] ) {

        if( player_damaged_leg [ playerid ] && IsPlayerRunning(playerid) ) {

            if( ++ player_leg_tick [playerid] >= 3) {

                antiReFall [ playerid ] = false ;
                player_leg_tick [ playerid ] = 0 ;
            }

            if ( ! IsPlayerRunning ( playerid ) ) {

                player_damaged_leg [ playerid ] = false;
                player_leg_tick [ playerid ] = 0 ;
            }

            if ( !antiReFall [ playerid ] ) {

                antiReFall [ playerid ] = true ;
                ApplyAnimation(playerid, "ped", "fall_collapse", 4.1, 0, 1, 1, 0, 0, 1);

            }
        }

        defer LegDamageHandler(playerid);
        return true ;
    }

    else return false ;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


IsPlayerRunning ( playerid ) {
    new keys, ud, lr ;
    GetPlayerKeys ( playerid, keys, ud, lr ) ;

    if ( keys & KEY_WALK )
        return false ;

    if ( ud == 0 && lr == 0 )
        return false ;

    return true ;
}

IsPlayerFalling ( playerid ) {
    new index = GetPlayerAnimationIndex ( playerid ) ;

    if ( index >= 958 && index <= 979 || index == 1130 || index == 1195 || index == 1132 ) return true ;

    return false ;
}