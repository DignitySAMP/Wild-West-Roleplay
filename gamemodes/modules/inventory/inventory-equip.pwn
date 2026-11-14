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
#define EQUIP_SLOT (6)
#define EQUIP_BONE (6)
#define EQUIP_COOLDOWN_MS (3000)
#define EQUIP_NONE (-1)

enum e_EQUIP
{
    E_EQUIP_EXTRA,
    E_EQUIP_MODEL,
    E_EQUIP_HUD_MODEL,
    Float:E_EQUIP_ZOOM,
    E_EQUIP_HUD_NAME[20],
    Float:E_EQUIP_OFFSET[9],
    E_EQUIP_ME[64],
    E_EQUIP_MESSAGE[128],
    E_EQUIP_NOTE[112],
    bool:E_EQUIP_CONSUME,
}

static const s_EquipTable[][e_EQUIP] =
{
    {E_ITEM_EXTRA_CAMERA,0,19623,1.0,"Flash Camera",{0.08,0.04,0.1,181.5,0.0,0.0,1.0,1.0,1.0},"has equipped a camera","You've equipped a camera. You can now take pictures.","",false},
    {E_ITEM_EXTRA_DYNAMITE,0,1654,1.0,"Dynamite",{0.08,0.04,0.1,181.5,0.0,0.0,1.0,1.0,1.0},"has equipped a set of dynamite","You've equipped a dynamite set. You can now use /dynamite.","",false},
    {E_ITEM_EXTRA_HUNTING_KNIFE,0,335,1.0,"Hunting Knife",{-0.018,0.06,-0.025,181.5,17.5,0.0,1.0,1.0,1.0},"has equipped a hunting knife","You've equipped a hunting knife. Press ~k~~SNEAK_ABOUT~ to skin a dead animal.","",false},
    {E_ITEM_EXTRA_FISHING_ROD,0,18632,1.0,"Fishing Rod",{0.08,0.04,0.1,181.5,0.0,0.0,1.0,1.0,1.0},"has equipped a fishing rod","You've equipped a fishing rod. Press ~k~~SNEAK_ABOUT~ near water to fish.","",false},
    {E_ITEM_EXTRA_MINE_PICKAXE,0,PICKAXE,4.5,"Pickaxe",{0.0709,0.0519,0.1359,0.0,0.0,0.0,1.0,1.0,1.0},"has equipped a pickaxe","You've equipped a pickaxe.  Press ~k~~SNEAK_ABOUT~ to mine a rock.","",false},
    {E_ITEM_EXTRA_LUMBER_HATCHET,0,HATCHET,4.5,"Hatchet",{0.0709,0.034,0.0,0.0,0.0,-175.4997,1.0,1.0,1.0},"has equipped a hatchet","You've equipped a hatchet. Press ~k~~SNEAK_ABOUT~ to chop a tree.","",false},
    {E_ITEM_EXTRA_LIQUOR_PALELAGER,0,1544,1.0,"Pale Lager",{0.08,0.04,-0.2,-0.2,0.0,3.8,1.0,1.0,1.0},"has opened a bottle of Pale Lager Liquor","Use /drink to drink. You can unequip the bottle by using unequip.","",false},
    {E_ITEM_EXTRA_LIQUOR_MILDALE,0,1543,1.0,"Mild Ale",{0.08,0.04,-0.2,-0.2,0.0,3.8,1.0,1.0,1.0},"has opened a bottle of Mild Ale","Use /drink to drink. You can unequip the bottle by using unequip.","",false},
    {E_ITEM_EXTRA_LIQUOR_MALTLIQUOR,0,1486,1.0,"Malt Liquor",{0.08,0.04,-0.2,-0.2,0.0,3.8,1.0,1.0,1.0},"has opened a bottle of Malt Liquor","Use /drink to drink. You can unequip the bottle by using unequip.","",false},
    {E_ITEM_EXTRA_LIQUOR_WHEATBEER,0,1484,1.0,"Wheat Beer",{0.0,0.0,-0.072,-0.2,19.0,3.8,1.0,1.0,1.0},"has opened a bottle of Wheat Beer","Use /drink to drink. You can unequip the bottle by using unequip.","",false},
    {E_ITEM_EXTRA_LIQUOR_WHITEWINE,0,19824,1.0,"White Wine",{0.08,0.04,-0.292,-0.2,0.0,3.8,0.81,0.83,0.703},"has opened a bottle of White Wine","Use /drink to drink. You can unequip the bottle by using unequip.","",false},
    {E_ITEM_EXTRA_LIQUOR_REDWINE,0,19822,1.0,"Red Wine",{0.08,0.04,-0.292,-0.2,0.0,3.8,0.81,0.83,0.703},"has opened a bottle of Red Wine","Use /drink to drink. You can unequip the bottle by using unequip.","",false},
    {E_ITEM_EXTRA_LIQUOR_GRAINWHISKEY,0,19823,1.0,"Grain Whiskey",{0.08,0.04,-0.22,-0.2,0.0,3.8,0.81,0.83,0.7},"has opened a bottle of Grain Whiskey","Use /drink to drink. You can unequip the bottle by using unequip.","",false},
    {E_ITEM_EXTRA_LIQUOR_MALTWHISKEY,0,19820,1.0,"Malt Whiskey",{0.08,0.04,-0.292,-0.2,0.0,3.8,0.81,0.83,0.703},"has opened a bottle of Malt Whiskey","Use /drink to drink. You can unequip the bottle by using unequip.","",false},
    {E_ITEM_EXTRA_LIQUOR_VODKA,0,19821,1.0,"Moonshine Vodka",{0.08,0.04,-0.292,-0.2,0.0,3.8,0.81,0.83,0.703},"has opened a bottle of Moonshine Vodka","Use /smoke 1 to drink. You can unequip the bottle by using unequip.","",false},
    {E_ITEM_EXTRA_SMOKE_CIGARPACK,1485,1485,1.0,"Cigar",{0.015,-0.022,0.019,-0.2,0.0,3.8,0.81,0.83,0.7},"pulled out a cigar from his pack and lit it up","Use /smoke 1 to smoke. Simply unequip to stop smoking.","",true},
    {E_ITEM_EXTRA_SMOKE_BLUNTPACK,3027,3027,1.0,"Cigarette",{0.11,0.0,0.033,63.0,69.2,3.8,0.81,0.83,0.7},"pulled out a rolled cigarette from his pack and lit it up","Use /smoke to smoke. Simply unequip to stop smoking.","",true},
    {E_ITEM_EXTRA_SHERIFF_LASSO,0,0,1.0,"Lasso",{-0.018,0.06,-0.025,181.5,17.5,0.0,1.0,1.0,1.0},"has equipped a lasso","You've equipped a lasso. Use /lasso [targetid] to target someone then use LEFT-CLICK to try and catch them.","Do not abuse the lasso for trolling. Ignoring this warning could lead you to an admin-jail or a ban.",false},
    {E_ITEM_EXTRA_SHERIFF_LONG_LASSO,0,0,1.0,"Long Lasso",{-0.018,0.06,-0.025,181.5,17.5,0.0,1.0,1.0,1.0},"has equipped a long lasso","You've equipped a long lasso. Use /lasso [targetid] to target someone then use LEFT-CLICK to try and catch them.","Do not abuse the lasso for trolling. Ignoring this warning could lead you to an admin-jail or a ban.",false}
};

