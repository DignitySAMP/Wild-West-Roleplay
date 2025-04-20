/*

    TO DO LIST:

    Reduce the spam (add one lines, don't clear chat, etc).
    Remove the "information" textdraws. Make it a cmd instead: /pokertableinfo (pti).
    Redesign the "choices" textdraws - add the ww-rp colors.
    Add logging to everything.
    Remove the excess SF-CNR code and replace it with WW-RP stuff (as long as it works)

*/


#tryinclude <a_samp>
#tryinclude <sscanf2>
#tryinclude <streamer>
#tryinclude <strlib>
#tryinclude <zcmd>


#tryinclude <YSI\y_va>
#tryinclude <YSI\y_iterate>
#tryinclude <YSI\y_dialog>
#tryinclude <YSI\y_hooks>
#tryinclude <YSI\foreach>

#define COL_GREY                    "{C0C0C0}"
#define COL_WHITE                   "{FFFFFF}"

#define strmatch(%1,%2)                     (!strcmp(%1,%2,true))


#define cash_format(%0) \
    (number_format(%0, .prefix = '$'))

#define ITER_NONE (cellmin)

#define HOLDING(%0)                         ((newkeys & (%0)) == (%0))
#define PRESSED(%0)                         (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
    
#include "games/poker/poker.pwn"


/* ** Functions ** */


// purpose: convert integer into dollar string (large credit to Slice - i just added a prefix parameter)
stock number_format( { _, Float, Text3D, Menu, Text, DB, DBResult, bool, File }: variable, prefix = '\0', decimals = -1, thousand_seperator = ',', decimal_point = '.', tag = tagof( variable ) )
{
    static
        s_szReturn[ 32 ],
        s_szThousandSeparator[ 2 ] = { ' ', EOS },
        s_iDecimalPos,
        s_iChar,
        s_iSepPos
    ;

    if ( tag == tagof( bool: ) )
    {
        if ( variable )
            memcpy( s_szReturn, "true", 0, 5 * ( cellbits / 8 ) );
        else
            memcpy( s_szReturn, "false", 0, 6 * ( cellbits / 8 ) );

        return s_szReturn;
    }
    else if ( tag == tagof( Float: ) )
    {
        if ( decimals == -1 )
            decimals = 8;

        format( s_szReturn, sizeof( s_szReturn ), "%.*f", decimals, variable );
    }
    else
    {
        format( s_szReturn, sizeof( s_szReturn ), "%d", variable );

        if ( decimals > 0 )
        {
            strcat( s_szReturn, "." );

            while ( decimals-- )
                strcat( s_szReturn, "0" );
        }
    }

    s_iDecimalPos = strfind( s_szReturn, "." );

    if ( s_iDecimalPos == -1 )
        s_iDecimalPos = strlen( s_szReturn );
    else
        s_szReturn[ s_iDecimalPos ] = decimal_point;

    if ( s_iDecimalPos >= 4 && thousand_seperator )
    {
        s_szThousandSeparator[ 0 ] = thousand_seperator;

        s_iChar = s_iDecimalPos;
        s_iSepPos = 0;

        while ( --s_iChar > 0 )
        {
            if ( ++s_iSepPos == 3 && s_szReturn[ s_iChar - 1 ] != '-' )
            {
                strins( s_szReturn, s_szThousandSeparator, s_iChar );

                s_iSepPos = 0;
            }
        }
    }

    if ( prefix != '\0' )
    {
        static
            prefix_string[ 2 ];

        prefix_string[ 0 ] = prefix;
        strins( s_szReturn, prefix_string, s_szReturn[ 0 ] == '-' ); // no point finding -
    }
    return s_szReturn;
}

#define cash_format(%0) \
    (number_format(%0, .prefix = '$'))

// purpose: find a random element in sample space, excluding [a, b, c, ...]
stock randomExcept( except[ ], len = sizeof( except ), available_element_value = -1 ) {

    new bool: any_available_elements = false;

    // we will check if there are any elements that are not in except[]
    for ( new x = 0; x < len; x ++ ) if ( except[ x ] == available_element_value ) {
        any_available_elements = true;
        break;
    }

    // if all elements are included in except[], prevent continuing otherwise it will infinite loop
    if ( ! any_available_elements ) {
        return -1;
    }

    new random_number = random( len );

    // use recursion to find another element
    for ( new x = 0; x < len; x ++ ) {
        if ( random_number == except[ x ] ) {
            return randomExcept( except, len );
        }
    }
    return random_number;
}

// purpose: generate a random string up to a length
stock randomString( strDest[ ], strLen = 10 ) {
    while ( strLen -- )  {
        strDest[ strLen ] = random( 2 ) ? ( random( 26 ) + ( random( 2 ) ? 'a' : 'A' ) ) : ( random( 10 ) + '0' );
    }
}

// purpose: get unattached player object index
stock Player_GetUnusedAttachIndex( playerid )
{
    for ( new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i ++ )
        if ( ! IsPlayerAttachedObjectSlotUsed( playerid, i ) )
            return i;

    return cellmin;
}
