/**
 *           __             __
 *          |  \           |  |
 *      ____| $$  ______  _| $$_     ______
 *     /      $$ |      \|   $$ \   |      |
 *    |  $$$$$$$  \$$$$$$\\$$$$$$    \$$$$$$|
 *    | $$  | $$ /      $$ | $$ __  /      $$
 *    | $$__| $$|  $$$$$$$ | $$|  \|  $$$$$$$
 *     \$$    $$ \$$    $$  \$$  $$ \$$    $$
 *      \$$$$$$$  \$$$$$$$   \$$$$   \$$$$$$$
 *
 */
#define HORSE_OBJECT_COW (19833)
#define HORSE_ATTACH_SLOT (6)
#define HORSE_MOUNT_COOLDOWN (5000)
#define HORSE_STEP_MS (800)
#define HORSE_CALL_SOUND_MS (2000)
#define HORSE_CALL_SPAWN_MS (3000)
#define HORSE_TICK_MS (10)
#define HORSE_MOVE_MS (40)
#define HORSE_FRAME_FAST_MS (50)
#define HORSE_FRAME_IDLE_MS (75)
#define HORSE_RELOAD_TICKS (100)
#define HORSE_NOISE_TICKS (200)
#define HORSE_MOUNT_RANGE (2.5)
#define HORSE_POINT_RANGE (1.0)
#define HORSE_STREAM_RANGE (250.0)
#define HORSE_VELOCITY_NORM (0.15)
#define HORSE_VELOCITY_BACK (0.05)
#define HORSE_VELOCITY_WALK (0.75)
#define HORSE_VELOCITY_GALLOP (2.0)
#define HORSE_TURN (6.0)

enum
{
    HORSE_SOUND_GALLOP,
    HORSE_SOUND_SNORT,
    HORSE_SOUND_WHINE,
    HORSE_SOUND_SPAWN,
    HORSE_SOUND_WHISTLE
}

static const s_HorseSoundFiles[5][] =
{
    "horse/horse_running.mp3",
    "horse/horse_snort.wav",
    "horse/horse_whine.mp3",
    "horse/horse_spawn.wav",
    "horse/horse_whistle.wav"
};

static bool:s_HorseSpawned[MAX_PLAYERS];
static bool:s_HorseRiding[MAX_PLAYERS];
static bool:s_HorseBusy[MAX_PLAYERS];
static s_HorseCoat[MAX_PLAYERS];
static STREAMER_TAG_OBJECT:s_HorseObject[MAX_PLAYERS];
static STREAMER_TAG_CP:s_HorseCp[MAX_PLAYERS][2];
static Float:s_HorsePos[MAX_PLAYERS][4];
static s_HorseTicket[MAX_PLAYERS];
static s_HorseMountTick[MAX_PLAYERS];
static s_HorseMountDirection[MAX_PLAYERS];
static Float:s_HorseStamina[MAX_PLAYERS];
static bool:s_HorseAbleToSprint[MAX_PLAYERS];
static s_HorseReloadTick[MAX_PLAYERS];
static s_HorseNoiseTick[MAX_PLAYERS];
static bool:s_HorseNoiseFlip[MAX_PLAYERS];
static bool:s_HorsePlayingSound[MAX_PLAYERS];
static bool:s_HorseSoundOn[MAX_PLAYERS] = {true,...};
static bool:s_HorseHudOff[MAX_PLAYERS];
static s_HorseFrame[MAX_PLAYERS];
static s_HorseFrameSet[MAX_PLAYERS];
static s_HorseModel[MAX_PLAYERS];
static s_HorseMoveDue[MAX_PLAYERS];
static s_HorseFrameDue[MAX_PLAYERS];
static Float:s_HorseSpeed[MAX_PLAYERS];
static Float:s_HorseHeading[MAX_PLAYERS];
static s_HorseRiders;

static const Float:s_HorseOffsets[5][6] =
{
    {0.0,0.0,0.0,0.0,0.0,0.0},
    {-0.480000,0.447999,-0.017999,-92.400009,13.200000,1.000000},
    {-0.441000,0.323999,0.000000,-91.499946,16.799995,0.000000},
    {-0.441000,0.323999,0.000000,-91.499946,16.799995,0.000000},
    {-0.479000,0.273000,0.000000,-179.600082,-2.499999,19.500005}
};

forward bool:Horse_ForceDismount(playerid);
forward Horse_MountDeferred(playerid,ticket);
forward Horse_DismountDeferred(playerid,ticket);
forward Horse_CallDeferred(playerid,ticket);
forward Horse_OnMounted(playerid);
forward Horse_OnDismounted(playerid);