static s_EquipExtra[MAX_PLAYERS] = {EQUIP_NONE,...};
static s_EquipUid[MAX_PLAYERS];
static s_EquipTick[MAX_PLAYERS];
static bool:s_EquipWeapon[MAX_PLAYERS];

forward Inventory_OnEquip(playerid,extra,bool:equipped);
forward Inventory_UseEquip(playerid,uid,item,extra);

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
stock Inventory_GetEquipped(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return EQUIP_NONE;
    }

    return s_EquipExtra[playerid];
}

stock Inventory_GetEquippedUid(playerid)
{
    return s_EquipUid[playerid];
}

stock Inventory_SetWeaponInHand(playerid,bool:inHand)
{
    s_EquipWeapon[playerid] = inHand;
}

stock bool:Inventory_Unequip(playerid,bool:announce = true)
{
    new extra = s_EquipExtra[playerid];

    if (extra == EQUIP_NONE)
    {
        return false;
    }

    s_EquipExtra[playerid] = EQUIP_NONE;
    s_EquipUid[playerid] = 0;
    RemovePlayerAttachedObject(playerid,EQUIP_SLOT);
    Hud_ClearWeapon(playerid);

    if (announce)
    {
        new item = Item_FindByExtra(extra), name[ITEM_NAME_LEN], line[160], player[ACCOUNT_NAME_LEN];
        Item_GetName(item,name);
        Account_GetRoleplayName(playerid,player);
        format(line,sizeof(line),"* %s has unequipped their %s.",player,name);
        ProxDetector(playerid,20.0,COLOR_ACTION,line);
        SendServerMessage(playerid,"The item you equipped before has been unequipped.",MSG_TYPE_ERROR);
    }

    pawn_call_public("Inventory_OnEquip","dd",playerid,extra,false);
    pawn_call_public("Inventory_OnChanged","d",playerid);
    return true;
}

