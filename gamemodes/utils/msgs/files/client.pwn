#define MSG_TYPE_INFO	( 0 )
#define MSG_TYPE_WARN	( 1 )
#define MSG_TYPE_ERROR  ( 2 )

SendServerMessage ( playerid, string [], type ) {

    new text[128*2];
	switch ( type ) {

		case MSG_TYPE_INFO: {

            format(text,sizeof(text),"Info:{dedede} %s",string);
            return SendSplitMessage(playerid,0x92C742FF,text);
			//return SendClientMessageFormatted ( playerid, 0x92C742FF, "Info:{dedede} %s", string); // 0x92C742FF - olive
		}

		case MSG_TYPE_WARN: {

            format(text,sizeof(text),"Warning:{dedede} %s",string);
            return SendSplitMessage(playerid,COLOR_YELLOW,text);
			//return SendClientMessageFormatted ( playerid, COLOR_YELLOW, "Warning:{dedede} %s", string); 
		}

        case MSG_TYPE_ERROR: {

            format(text,sizeof(text),"Error:{dedede} %s",string);
            return SendSplitMessage(playerid,COLOR_RED,text);
            //return SendClientMessageFormatted ( playerid, COLOR_RED, "Error:{dedede} %s", string ) ;
        }
	}

	return true ;
}
/*
#define BYTES_PER_CELL		( 4 )

stock SendClientMessageFormatted(playerid, color, fstring[], {Float, _}:...) {
    static const STATIC_ARGS = 3 ;
    new n = (numargs() - STATIC_ARGS) * BYTES_PER_CELL ;

    if ( n ) {
        new message[256], arg_start ,arg_end ;

        #emit CONST.alt        	fstring
        #emit LCTRL          	5
        #emit ADD
        #emit STOR.S.pri        arg_start

        #emit LOAD.S.alt        n
        #emit ADD
        #emit STOR.S.pri        arg_end

        do {
            #emit LOAD.I
            #emit PUSH.pri
            arg_end -= BYTES_PER_CELL;
            #emit LOAD.S.pri 	arg_end
        }

        while ( arg_end > arg_start ) ;

        #emit PUSH.S          	fstring
        #emit PUSH.C          	256
        #emit PUSH.ADR        	message

        n += BYTES_PER_CELL * 3;

        #emit PUSH.S          	n
        #emit SYSREQ.C        	format

        n += BYTES_PER_CELL;
        #emit LCTRL          	4
        #emit LOAD.S.alt 		n
        #emit ADD
        #emit SCTRL         	4

        if ( playerid == INVALID_PLAYER_ID ) {
            #pragma unused playerid
            return SendClientMessageToAll ( color, message ) ;
        } 

        else {
            return SendClientMessage ( playerid, color, message ) ;
        }
    } 
    else {
        if ( playerid == INVALID_PLAYER_ID ) {
            #pragma unused playerid
            return SendClientMessageToAll ( color, fstring ) ;
        } 

        else {
            return SendClientMessage ( playerid, color, fstring ) ;
        }
    }
}
*/
stock SendClientMessageFormatted( playerid, colour, const format[ ], va_args<> )
{
    static
        out[ 144 ];

    va_format( out, sizeof( out ), format, va_start<3> );

    if ( playerid == INVALID_PLAYER_ID ) {
        return SendClientMessageToAll( colour, out );
    } else {
        return SendClientMessage( playerid, colour, out );
    }
}