/**
 *      ______                                   __      __
 *     /      \                                 |  \    |  |
 *    |  $$$$$$\ __    __  _______    _______  _| $$_    \$$  ______   _______    _______
 *    | $$_  \$$|  \  |  \|       \  /       \|   $$ \  |  \ /      \ |       \  /       |
 *    | $$ \    | $$  | $$| $$$$$$$\|  $$$$$$$ \$$$$$$  | $$|  $$$$$$\| $$$$$$$\|  $$$$$$$
 *    | $$$$    | $$  | $$| $$  | $$| $$        | $$ __ | $$| $$  | $$| $$  | $$ \$$    |
 *    | $$      | $$__/ $$| $$  | $$| $$_____   | $$|  \| $$| $$__/ $$| $$  | $$ _\$$$$$$|
 *    | $$       \$$    $$| $$  | $$ \$$     \   \$$  $$| $$ \$$    $$| $$  | $$|       $$
 *     \$$        \$$$$$$  \$$   \$$  \$$$$$$$    \$$$$  \$$  \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
stock bool:Horse_IsSpawned(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_HorseSpawned[playerid];
}

stock bool:Horse_IsRiding(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_HorseRiding[playerid];
}

stock Float:Horse_GetStamina(playerid)
{
    return s_HorseStamina[playerid];
}

stock Float:Horse_GetSpeed(playerid)
{
    return s_HorseSpeed[playerid];
}

stock Float:Horse_GetHeading(playerid)
{
    return s_HorseHeading[playerid];
}

stock Horse_SetStamina(playerid,Float:value)
{
    s_HorseStamina[playerid] = value;
}

stock bool:Horse_CanSprint(playerid)
{
    return s_HorseAbleToSprint[playerid];
}

stock bool:Horse_IsSoundOn(playerid)
{
    return s_HorseSoundOn[playerid];
}

stock bool:Horse_IsHudHidden(playerid)
{
    return s_HorseHudOff[playerid];
}

stock Horse_GetCoat(playerid)
{
    return s_HorseCoat[playerid];
}

stock Horse_GetModel(playerid)
{
    return s_HorseModel[playerid];
}

stock Horse_GetFrameSet(playerid)
{
    return s_HorseFrameSet[playerid];
}

stock Horse_GetObject(playerid)
{
    return _:s_HorseObject[playerid];
}

stock Horse_GetCheckpoint(playerid,index)
{
    return _:s_HorseCp[playerid][index];
}

stock Horse_GetPosition(playerid,&Float:x,&Float:y,&Float:z,&Float:rotation)
{
    x = s_HorsePos[playerid][0];
    y = s_HorsePos[playerid][1];
    z = s_HorsePos[playerid][2];
    rotation = s_HorsePos[playerid][3];
}

stock Horse_GetMountTick(playerid)
{
    return s_HorseMountTick[playerid];
}

stock Horse_SetSoundOn(playerid,bool:on)
{
    s_HorseSoundOn[playerid] = on;
}

stock Horse_SetHudHidden(playerid,bool:hidden)
{
    s_HorseHudOff[playerid] = hidden;
}

stock Horse_SetReloadTick(playerid,value)
{
    s_HorseReloadTick[playerid] = value;
}

static Horse_PlaySound(playerid,sound)
{
    Audio_Play(playerid,s_HorseSoundFiles[sound],0.0,0.0,0.0,5.0,false);
}

static Horse_StopSound(playerid)
{
    Audio_Stop(playerid);
}

static Horse_Offset(Float:rotation,Float:distance,Float:offset,&Float:x,&Float:y)
{
    new Float:angle = rotation + offset;
    x += distance * floatsin(-angle,degrees);
    y += distance * floatcos(-angle,degrees);
}

static Float:Horse_GallopSpeed(playerid)
{
    new type = Horse_GetType(playerid);

    if (type == HORSE_COW)
    {
        type = 5;
    }

    return HORSE_VELOCITY_GALLOP + (float(type) * 0.015);
}

static Horse_DestroyCheckpoints(playerid)
{
    for (new i = 0;i < 2;i++)
    {
        if (_:s_HorseCp[playerid][i] != INVALID_STREAMER_ID)
        {
            DestroyDynamicCP(s_HorseCp[playerid][i]);
            s_HorseCp[playerid][i] = STREAMER_TAG_CP:INVALID_STREAMER_ID;
        }
    }
}

static Horse_DestroyObject(playerid)
{
    if (_:s_HorseObject[playerid] != INVALID_STREAMER_ID)
    {
        DestroyDynamicObject(s_HorseObject[playerid]);
        s_HorseObject[playerid] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
    }
}

static Horse_CreateCheckpoints(playerid)
{
    Horse_DestroyCheckpoints(playerid);
    new Float:leftX = s_HorsePos[playerid][0], Float:leftY = s_HorsePos[playerid][1], Float:rightX = s_HorsePos[playerid][0], Float:rightY = s_HorsePos[playerid][1], Float:z;
    new Float:rotation = s_HorsePos[playerid][3];
    GetPlayerPos(playerid,z,z,z);

    if (Horse_IsCow(playerid))
    {
        Horse_Offset(rotation,1.0,90.0,leftX,leftY);
        Horse_Offset(rotation,1.0,270.0,rightX,rightY);
    }
    else
    {
        Horse_Offset(rotation,1.0,180.0,leftX,leftY);
        Horse_Offset(rotation,1.0,0.0,rightX,rightY);
    }

    s_HorseCp[playerid][0] = CreateDynamicCP(leftX,leftY,z,1.0,-1,-1,playerid,2.5);
    s_HorseCp[playerid][1] = CreateDynamicCP(rightX,rightY,z,1.0,-1,-1,playerid,2.5);
}

static Horse_PlaceObject(playerid,Float:x,Float:y,Float:z,Float:angle)
{
    Horse_DestroyObject(playerid);

    if (Horse_IsCow(playerid))
    {
        s_HorsePos[playerid][0] = x;
        s_HorsePos[playerid][1] = y;
        s_HorsePos[playerid][2] = z - 1.2;
        s_HorsePos[playerid][3] = angle;
        s_HorseObject[playerid] = CreateDynamicObject(HORSE_OBJECT_COW,x,y,z - 1.2,0.0,0.0,angle,-1,-1,-1,HORSE_STREAM_RANGE);
    }
    else
    {
        s_HorsePos[playerid][0] = x;
        s_HorsePos[playerid][1] = y;
        s_HorsePos[playerid][2] = z - 0.2;
        s_HorsePos[playerid][3] = angle + 270.0;
        s_HorseObject[playerid] = CreateDynamicObject(HORSE_IDLE_INDEX + (HORSE_IDLE_FRAMES * s_HorseCoat[playerid]),x,y,z - 0.2,0.0,-90.0,angle + 270.0,-1,-1,-1,HORSE_STREAM_RANGE);
    }

    Streamer_Update(playerid,STREAMER_TYPE_OBJECT);
}

static Horse_Say(playerid,const text[])
{
    new rp[ACCOUNT_NAME_LEN], line[128], kind[8];
    Account_GetRoleplayName(playerid,rp);
    strcopy(kind,Horse_IsCow(playerid) ? ("cow") : ("horse"));
    format(line,sizeof(line),text,rp,kind);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
}

static Horse_UpdateHud(playerid)
{
    if (s_HorseHudOff[playerid])
    {
        return;
    }

    Hud_SetHorse(playerid,s_HorseStamina[playerid],Horse_GetHealth(playerid));
}

stock Horse_ShowHud(playerid)
{
    Hud_SetHorse(playerid,s_HorseStamina[playerid],Horse_GetHealth(playerid));
}

stock Horse_HideHud(playerid)
{
    Hud_HideHorse(playerid);
}

stock Horse_Cleanup(playerid)
{
    if (s_HorseRiding[playerid])
    {
        s_HorseRiders--;
    }

    s_HorseTicket[playerid]++;
    s_HorseSpawned[playerid] = false;
    s_HorseRiding[playerid] = false;
    s_HorseBusy[playerid] = false;
    s_HorseCoat[playerid] = 0;
    s_HorseModel[playerid] = 0;
    s_HorseStamina[playerid] = 100.0;
    s_HorseAbleToSprint[playerid] = true;
    s_HorseReloadTick[playerid] = 0;
    s_HorseNoiseTick[playerid] = 0;
    s_HorseMountTick[playerid] = 0;
    s_HorsePlayingSound[playerid] = false;
    s_HorseHudOff[playerid] = false;
    s_HorseSoundOn[playerid] = true;
    s_HorseFrame[playerid] = 0;
    s_HorseFrameSet[playerid] = 0;
    Horse_DestroyObject(playerid);
    Horse_DestroyCheckpoints(playerid);

    if (IsPlayerConnected(playerid))
    {
        Horse_HideHud(playerid);
    }
}

static bool:Horse_InOpen(playerid)
{
    return GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0;
}

stock Horse_SetHealth(playerid,Float:health,issuerid = INVALID_PLAYER_ID)
{
    Horse_SetStoredHealth(playerid,health);
    Horse_SaveHealth(playerid);

    if (s_HorseRiding[playerid])
    {
        Horse_UpdateHud(playerid);
    }

    if (Horse_GetHealth(playerid) > 0.0)
    {
        return;
    }

    Horse_DestroyCheckpoints(playerid);
    new line[128];

    if (issuerid != INVALID_PLAYER_ID && IsPlayerConnected(issuerid))
    {
        new name[ACCOUNT_NAME_LEN];
        Account_GetRoleplayName(issuerid,name);
        format(line,sizeof(line),"Your horse has been killed by (%d) %s. It will respawn soon.",issuerid,name);
    }
    else
    {
        strcopy(line,"Your horse has been killed. It will respawn soon.");
    }

    SendServerMessage(playerid,line,MSG_TYPE_ERROR);

    if (s_HorseRiding[playerid])
    {
        Horse_ForceDismount(playerid);
        new Float:x, Float:y, Float:z, Float:rotation;
        Horse_GetPosition(playerid,x,y,z,rotation);
        SetPlayerPos(playerid,x,y,z + 1.25);
        ApplyAnimation(playerid,"PED","KO_SHOT_STOM",4.1,false,true,true,true,0,SYNC_ALL);
    }

    if (_:s_HorseObject[playerid] != INVALID_STREAMER_ID)
    {
        new Float:x, Float:y, Float:z;
        GetDynamicObjectPos(s_HorseObject[playerid],x,y,z);
        SetDynamicObjectRot(s_HorseObject[playerid],0.0,90.0,0.0);
        SetDynamicObjectPos(s_HorseObject[playerid],x,y,z);
    }
}

stock bool:Horse_ForceDismount(playerid)
{
    if (!s_HorseRiding[playerid] && !s_HorseBusy[playerid])
    {
        return false;
    }

    s_HorseTicket[playerid]++;
    new bool:wasRiding = s_HorseRiding[playerid];

    if (wasRiding)
    {
        s_HorseRiders--;
    }

    s_HorseRiding[playerid] = false;
    s_HorseBusy[playerid] = false;
    Player_SetBusy(playerid,E_PLAYER_BUSY_HORSE,false);
    RemovePlayerAttachedObject(playerid,HORSE_ATTACH_SLOT);
    SetPlayerVelocity(playerid,0.0,0.0,0.0);
    ClearAnimations(playerid,SYNC_ALL);
    Horse_StopSound(playerid);
    s_HorsePlayingSound[playerid] = false;
    Horse_HideHud(playerid);

    if (wasRiding && s_HorseSpawned[playerid])
    {
        new Float:x, Float:y, Float:z, Float:angle;
        GetPlayerPos(playerid,x,y,z);
        GetPlayerFacingAngle(playerid,angle);
        Horse_Offset(angle,1.0,s_HorseMountDirection[playerid] == 0 ? 90.0 : 270.0,x,y);
        Horse_PlaceObject(playerid,x,y,z,angle);
        Horse_CreateCheckpoints(playerid);
    }

    return wasRiding;
}

stock Horse_Despawn(playerid)
{
    s_HorseTicket[playerid]++;

    if (s_HorseRiding[playerid])
    {
        Horse_ForceDismount(playerid);
    }

    Horse_DestroyCheckpoints(playerid);
    Horse_DestroyObject(playerid);
    s_HorseSpawned[playerid] = false;
}

stock bool:Horse_Spawn(playerid)
{
    if (!Horse_HasHorse(playerid))
    {
        SendServerMessage(playerid,"You don't have a horse.",MSG_TYPE_ERROR);
        return false;
    }

    if (Horse_GetHealth(playerid) <= 0.0)
    {
        SendServerMessage(playerid,"Your horse is dead. Go to a stablemaster and /revive it.",MSG_TYPE_ERROR);
        return false;
    }

    if (s_HorseSpawned[playerid])
    {
        SendServerMessage(playerid,"You already have a horse spawned. Use /respawnhorse to despawn it.",MSG_TYPE_ERROR);
        return false;
    }

    if (!Player_IsFree(playerid))
    {
        SendServerMessage(playerid,"You can't spawn your horse right now.",MSG_TYPE_ERROR);
        return false;
    }

    if (!Horse_InOpen(playerid))
    {
        SendServerMessage(playerid,"You can only spawn a horse outside.",MSG_TYPE_ERROR);
        return false;
    }

    new type = Horse_GetType(playerid);

    if (type == 0 || type == 4 || type == 5)
    {
        SendServerMessage(playerid,"Your horse ID has been temporarily disabled due to a bug. You've been given a free (expensive) replacement!",MSG_TYPE_WARN);
        Horse_SetType(playerid,3);
    }

    SendServerMessage(playerid,"You've called your horse. It should be here soon.",MSG_TYPE_INFO);
    Horse_PlaySound(playerid,HORSE_SOUND_WHISTLE);
    s_HorseSpawned[playerid] = true;
    s_HorseTicket[playerid]++;
    SetTimerEx("Horse_CallDeferred",0,false,"dd",playerid,s_HorseTicket[playerid]);
    return true;
}

static Horse_CallFlow(playerid,ticket)
{
    yield 1;
    await task_ms(HORSE_CALL_SOUND_MS);

    if (!IsPlayerConnected(playerid) || ticket != s_HorseTicket[playerid] || !s_HorseSpawned[playerid])
    {
        return;
    }

    Horse_PlaySound(playerid,HORSE_SOUND_SPAWN);
    await task_ms(HORSE_CALL_SPAWN_MS);

    if (!IsPlayerConnected(playerid) || ticket != s_HorseTicket[playerid] || !s_HorseSpawned[playerid])
    {
        return;
    }

    if (!Horse_InOpen(playerid))
    {
        s_HorseSpawned[playerid] = false;
        SendServerMessage(playerid,"You can only spawn a horse outside.",MSG_TYPE_ERROR);
        return;
    }

    new Float:x, Float:y, Float:z, Float:angle;
    s_HorseCoat[playerid] = Horse_IsCow(playerid) ? 0 : Horse_GetType(playerid);
    GetPlayerPos(playerid,x,y,z);
    GetPlayerFacingAngle(playerid,angle);
    Horse_Offset(angle,1.0,-90.0,x,y);
    Horse_PlaceObject(playerid,x,y,z,angle);
    Horse_CreateCheckpoints(playerid);

    if (Horse_IsCow(playerid))
    {
        SendServerMessage(playerid,"Your cow has spawned near your location. Press ~k~~VEHICLE_ENTER_EXIT~ to mount it. To toggle hud, use /toghorsetds.",MSG_TYPE_INFO);
    }
    else
    {
        SendServerMessage(playerid,"Your horse has spawned near your location. Press ~k~~VEHICLE_ENTER_EXIT~ to mount it. To toggle hud, use /toghorsetds.",MSG_TYPE_INFO);
    }
}

public Horse_CallDeferred(playerid,ticket)
{
    Horse_CallFlow(playerid,ticket);
    return 1;
}

static Horse_MountCooldown(playerid)
{
    new left = HORSE_MOUNT_COOLDOWN - (GetTickCount() - s_HorseMountTick[playerid]);

    if (left > 0)
    {
        new line[128];
        format(line,sizeof(line),"Please don't spam the horse mounting function. You're on a %0.2f second cooldown.",float(left) / 1000.0);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return false;
    }

    return true;
}

stock bool:Horse_TryMount(playerid)
{
    if (!s_HorseSpawned[playerid] || _:s_HorseObject[playerid] == INVALID_STREAMER_ID || s_HorseBusy[playerid])
    {
        return false;
    }

    if (!IsPlayerInRangeOfPoint(playerid,HORSE_MOUNT_RANGE,s_HorsePos[playerid][0],s_HorsePos[playerid][1],s_HorsePos[playerid][2]))
    {
        return false;
    }

    if (!Horse_MountCooldown(playerid))
    {
        return false;
    }

    if (Horse_GetHealth(playerid) <= 0.0)
    {
        SendServerMessage(playerid,"Your horse is dead. Go to a stablemaster to revive it.",MSG_TYPE_ERROR);
        return false;
    }

    if (Weapons_Get(playerid,E_GUN_SLOT_HAND) != 0)
    {
        SendServerMessage(playerid,"You need to holster your weapon before you can mount your horse.",MSG_TYPE_ERROR);
        return false;
    }

    if (!Horse_InOpen(playerid))
    {
        SendServerMessage(playerid,"You can only spawn a horse outside.",MSG_TYPE_ERROR);
        return false;
    }

    new Float:rotation = s_HorsePos[playerid][3], Float:ax = s_HorsePos[playerid][0], Float:ay = s_HorsePos[playerid][1], Float:bx = s_HorsePos[playerid][0], Float:by = s_HorsePos[playerid][1], Float:z = s_HorsePos[playerid][2];
    Horse_Offset(rotation,1.0,0.0,ax,ay);
    Horse_Offset(rotation,1.0,180.0,bx,by);

    if (IsPlayerInRangeOfPoint(playerid,HORSE_POINT_RANGE,ax,ay,z))
    {
        ApplyAnimation(playerid,"BIKED","BIKEd_jumponL",4.1,false,false,false,true,0,SYNC_ALL);
        s_HorseMountDirection[playerid] = 0;
    }
    else if (IsPlayerInRangeOfPoint(playerid,HORSE_POINT_RANGE,bx,by,z))
    {
        ApplyAnimation(playerid,"BIKED","BIKEd_jumponR",4.1,false,false,false,true,0,SYNC_ALL);
        s_HorseMountDirection[playerid] = 1;
    }
    else
    {
        return false;
    }

    s_HorseMountTick[playerid] = GetTickCount();
    s_HorseBusy[playerid] = true;
    SetPlayerFacingAngle(playerid,rotation);
    Inventory_Unequip(playerid,false);
    RemovePlayerAttachedObject(playerid,HORSE_ATTACH_SLOT);
    s_HorseTicket[playerid]++;
    SetTimerEx("Horse_MountDeferred",0,false,"dd",playerid,s_HorseTicket[playerid]);
    return true;
}

static Horse_MountModel(playerid)
{
    if (Horse_IsCow(playerid))
    {
        return HORSE_OBJECT_COW;
    }

    return HORSE_IDLE_INDEX + (HORSE_IDLE_FRAMES * s_HorseCoat[playerid]);
}

static Horse_MountFlow(playerid,ticket)
{
    yield 1;
    await task_ms(HORSE_STEP_MS);

    if (!IsPlayerConnected(playerid) || ticket != s_HorseTicket[playerid] || !s_HorseBusy[playerid] || !s_HorseSpawned[playerid])
    {
        return;
    }

    if (!Horse_InOpen(playerid))
    {
        s_HorseBusy[playerid] = false;
        ClearAnimations(playerid,SYNC_ALL);
        SendServerMessage(playerid,"You can only spawn a horse outside.",MSG_TYPE_ERROR);
        return;
    }

    Horse_DestroyObject(playerid);
    Horse_DestroyCheckpoints(playerid);
    ApplyAnimation(playerid,"BIKED","BIKEd_Ride",4.0,true,true,true,true,0,SYNC_ALL);
    Injury_RefreshClient(playerid);
    s_HorseModel[playerid] = Horse_MountModel(playerid);
    SetPlayerAttachedObject(playerid,HORSE_ATTACH_SLOT,s_HorseModel[playerid],1,-1.64,0.540,-0.010,92.7,73.8,88.4,1.0,1.0,1.25);
    s_HorseStamina[playerid] = 100.0;
    s_HorseAbleToSprint[playerid] = true;
    s_HorseReloadTick[playerid] = 0;
    s_HorseFrame[playerid] = 0;
    s_HorseFrameSet[playerid] = 0;
    s_HorseBusy[playerid] = false;
    s_HorseRiding[playerid] = true;
    s_HorseRiders++;
    s_HorseMoveDue[playerid] = 0;
    s_HorseFrameDue[playerid] = GetTickCount() + 100;
    Player_SetBusy(playerid,E_PLAYER_BUSY_HORSE,true);
    Horse_ShowHud(playerid);

    if (s_HorseHudOff[playerid])
    {
        Horse_HideHud(playerid);
    }

    SendServerMessage(playerid,"If you have lag, use /audiomsg to hide the audio messages or use /nohorsesound to disable horse noises.",MSG_TYPE_INFO);
    SendServerMessage(playerid,"If your sitting animation is bugged, use /resynchorse to resync it.",MSG_TYPE_WARN);
    Horse_Say(playerid,"* %s has mounted their %s.");
    pawn_call_public("Horse_OnMounted","d",playerid);
}

public Horse_MountDeferred(playerid,ticket)
{
    Horse_MountFlow(playerid,ticket);
    return 1;
}

stock bool:Horse_TryDismount(playerid)
{
    if (!s_HorseRiding[playerid])
    {
        return false;
    }

    if (!Horse_MountCooldown(playerid))
    {
        return false;
    }

    s_HorseMountTick[playerid] = GetTickCount();
    s_HorseRiding[playerid] = false;
    s_HorseRiders--;
    s_HorseBusy[playerid] = true;
    RemovePlayerAttachedObject(playerid,HORSE_ATTACH_SLOT);

    if (s_HorseMountDirection[playerid] == 0)
    {
        ApplyAnimation(playerid,"BIKED","BIKEd_getoffLHS",4.1,false,false,false,true,0,SYNC_ALL);
    }
    else
    {
        ApplyAnimation(playerid,"BIKED","BIKEd_getoffRHS",4.1,false,false,false,true,0,SYNC_ALL);
    }

    s_HorseTicket[playerid]++;
    SetTimerEx("Horse_DismountDeferred",0,false,"dd",playerid,s_HorseTicket[playerid]);
    return true;
}

static Horse_DismountFlow(playerid,ticket)
{
    yield 1;
    await task_ms(HORSE_STEP_MS);

    if (!IsPlayerConnected(playerid) || ticket != s_HorseTicket[playerid] || !s_HorseBusy[playerid] || !s_HorseSpawned[playerid])
    {
        return;
    }

    new Float:x, Float:y, Float:z, Float:angle;
    GetPlayerPos(playerid,x,y,z);
    GetPlayerFacingAngle(playerid,angle);
    Horse_Offset(angle,1.0,s_HorseMountDirection[playerid] == 0 ? 90.0 : 270.0,x,y);
    Horse_PlaceObject(playerid,x,y,z,angle);
    Horse_CreateCheckpoints(playerid);
    Horse_HideHud(playerid);
    Horse_StopSound(playerid);
    s_HorsePlayingSound[playerid] = false;
    Horse_Say(playerid,"* %s has dismounted their %s.");
    ClearAnimations(playerid,SYNC_ALL);
    TogglePlayerControllable(playerid,true);
    s_HorseBusy[playerid] = false;
    Player_SetBusy(playerid,E_PLAYER_BUSY_HORSE,false);
    pawn_call_public("Horse_OnDismounted","d",playerid);
}

public Horse_DismountDeferred(playerid,ticket)
{
    Horse_DismountFlow(playerid,ticket);
    return 1;
}

public Horse_OnMounted(playerid)
{
    return 1;
}

public Horse_OnDismounted(playerid)
{
    return 1;
}

stock Horse_Move(playerid)
{
    new KEY:keys, ud, lr, Float:angle, Float:forward_;
    GetPlayerKeys(playerid,keys,ud,lr);
    GetPlayerFacingAngle(playerid,angle);

    if (++s_HorseReloadTick[playerid] > HORSE_RELOAD_TICKS)
    {
        ApplyAnimation(playerid,"BIKED","BIKEd_Ride",4.0,true,true,true,true,0,SYNC_ALL);
        Injury_RefreshClient(playerid);
        s_HorseReloadTick[playerid] = 0;
    }

    if (ud == KEY_UP)
    {
        forward_ = HORSE_VELOCITY_NORM;
    }
    else if (ud == KEY_DOWN)
    {
        forward_ = -HORSE_VELOCITY_BACK;
    }

    if (lr == KEY_LEFT)
    {
        angle += HORSE_TURN;
    }
    else if (lr == KEY_RIGHT)
    {
        angle -= HORSE_TURN;
    }

    SetPlayerFacingAngle(playerid,angle);
    s_HorseHeading[playerid] = angle;
    new bool:jump = (keys & KEY_JUMP) != KEY:0, bool:walk = (keys & KEY_WALK) != KEY:0;

    if (jump)
    {
        forward_ *= Horse_GallopSpeed(playerid);
    }

    if (walk)
    {
        forward_ *= HORSE_VELOCITY_WALK;
    }

    SetPlayerVelocity(playerid,forward_ * floatsin(-angle,degrees),forward_ * floatcos(-angle,degrees),0.01);
    s_HorseSpeed[playerid] = forward_;

    if (ud != 0)
    {
        if (++s_HorseNoiseTick[playerid] >= HORSE_NOISE_TICKS && s_HorseSoundOn[playerid])
        {
            s_HorseNoiseFlip[playerid] = !s_HorseNoiseFlip[playerid];
            Horse_PlaySound(playerid,s_HorseNoiseFlip[playerid] ? HORSE_SOUND_SNORT : HORSE_SOUND_WHINE);
            s_HorseNoiseTick[playerid] = 0;
        }

        if (s_HorseStamina[playerid] >= 65.0)
        {
            s_HorseAbleToSprint[playerid] = true;
        }

        if (jump && s_HorseStamina[playerid] > 5.0 && s_HorseAbleToSprint[playerid])
        {
            if (!s_HorsePlayingSound[playerid])
            {
                s_HorsePlayingSound[playerid] = true;

                if (s_HorseSoundOn[playerid])
                {
                    Horse_PlaySound(playerid,HORSE_SOUND_GALLOP);
                }
            }

            if (s_HorseStamina[playerid] < 15.0)
            {
                Horse_StopSound(playerid);
                s_HorsePlayingSound[playerid] = false;
                s_HorseAbleToSprint[playerid] = false;
                return;
            }

            if (walk)
            {
                forward_ *= HORSE_VELOCITY_WALK;
            }
            else
            {
                forward_ *= Horse_GallopSpeed(playerid);
            }

            s_HorseStamina[playerid] -= 1.0;
        }
        else if (s_HorseStamina[playerid] < 100.0)
        {
            s_HorseStamina[playerid] += 1.0;
        }

        if (walk && !jump)
        {
            forward_ *= HORSE_VELOCITY_WALK;

            if (s_HorseStamina[playerid] < 100.0)
            {
                s_HorseStamina[playerid] += 2.0;

                if (s_HorseStamina[playerid] > 100.0)
                {
                    s_HorseStamina[playerid] = 100.0;
                }
            }
        }

        new Float:x, Float:y, Float:z, Float:floorZ;
        GetPlayerPos(playerid,x,y,floorZ);
        z = floorZ;
        CA_FindZ_For2DCoord(x,y,z);
        z += 1.25;
        s_HorseSpeed[playerid] = forward_;
        new Float:vx = forward_ * floatsin(-angle,degrees), Float:vy = forward_ * floatcos(-angle,degrees);

        if (z - floorZ >= 3.0)
        {
            SetPlayerVelocity(playerid,vx,vy,0.01);
        }
        else
        {
            if (floorZ <= z)
            {
                SetPlayerVelocity(playerid,vx,vy,0.05);
            }

            if (floorZ > z + 0.35)
            {
                SetPlayerVelocity(playerid,vx,vy,-0.75);
            }
        }
    }
    else
    {
        Horse_StopSound(playerid);
        s_HorsePlayingSound[playerid] = false;

        if (s_HorseStamina[playerid] < 100.0)
        {
            s_HorseStamina[playerid] += 1.0;
        }
    }

    Horse_UpdateHud(playerid);
}

stock Horse_Frame(playerid)
{
    if (Horse_IsCow(playerid))
    {
        return HORSE_FRAME_IDLE_MS;
    }

    new KEY:keys, ud, lr;
    GetPlayerKeys(playerid,keys,ud,lr);
    new coat = s_HorseCoat[playerid], set, frames, base;

    if (ud == 0 && lr == 0)
    {
        set = 1;
        frames = HORSE_IDLE_FRAMES;
        base = HORSE_IDLE_INDEX;
    }
    else if ((keys & KEY_JUMP) != KEY:0)
    {
        set = 3;
        frames = HORSE_GALLOP_FRAMES;
        base = HORSE_GALLOP_INDEX;
    }
    else if ((keys & KEY_WALK) != KEY:0)
    {
        set = 2;
        frames = HORSE_WALK_FRAMES;
        base = HORSE_WALK_INDEX;
    }
    else
    {
        set = 4;
        frames = HORSE_SPRINT_FRAMES;
        base = HORSE_SPRINT_INDEX;
    }

    new first = set == 1 ? 0 : 1;

    if (s_HorseFrame[playerid] >= frames || s_HorseFrame[playerid] < first || (s_HorseFrame[playerid] <= 0 && set != 1))
    {
        s_HorseFrame[playerid] = first;
    }

    new Float:offsets[6];
    offsets = s_HorseOffsets[set];
    new model = base + (frames * coat) + s_HorseFrame[playerid]++;
    s_HorseFrameSet[playerid] = set;
    s_HorseModel[playerid] = model;
    SetPlayerAttachedObject(playerid,HORSE_ATTACH_SLOT,model,1,offsets[0],offsets[1],offsets[2],offsets[3],offsets[4],offsets[5],1.0,1.0,1.0);
    return set == 1 ? HORSE_FRAME_IDLE_MS : HORSE_FRAME_FAST_MS;
}

stock Horse_Tick()
{
    if (s_HorseRiders <= 0)
    {
        return;
    }

    new now = GetTickCount();

    for (new playerid = 0;playerid < MAX_PLAYERS;playerid++)
    {
        if (!s_HorseRiding[playerid] || !IsPlayerConnected(playerid))
        {
            continue;
        }

        if (now >= s_HorseMoveDue[playerid])
        {
            s_HorseMoveDue[playerid] = now + HORSE_MOVE_MS;
            Horse_Move(playerid);
        }

        if (now >= s_HorseFrameDue[playerid])
        {
            s_HorseFrameDue[playerid] = now + Horse_Frame(playerid);
        }
    }
}

