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
#define WEAPON_SLOT_PANTS (7)
#define WEAPON_SLOT_BACK (8)
#define WEAPON_SLOT_HANDS (9)
#define WEAPON_OFFSETS (9)
#define WEAPON_NAME_LEN (32)

enum _:E_GUN_SLOT
{
    E_GUN_SLOT_HAND = 0,
    E_GUN_SLOT_PANTS,
    E_GUN_SLOT_BACK,
}

static s_WepWeapon[MAX_PLAYERS][3];
static s_WepAmmo[MAX_PLAYERS][3];
static Float:s_WepPantsOffset[MAX_PLAYERS][WEAPON_OFFSETS];
static Float:s_WepBackOffset[MAX_PLAYERS][WEAPON_OFFSETS];
static bool:s_WepLoaded[MAX_PLAYERS];
static bool:s_WepApplied[MAX_PLAYERS];
static bool:s_WepDirty[MAX_PLAYERS];
static bool:s_WepHandsBusy[MAX_PLAYERS];

forward Weapons_OnLoaded(playerid,token);
forward Weapons_OnChanged(playerid);

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
stock bool:Weapon_IsValid(weaponid)
{
    switch (weaponid)
    {
        case 24, 25, 26, 33, 34, 43:
        {
            return true;
        }
    }

    return false;
}

stock Weapon_GetModel(weaponid)
{
    switch (weaponid)
    {
        case 4:
        {
            return 335;
        }
        case 5:
        {
            return 336;
        }
        case 24:
        {
            return 348;
        }
        case 25:
        {
            return 349;
        }
        case 26:
        {
            return 350;
        }
        case 33:
        {
            return 357;
        }
        case 34:
        {
            return 358;
        }
        case 43:
        {
            return 367;
        }
    }

    return 0;
}

stock Weapon_FromModel(model)
{
    switch (model)
    {
        case 335:
        {
            return 4;
        }
        case 336:
        {
            return 5;
        }
        case 348:
        {
            return 24;
        }
        case 349:
        {
            return 25;
        }
        case 350:
        {
            return 26;
        }
        case 357:
        {
            return 33;
        }
        case 358:
        {
            return 34;
        }
        case 367:
        {
            return 43;
        }
    }

    return -1;
}

stock Weapon_GetName(weaponid,dest[],size = sizeof(dest))
{
    switch (weaponid)
    {
        case 0:
        {
            strcopy(dest,"None",size);
        }
        case 18:
        {
            strcopy(dest,"Molotov Cocktail",size);
        }
        case 44:
        {
            strcopy(dest,"Night Vis Goggles",size);
        }
        case 45:
        {
            strcopy(dest,"Thermal Goggles",size);
        }
        case 1 .. 17, 22 .. 43, 46:
        {
            GetWeaponName(WEAPON:weaponid,dest,size);
        }
        default:
        {
            strcopy(dest,"Invalid Weapon Id",size);
        }
    }
}

stock bool:Weapons_IsLoaded(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_WepLoaded[playerid];
}

stock Weapons_Get(playerid,slot)
{
    if (!Weapons_IsLoaded(playerid) || slot < 0 || slot > 2)
    {
        return 0;
    }

    return s_WepWeapon[playerid][slot];
}

stock Weapons_GetAmmo(playerid,slot)
{
    if (!Weapons_IsLoaded(playerid) || slot < 0 || slot > 2)
    {
        return 0;
    }

    return s_WepAmmo[playerid][slot];
}

stock Weapons_SetHandsBusy(playerid,bool:busy)
{
    s_WepHandsBusy[playerid] = busy;
}

stock Weapons_SetSlot(playerid,slot,weapon,ammo)
{
    s_WepWeapon[playerid][slot] = weapon;
    s_WepAmmo[playerid][slot] = ammo;
}

stock Weapons_MarkDirty(playerid)
{
    s_WepDirty[playerid] = true;
}

stock Weapons_Save(playerid)
{
    if (!Weapons_IsLoaded(playerid))
    {
        return;
    }

    s_WepDirty[playerid] = false;
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_handweapon = %d, character_handammo = %d, character_pantsweapon = %d, character_pantsammo = %d, character_backweapon = %d, character_backammo = %d WHERE character_id = %d",s_WepWeapon[playerid][0],s_WepAmmo[playerid][0],s_WepWeapon[playerid][1],s_WepAmmo[playerid][1],s_WepWeapon[playerid][2],s_WepAmmo[playerid][2],Character_GetId(playerid)));
}

stock Weapons_FlushDirty()
{
    foreach (new i : Player)
    {
        if (s_WepDirty[i])
        {
            Weapons_Save(i);
        }
    }
}

