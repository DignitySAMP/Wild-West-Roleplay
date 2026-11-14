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
#define MASK_LEVEL (10)
#define MASK_SLOT (5)
#define MASK_BONE (2)
#define MASK_COUNT (5)
#define ATTRIBUTES_LEN (145)
#define EXAMINE_RANGE (10.0)
#define EXAMINE_BUBBLE_MS (10000)

forward Mask_ShopDeferred(playerid,token);
forward Mask_OnLoaded(playerid,token);
forward Nametag_Refresh(playerid);

static const s_MaskModels[MASK_COUNT + 2] = {0,18919,18912,18913,18918,18911,11704};
static const s_MaskPrices[MASK_COUNT + 1] = {0,5,7,7,10,10};
static const s_MaskColours[MASK_COUNT + 1][8] = {"","white","black","green","olive","skull"};
static const Float:s_MaskDefault[9] = {0.078534,0.041857,-0.001727,268.970458,1.533374,269.223754,1.0,1.0,1.0};

static s_MaskOwned[MAX_PLAYERS];
static bool:s_MaskWorn[MAX_PLAYERS];
static Float:s_MaskOffsets[MAX_PLAYERS][9];
static s_Attributes[MAX_PLAYERS][ATTRIBUTES_LEN];

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
stock Mask_GetOwned(playerid)
{
    return s_MaskOwned[playerid];
}

stock bool:Mask_IsWorn(playerid)
{
    return s_MaskWorn[playerid];
}

stock Name_Real(playerid,dest[],size = sizeof(dest))
{
    Account_GetRoleplayName(playerid,dest,size);
}

stock Name_Display(playerid,dest[],size = sizeof(dest))
{
    if (s_MaskWorn[playerid])
    {
        format(dest,size,"Stranger %d_%d",Account_GetId(playerid) * 20,Character_GetId(playerid));
        return;
    }

    Account_GetRoleplayName(playerid,dest,size);
}

stock Mask_GetAttributes(playerid,dest[],size = sizeof(dest))
{
    strcopy(dest,s_Attributes[playerid],size);
}

static Mask_Reset(playerid)
{
    s_MaskOwned[playerid] = 0;
    s_MaskWorn[playerid] = false;
    s_Attributes[playerid][0] = EOS;

    for (new i = 0;i < 9;i++)
    {
        s_MaskOffsets[playerid][i] = s_MaskDefault[i];
    }
}

static Mask_Attach(playerid,bool:saved)
{
    new model = s_MaskModels[s_MaskOwned[playerid]];

    if (saved)
    {
        SetPlayerAttachedObject(playerid,MASK_SLOT,model,MASK_BONE,s_MaskOffsets[playerid][0],s_MaskOffsets[playerid][1],s_MaskOffsets[playerid][2],s_MaskOffsets[playerid][3],s_MaskOffsets[playerid][4],s_MaskOffsets[playerid][5],s_MaskOffsets[playerid][6],s_MaskOffsets[playerid][7],s_MaskOffsets[playerid][8]);
        return;
    }

    SetPlayerAttachedObject(playerid,MASK_SLOT,model,MASK_BONE,s_MaskDefault[0],s_MaskDefault[1],s_MaskDefault[2],s_MaskDefault[3],s_MaskDefault[4],s_MaskDefault[5],s_MaskDefault[6],s_MaskDefault[7],s_MaskDefault[8]);
}

public Mask_OnLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    Mask_Reset(playerid);

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0,"character_mask",s_MaskOwned[playerid]);
        cache_get_value_name(0,"character_attributes",s_Attributes[playerid],ATTRIBUTES_LEN);
        new column[24];

        for (new i = 0;i < 9;i++)
        {
            format(column,sizeof(column),"character_mask_o%d",i);
            cache_get_value_name_float(0,column,s_MaskOffsets[playerid][i]);
        }
    }

    return 1;
}

static Mask_Save(playerid)
{
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_mask = %d WHERE character_id = %d",s_MaskOwned[playerid],Character_GetId(playerid)));
}

/**
 *                                   __
 *                                  |  |
 *      _______  ______ ____    ____| $$  _______
 *     /       \|      \    \  /      $$ /       |
 *    |  $$$$$$$| $$$$$$\$$$$\|  $$$$$$$|  $$$$$$$
 *    | $$      | $$ | $$ | $$| $$  | $$ \$$    |
 *    | $$_____ | $$ | $$ | $$| $$__| $$ _\$$$$$$|
 *     \$$     \| $$ | $$ | $$ \$$    $$|       $$
 *      \$$$$$$$ \$$  \$$  \$$  \$$$$$$$ \$$$$$$$
 *
 */
