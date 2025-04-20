#if defined _inc_main
	#undef _inc_main
#endif

#include "aris/traps/data.pwn"
#include "aris/traps/func.pwn"
#include "aris/traps/utils.pwn"

new ReturnTrapCount = 0;

public OnGameModeInit() {

	//AddSimpleModel(0, 1923, -2000, "traps/footlock.dff", "traps/footlock.txd");

    for(new i; i < MAX_TRAPS; i++){
        Trap[i][trap_id] = INVALID_TRAP_ID;
    }

	#if defined trap_OnGameModeInit
		return trap_OnGameModeInit();
	#else
		return 1;
	#endif
}

#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif

#define OnGameModeInit trap_OnGameModeInit
#if defined trap_OnGameModeInit
	forward trap_OnGameModeInit();
#endif