stock bool:Weapons_HasOffsets(const Float:offsets[WEAPON_OFFSETS])
{
    return offsets[6] != 0.0 && offsets[7] != 0.0 && offsets[8] != 0.0;
}

stock Weapons_SetOffsets(playerid,slot,Float:values[WEAPON_OFFSETS])
{
    for (new i = 0;i < WEAPON_OFFSETS;i++)
    {
        if (slot == E_GUN_SLOT_PANTS)
        {
            s_WepPantsOffset[playerid][i] = values[i];
        }
        else
        {
            s_WepBackOffset[playerid][i] = values[i];
        }
    }

    new prefix[16];
    strcopy(prefix,slot == E_GUN_SLOT_PANTS ? ("trousergun") : ("backgun"));
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_%s_offsetx = %f, character_%s_offsety = %f, character_%s_offsetz = %f, character_%s_rotx = %f, character_%s_roty = %f, character_%s_rotz = %f, character_%s_scalex = %f, character_%s_scaley = %f, character_%s_scalez = %f WHERE character_id = %d",prefix,values[0],prefix,values[1],prefix,values[2],prefix,values[3],prefix,values[4],prefix,values[5],prefix,values[6],prefix,values[7],prefix,values[8],Character_GetId(playerid)));
}

stock Weapons_Attachments(playerid)
{
    RemovePlayerAttachedObject(playerid,WEAPON_SLOT_PANTS);
    RemovePlayerAttachedObject(playerid,WEAPON_SLOT_BACK);

    if (!s_WepHandsBusy[playerid])
    {
        RemovePlayerAttachedObject(playerid,WEAPON_SLOT_HANDS);
    }

    if (s_WepWeapon[playerid][1] != 0)
    {
        new model = Weapon_GetModel(s_WepWeapon[playerid][1]);

        if (!Weapons_HasOffsets(s_WepPantsOffset[playerid]))
        {
            if (model != 335)
            {
                SetPlayerAttachedObject(playerid,WEAPON_SLOT_PANTS,model,8,0.03,0.0,0.124,-103.4,0.0,1.8,1.0,1.0,1.0);
            }
            else
            {
                SetPlayerAttachedObject(playerid,WEAPON_SLOT_PANTS,model,8,0.14,0.10,0.12,-103.40,90.40,1.79,1.0,1.0,1.0);
            }
        }
        else
        {
            SetPlayerAttachedObject(playerid,WEAPON_SLOT_PANTS,model,8,s_WepPantsOffset[playerid][0],s_WepPantsOffset[playerid][1],s_WepPantsOffset[playerid][2],s_WepPantsOffset[playerid][3],s_WepPantsOffset[playerid][4],s_WepPantsOffset[playerid][5],s_WepPantsOffset[playerid][6],s_WepPantsOffset[playerid][7],s_WepPantsOffset[playerid][8]);
        }
    }

    if (!s_WepHandsBusy[playerid] && s_WepWeapon[playerid][2] != 0)
    {
        new model = Weapon_GetModel(s_WepWeapon[playerid][2]);

        if (!Weapons_HasOffsets(s_WepBackOffset[playerid]))
        {
            if (model == 336)
            {
                SetPlayerAttachedObject(playerid,WEAPON_SLOT_BACK,model,1,0.19,-0.16,0.0,0.0,-97.29,4.0,1.0,1.0,1.0);
            }
            else if (model == 335)
            {
                SetPlayerAttachedObject(playerid,WEAPON_SLOT_BACK,model,1,-0.29,-0.13,-0.20,0.0,-89.49,4.0,1.0,1.0,1.0);
            }
            else
            {
                SetPlayerAttachedObject(playerid,WEAPON_SLOT_BACK,model,1,-0.20,-0.13,0.0,0.0,0.0,4.0,1.0,1.0,1.0);
            }
        }
        else
        {
            SetPlayerAttachedObject(playerid,WEAPON_SLOT_BACK,model,1,s_WepBackOffset[playerid][0],s_WepBackOffset[playerid][1],s_WepBackOffset[playerid][2],s_WepBackOffset[playerid][3],s_WepBackOffset[playerid][4],s_WepBackOffset[playerid][5],s_WepBackOffset[playerid][6],s_WepBackOffset[playerid][7],s_WepBackOffset[playerid][8]);
        }
    }

    if (s_WepWeapon[playerid][0] != 0 && s_WepAmmo[playerid][0] <= 0 && Weapon_GetModel(s_WepWeapon[playerid][0]) != 0)
    {
        SetPlayerAttachedObject(playerid,WEAPON_SLOT_HANDS,Weapon_GetModel(s_WepWeapon[playerid][0]),6,0.004,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0);
    }
}