stock bool:Inventory_SetEquipped(playerid,uid,extra)
{
    if (s_EquipExtra[playerid] != EQUIP_NONE)
    {
        return false;
    }

    s_EquipExtra[playerid] = extra;
    s_EquipUid[playerid] = uid;
    s_EquipTick[playerid] = GetTickCount();
    pawn_call_public("Inventory_OnEquip","dd",playerid,extra,true);
    pawn_call_public("Inventory_OnChanged","d",playerid);
    return true;
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
public Inventory_OnEquip(playerid,extra,bool:equipped)
{
    return 1;
}

public Inventory_UseEquip(playerid,uid,item,extra)
{
    if (s_EquipExtra[playerid] != EQUIP_NONE)
    {
        Inventory_Unequip(playerid,true);
        return 1;
    }

    new def = -1;

    for (new i = 0;i < sizeof(s_EquipTable);i++)
    {
        if (s_EquipTable[i][E_EQUIP_EXTRA] == extra)
        {
            def = i;
            break;
        }
    }

    if (def == -1)
    {
        return 0;
    }

    if (s_EquipWeapon[playerid])
    {
        SendServerMessage(playerid,"You have to holster your weapon before you can equip something.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Player_IsBusyWith(playerid,E_PLAYER_BUSY_HORSE) && extra != E_ITEM_EXTRA_SHERIFF_LASSO)
    {
        SendServerMessage(playerid,"You cannot equip anything while riding a horse.",MSG_TYPE_ERROR);
        return 1;
    }

    new elapsed = GetTickCount() - s_EquipTick[playerid];

    if (elapsed < EQUIP_COOLDOWN_MS)
    {
        new line[96];
        format(line,sizeof(line),"You must wait %0.2f seconds before equipping something again.",float(EQUIP_COOLDOWN_MS - elapsed) / 1000.0);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return 1;
    }

    new model = s_EquipTable[def][E_EQUIP_MODEL], hudModel = s_EquipTable[def][E_EQUIP_HUD_MODEL], hudName[20], line[160], player[ACCOUNT_NAME_LEN];

    if (model == 0)
    {
        model = Item_GetModel(item);
    }

    if (hudModel == 0)
    {
        hudModel = Item_GetModel(item);
    }

    strcopy(hudName,s_EquipTable[def][E_EQUIP_HUD_NAME],sizeof(hudName));
    SetPlayerAttachedObject(playerid,EQUIP_SLOT,model,EQUIP_BONE,s_EquipTable[def][E_EQUIP_OFFSET][0],s_EquipTable[def][E_EQUIP_OFFSET][1],s_EquipTable[def][E_EQUIP_OFFSET][2],s_EquipTable[def][E_EQUIP_OFFSET][3],s_EquipTable[def][E_EQUIP_OFFSET][4],s_EquipTable[def][E_EQUIP_OFFSET][5],s_EquipTable[def][E_EQUIP_OFFSET][6],s_EquipTable[def][E_EQUIP_OFFSET][7],s_EquipTable[def][E_EQUIP_OFFSET][8]);
    Inventory_SetEquipped(playerid,s_EquipTable[def][E_EQUIP_CONSUME] ? 0 : uid,extra);
    Hud_SetWeapon(playerid,hudName,hudModel,HUD_AMMO_ITEM,s_EquipTable[def][E_EQUIP_ZOOM]);
    Account_GetRoleplayName(playerid,player);
    format(line,sizeof(line),"* %s %s.",player,s_EquipTable[def][E_EQUIP_ME]);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
    SendServerMessage(playerid,s_EquipTable[def][E_EQUIP_MESSAGE],MSG_TYPE_INFO);

    if (s_EquipTable[def][E_EQUIP_NOTE][0] != EOS)
    {
        SendServerMessage(playerid,s_EquipTable[def][E_EQUIP_NOTE],MSG_TYPE_WARN);
    }

    if (s_EquipTable[def][E_EQUIP_CONSUME])
    {
        new index = Inventory_IndexOfUid(playerid,uid);

        if (index != INV_ROW_NONE)
        {
            Inventory_Decrease(playerid,index,1);
        }
    }

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

hook Inventory_OnRowRemoved(playerid,uid,item)
{
    if (uid != 0 && uid == s_EquipUid[playerid])
    {
        Inventory_Unequip(playerid,false);
    }
}

hook OnGameModeInit()
{
    Inventory_RegisterUse(E_ITEM_TYPE_EQUIP,USE_ANY,"Inventory_UseEquip");
}

hook OnPlayerConnect(playerid)
{
    s_EquipExtra[playerid] = EQUIP_NONE;
    s_EquipUid[playerid] = 0;
    s_EquipTick[playerid] = 0;
    s_EquipWeapon[playerid] = false;
}

hook OnPlayerDisconnect(playerid,reason)
{
    s_EquipExtra[playerid] = EQUIP_NONE;
    s_EquipUid[playerid] = 0;
}