CMD:mask(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (Character_GetLevel(playerid) < MASK_LEVEL)
    {
        SendServerMessage(playerid,"You need to be level 10 to use a mask.",MSG_TYPE_ERROR);
        return 1;
    }

    if (s_MaskOwned[playerid] == 0)
    {
        SendServerMessage(playerid,"You don't have a mask. Buy one in a clothing store.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!s_MaskWorn[playerid])
    {
        Mask_Attach(playerid,true);
        s_MaskWorn[playerid] = true;
        SendServerMessage(playerid,"You have masked yourself. If you don't see your mask, use /editmask because it might not be set up properly (yet)!",MSG_TYPE_WARN);
    }
    else
    {
        s_MaskWorn[playerid] = false;
        RemovePlayerAttachedObject(playerid,MASK_SLOT);
        SendServerMessage(playerid,"You have unmasked yourself.",MSG_TYPE_INFO);
    }

    Nametag_Refresh(playerid);
    return 1;
}

CMD:resyncmask(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (s_MaskOwned[playerid] == 0)
    {
        SendServerMessage(playerid,"You don't have a mask. Buy one in a clothing store.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!s_MaskWorn[playerid])
    {
        SendServerMessage(playerid,"You're not masked - use /mask.",MSG_TYPE_ERROR);
        return 1;
    }

    Mask_Attach(playerid,true);
    return 1;
}

CMD:editmask(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (s_MaskOwned[playerid] == 0)
    {
        SendServerMessage(playerid,"You don't have a mask. Buy one in a clothing store.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!s_MaskWorn[playerid])
    {
        SendServerMessage(playerid,"You're not masked - use /mask.",MSG_TYPE_ERROR);
        return 1;
    }

    Mask_Attach(playerid,true);
    EditAttachedObject(playerid,MASK_SLOT);
    SendServerMessage(playerid,"You can now edit the mask. Reminder: equipping an item will remove it.",MSG_TYPE_ERROR);
    return 1;
}

CMD:attributes(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new text[ATTRIBUTES_LEN];

    if (sscanf(params,"s[144]",text))
    {
        SendServerMessage(playerid,"/attributes [text]",MSG_TYPE_ERROR);
        return 1;
    }

    strcopy(s_Attributes[playerid],text,ATTRIBUTES_LEN);
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_attributes = '%e' WHERE character_id = %d",text,Character_GetId(playerid)));
    new line[200], name[ACCOUNT_NAME_LEN];
    Name_Real(playerid,name);
    format(line,sizeof(line),"** Attribution message: %s's attributes: %s",name,text);
    SendClientMessage(playerid,COLOR_ACTION,line);
    return 1;
}

ALT:att=CMD:attributes;

CMD:examine(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendServerMessage(playerid,"/examine [target]",MSG_TYPE_ERROR);
        return 1;
    }

    if (targetid == INVALID_PLAYER_ID || !Player_IsReady(targetid))
    {
        SendServerMessage(playerid,"Player doesn't seem to be connected.",MSG_TYPE_ERROR);
        return 1;
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(targetid,x,y,z);

    if (targetid != playerid && !IsPlayerInRangeOfPoint(playerid,EXAMINE_RANGE,x,y,z))
    {
        SendServerMessage(playerid,"You're not close enough to your target.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[200], name[ACCOUNT_NAME_LEN];
    Name_Real(targetid,name);
    format(line,sizeof(line),"%s's attributes: %s",name,s_Attributes[targetid]);
    SetPlayerChatBubble(targetid,line,COLOR_ACTION,20.0,EXAMINE_BUBBLE_MS);
    format(line,sizeof(line),"** Attribution message: %s's attributes: %s",name,s_Attributes[targetid]);
    SendClientMessage(playerid,COLOR_ACTION,line);
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

hook OnMigrationRun()
{
    Migration_Add("people-1-mask-attributes","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_mask INT NOT NULL DEFAULT 0, ADD COLUMN IF NOT EXISTS character_attributes VARCHAR(145) NOT NULL DEFAULT '', ADD COLUMN IF NOT EXISTS character_mask_o0 FLOAT NOT NULL DEFAULT 0.078534, ADD COLUMN IF NOT EXISTS character_mask_o1 FLOAT NOT NULL DEFAULT 0.041857, ADD COLUMN IF NOT EXISTS character_mask_o2 FLOAT NOT NULL DEFAULT -0.001727, ADD COLUMN IF NOT EXISTS character_mask_o3 FLOAT NOT NULL DEFAULT 268.970458, ADD COLUMN IF NOT EXISTS character_mask_o4 FLOAT NOT NULL DEFAULT 1.533374, ADD COLUMN IF NOT EXISTS character_mask_o5 FLOAT NOT NULL DEFAULT 269.223754, ADD COLUMN IF NOT EXISTS character_mask_o6 FLOAT NOT NULL DEFAULT 1, ADD COLUMN IF NOT EXISTS character_mask_o7 FLOAT NOT NULL DEFAULT 1, ADD COLUMN IF NOT EXISTS character_mask_o8 FLOAT NOT NULL DEFAULT 1");
}

hook OnPlayerConnect(playerid)
{
    Mask_Reset(playerid);
}

hook Character_OnLoad(playerid,characterid)
{
    Mask_Reset(playerid);
    mysql_tquery_s(g_Mysql,str_format("SELECT character_mask, character_attributes, character_mask_o0, character_mask_o1, character_mask_o2, character_mask_o3, character_mask_o4, character_mask_o5, character_mask_o6, character_mask_o7, character_mask_o8 FROM characters WHERE character_id = %d",characterid),"Mask_OnLoaded","dd",playerid,Account_GetToken(playerid));
}

stock Mask_AnnounceLeave(playerid,reason)
{
    new const reasons[3][] = {"Timeout/Crash","Quit","Kick/Ban"};

    if (reason < 0 || reason > 2)
    {
        return false;
    }

    new name[MAX_PLAYER_NAME + 1], line[144];
    Name_Display(playerid,name);
    format(line,sizeof(line),"[DISCONNECT] (%d) %s has disconnected from the server. Reason: %s",playerid,name,reasons[reason]);
    return ProxDetector(playerid,15.0,0xAAC4E5FF,line);
}

hook Character_OnLeaving(playerid,characterid)
{
    Mask_AnnounceLeave(playerid,Account_GetLeaveReason(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    if (s_MaskWorn[playerid])
    {
        RemovePlayerAttachedObject(playerid,MASK_SLOT);
    }

    Mask_Reset(playerid);
}

hook OnPlayerEditAttachedObject(playerid,EDIT_RESPONSE:response,index,modelid,boneid,Float:fOffsetX,Float:fOffsetY,Float:fOffsetZ,Float:fRotX,Float:fRotY,Float:fRotZ,Float:fScaleX,Float:fScaleY,Float:fScaleZ)
{
    if (index != MASK_SLOT || response != EDIT_RESPONSE_FINAL || !s_MaskWorn[playerid])
    {
        return;
    }

    s_MaskOffsets[playerid][0] = fOffsetX;
    s_MaskOffsets[playerid][1] = fOffsetY;
    s_MaskOffsets[playerid][2] = fOffsetZ;
    s_MaskOffsets[playerid][3] = fRotX;
    s_MaskOffsets[playerid][4] = fRotY;
    s_MaskOffsets[playerid][5] = fRotZ;
    s_MaskOffsets[playerid][6] = fScaleX;
    s_MaskOffsets[playerid][7] = fScaleY;
    s_MaskOffsets[playerid][8] = fScaleZ;
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_mask_o0 = %f, character_mask_o1 = %f, character_mask_o2 = %f, character_mask_o3 = %f, character_mask_o4 = %f, character_mask_o5 = %f, character_mask_o6 = %f, character_mask_o7 = %f, character_mask_o8 = %f WHERE character_id = %d",fOffsetX,fOffsetY,fOffsetZ,fRotX,fRotY,fRotZ,fScaleX,fScaleY,fScaleZ,Character_GetId(playerid)));
}

static Mask_Shop(playerid,token)
{
    yield 1;
    new response[DIALOG_RESPONSE];
    Picker_Begin(playerid);
    Picker_Add(playerid,18919,"White Bandana ($5.00)");
    Picker_Add(playerid,18912,"Black Bandana ($7.00)");
    Picker_Add(playerid,18913,"Green Bandana ($7.00)");
    Picker_Add(playerid,18918,"Olive Bandana ($10.00)");
    Picker_Add(playerid,18911,"Skull Bandana ($10.00)");
    await_arr(response) Picker_Show(playerid,"Mask Selection","Select","Cancel");

    if (!Account_IsCurrent(playerid,token))
    {
        return;
    }

    PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
    new pick = response[DIALOG_RESPONSE_LISTITEM] + 1;

    if (!response[DIALOG_RESPONSE_RESPONSE] || pick < 1 || pick > MASK_COUNT)
    {
        return;
    }

    new line[96], price = s_MaskPrices[pick];

    if (!Money_CanAfford(playerid,Money_Make(price)))
    {
        format(line,sizeof(line),"You need at least $%d in order to purchase this.",price);
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        return;
    }

    Money_Take(playerid,Money_Make(price));
    s_MaskOwned[playerid] = pick;
    format(line,sizeof(line),"You've bought a %s bandana for $%d. You can now use /mask.",s_MaskColours[pick],price);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    Mask_Save(playerid);

    if (s_MaskWorn[playerid])
    {
        Mask_Attach(playerid,true);
    }
}

public Mask_ShopDeferred(playerid,token)
{
    Mask_Shop(playerid,token);
    return 1;
}

hook Shop_OnMask(playerid,pointid)
{
    SetTimerEx("Mask_ShopDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
}