stock Weapons_SyncEngine(playerid)
{
    ResetPlayerWeapons(playerid);

    if (s_WepWeapon[playerid][0] != 0 && s_WepAmmo[playerid][0] > 0)
    {
        GivePlayerWeapon(playerid,WEAPON:s_WepWeapon[playerid][0],s_WepAmmo[playerid][0]);
    }
}

stock Weapons_SyncHud(playerid)
{
    if (Inventory_GetEquipped(playerid) != EQUIP_NONE)
    {
        return;
    }

    if (s_WepWeapon[playerid][0] == 0)
    {
        Hud_ClearWeapon(playerid);
        return;
    }

    Hud_SetEngineWeapon(playerid,s_WepWeapon[playerid][0],s_WepAmmo[playerid][0]);
}

stock Weapons_Apply(playerid)
{
    if (!Player_IsReady(playerid) || !s_WepLoaded[playerid])
    {
        return;
    }

    s_WepApplied[playerid] = true;
    Inventory_SetWeaponInHand(playerid,s_WepWeapon[playerid][0] != 0);
    Weapons_SyncEngine(playerid);
    Weapons_Attachments(playerid);
    Weapons_SyncHud(playerid);
}

stock bool:Weapons_Give(playerid,weaponid,ammo)
{
    if (!Player_IsReady(playerid) || !Weapons_IsLoaded(playerid))
    {
        return false;
    }

    if (s_WepWeapon[playerid][0] != 0)
    {
        SendServerMessage(playerid,"You already have a weapon equipped. Holster it first.",MSG_TYPE_ERROR);
        return false;
    }

    if (Inventory_GetEquipped(playerid) != EQUIP_NONE)
    {
        SendServerMessage(playerid,"You need to unequip your current item before buying a weapon.",MSG_TYPE_ERROR);
        return false;
    }

    if (ammo < 0)
    {
        ammo = 0;
    }

    s_WepWeapon[playerid][0] = weaponid;
    s_WepAmmo[playerid][0] = ammo;
    Weapons_Save(playerid);
    Inventory_SetWeaponInHand(playerid,true);
    RemovePlayerAttachedObject(playerid,WEAPON_SLOT_HANDS);
    Weapons_SyncEngine(playerid);
    Weapons_ReloadAnimation(playerid,weaponid);

    if (ammo <= 0 && weaponid != 4 && weaponid != 5)
    {
        SetPlayerAttachedObject(playerid,WEAPON_SLOT_HANDS,Weapon_GetModel(weaponid),6,0.004,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0);
    }

    Weapons_SyncHud(playerid);
    pawn_call_public("Weapons_OnChanged","d",playerid);
    return true;
}

stock Weapons_RemoveHand(playerid)
{
    if (!Weapons_IsLoaded(playerid))
    {
        return;
    }

    s_WepWeapon[playerid][0] = 0;
    s_WepAmmo[playerid][0] = 0;
    Weapons_Save(playerid);
    Inventory_SetWeaponInHand(playerid,false);

    if (IsPlayerAttachedObjectSlotUsed(playerid,WEAPON_SLOT_HANDS) && !s_WepHandsBusy[playerid])
    {
        RemovePlayerAttachedObject(playerid,WEAPON_SLOT_HANDS);
    }

    ResetPlayerWeapons(playerid);
    SetPlayerDrunkLevel(playerid,0);
    Weapons_SyncHud(playerid);
    pawn_call_public("Weapons_OnChanged","d",playerid);
}

stock Weapons_ReloadAnimation(playerid,weaponid)
{
    switch (weaponid)
    {
        case 22:
        {
            ApplyAnimation(playerid,"COLT45","colt45_reload",4.0,false,false,false,false,0);
        }
        case 23:
        {
            ApplyAnimation(playerid,"SILENCED","Silence_reload",4.0,false,false,false,false,0);
        }
        case 24:
        {
            ApplyAnimation(playerid,"PYTHON","python_reload",4.0,false,false,false,false,0);
        }
        case 25, 27:
        {
            ApplyAnimation(playerid,"BUDDY","buddy_reload",4.0,false,false,false,false,0);
        }
        case 26:
        {
            ApplyAnimation(playerid,"COLT45","sawnoff_reload",4.0,false,false,false,false,0);
        }
        case 29 .. 31, 33, 34:
        {
            ApplyAnimation(playerid,"RIFLE","rifle_load",4.0,false,false,false,false,0);
        }
        case 28, 32:
        {
            ApplyAnimation(playerid,"TEC","tec_reload",4.0,false,false,false,false,0);
        }
    }
}

static Weapons_ResetState(playerid)
{
    for (new i = 0;i < 3;i++)
    {
        s_WepWeapon[playerid][i] = 0;
        s_WepAmmo[playerid][i] = 0;
    }

    for (new i = 0;i < WEAPON_OFFSETS;i++)
    {
        s_WepPantsOffset[playerid][i] = 0.0;
        s_WepBackOffset[playerid][i] = 0.0;
    }

    s_WepLoaded[playerid] = false;
    s_WepApplied[playerid] = false;
    s_WepDirty[playerid] = false;
    s_WepHandsBusy[playerid] = false;
}

/**
 *                        __  __  __                            __
 *                       |  \|  \|  \                          |  |
 *      _______  ______  | $$| $$| $$____    ______    _______ | $$   __   _______
 *     /       \|      \ | $$| $$| $$    \  |      \  /       \| $$  /  \ /       |
 *    |  $$$$$$$ \$$$$$$\| $$| $$| $$$$$$$\  \$$$$$$\|  $$$$$$$| $$_/  $$|  $$$$$$$
 *    | $$      /      $$| $$| $$| $$  | $$ /      $$| $$      | $$   $$  \$$    |
 *    | $$_____|  $$$$$$$| $$| $$| $$__/ $$|  $$$$$$$| $$_____ | $$$$$$\  _\$$$$$$|
 *     \$$     \\$$    $$| $$| $$| $$    $$ \$$    $$ \$$     \| $$  \$$\|       $$
 *      \$$$$$$$ \$$$$$$$ \$$ \$$ \$$$$$$$   \$$$$$$$  \$$$$$$$ \$$   \$$ \$$$$$$$
 *
 */
public Weapons_OnChanged(playerid)
{
    return 1;
}

public Weapons_OnLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"character_handweapon",s_WepWeapon[playerid][0]);
        cache_get_value_name_int(0,"character_handammo",s_WepAmmo[playerid][0]);
        cache_get_value_name_int(0,"character_pantsweapon",s_WepWeapon[playerid][1]);
        cache_get_value_name_int(0,"character_pantsammo",s_WepAmmo[playerid][1]);
        cache_get_value_name_int(0,"character_backweapon",s_WepWeapon[playerid][2]);
        cache_get_value_name_int(0,"character_backammo",s_WepAmmo[playerid][2]);
        new names[WEAPON_OFFSETS][8] = {"offsetx","offsety","offsetz","rotx","roty","rotz","scalex","scaley","scalez"}, column[48];

        for (new i = 0;i < WEAPON_OFFSETS;i++)
        {
            format(column,sizeof(column),"character_trousergun_%s",names[i]);
            cache_get_value_name_float(0,column,s_WepPantsOffset[playerid][i]);
            format(column,sizeof(column),"character_backgun_%s",names[i]);
            cache_get_value_name_float(0,column,s_WepBackOffset[playerid][i]);
        }
    }

    s_WepLoaded[playerid] = true;
    Weapons_Apply(playerid);
    return 1;
}

/**
 *     __                            __
 *    |  \                          |  |
 *    | $$____    ______    ______  | $$   __   _______
 *    | $$    \  /      \  /      \ | $$  /  \ /       |
 *    | $$$$$$$\|  $$$$$$\|  $$$$$$\| $$_/  $$|  $$$$$$$
 *    | $$  | $$| $$  | $$| $$  | $$| $$   $$  \$$    |
 *    | $$  | $$| $$__/ $$| $$__/ $$| $$$$$$\  _\$$$$$$|
 *    | $$  | $$ \$$    $$ \$$    $$| $$  \$$\|       $$
 *     \$$   \$$  \$$$$$$   \$$$$$$  \$$   \$$ \$$$$$$$
 *
 */
#include <pp-hooks>

hook OnPlayerConnect(playerid)
{
    Weapons_ResetState(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    if (s_WepDirty[playerid])
    {
        Weapons_Save(playerid);
    }

    Weapons_ResetState(playerid);
}

hook Character_OnLoad(playerid,characterid)
{
    Weapons_ResetState(playerid);
    mysql_tquery_s(g_Mysql,str_format("SELECT character_handweapon, character_handammo, character_pantsweapon, character_pantsammo, character_backweapon, character_backammo, character_trousergun_offsetx, character_trousergun_offsety, character_trousergun_offsetz, character_trousergun_rotx, character_trousergun_roty, character_trousergun_rotz, character_trousergun_scalex, character_trousergun_scaley, character_trousergun_scalez, character_backgun_offsetx, character_backgun_offsety, character_backgun_offsetz, character_backgun_rotx, character_backgun_roty, character_backgun_rotz, character_backgun_scalex, character_backgun_scaley, character_backgun_scalez FROM characters WHERE character_id = %d",characterid),"Weapons_OnLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    if (s_WepDirty[playerid])
    {
        Weapons_Save(playerid);
    }

    Weapons_ResetState(playerid);
    Inventory_SetWeaponInHand(playerid,false);
}

hook Spawn_OnComplete(playerid)
{
    Weapons_Apply(playerid);
}
