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
#define ATCH_SLOTS (5)
#define ATCH_PRICE (50)
#define ATCH_BONES (18)
#define ATCH_VALUES (9)
#define ATCH_LIST_LEN (1024)
#define ATCH_OFFSET_LIMIT (3.0)
#define ATCH_ROTATION_LIMIT (360.0)
#define ATCH_SCALE_MIN (0.1)
#define ATCH_SCALE_MAX (4.0)

forward Atch_ShopDeferred(playerid,token);
forward Atch_MenuDeferred(playerid,token);
forward Atch_OnLoaded(playerid,token,characterid);

enum e_ATCH
{
    E_ATCH_ARRAY,
    E_ATCH_BONE,
    bool:E_ATCH_VISIBLE,
    Float:E_ATCH_VALUES[ATCH_VALUES]
}

static const s_AtchBones[ATCH_BONES][16] =
{
    "Spine","Head","Left Arm","Right Arm","Left Hand","Right Hand","Left Thigh","Right Thigh","Left Foot","Right Foot","Right Calf","Left Calf","Left Forearm","Right Forearm","Left Shoulder","Right Shoulder","Neck","Jaw"
};

static List:s_AtchSlots[MAX_PLAYERS];
static s_AtchEdit[MAX_PLAYERS];
static s_AtchBuyItem[MAX_PLAYERS];
static s_AtchCharacter[MAX_PLAYERS];

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
static Atch_Blank(row[e_ATCH])
{
    row[E_ATCH_ARRAY] = -1;
    row[E_ATCH_BONE] = 1;
    row[E_ATCH_VISIBLE] = false;

    for (new i = 0;i < ATCH_VALUES;i++)
    {
        row[E_ATCH_VALUES][i] = i >= 6 ? 1.0 : 0.0;
    }
}

static Atch_Free(playerid)
{
    if (list_valid(s_AtchSlots[playerid]))
    {
        list_delete(s_AtchSlots[playerid]);
    }

    s_AtchSlots[playerid] = INVALID_LIST;
    s_AtchEdit[playerid] = -1;
    s_AtchBuyItem[playerid] = -1;
    s_AtchCharacter[playerid] = 0;
}

static Atch_Build(playerid)
{
    Atch_Free(playerid);
    s_AtchSlots[playerid] = list_new();

    for (new i = 0;i < ATCH_SLOTS;i++)
    {
        new row[e_ATCH];
        Atch_Blank(row);
        list_add_arr(s_AtchSlots[playerid],row);
    }
}

stock bool:Atch_IsLoaded(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && list_valid(s_AtchSlots[playerid]);
}

stock bool:Atch_Get(playerid,slot,row[e_ATCH])
{
    if (!Atch_IsLoaded(playerid) || slot < 0 || slot >= ATCH_SLOTS)
    {
        Atch_Blank(row);
        return false;
    }

    list_get_arr(s_AtchSlots[playerid],slot,row);
    return true;
}

static Atch_Set(playerid,slot,const row[e_ATCH])
{
    list_set_arr(s_AtchSlots[playerid],slot,row);
}

stock Atch_FreeSlot(playerid)
{
    for (new i = 0;i < ATCH_SLOTS;i++)
    {
        new row[e_ATCH];

        if (Atch_Get(playerid,i,row) && row[E_ATCH_ARRAY] == -1)
        {
            return i;
        }
    }

    return -1;
}

stock Atch_ThermalInfo(playerid,slot)
{
    new row[e_ATCH];

    if (!Atch_Get(playerid,slot,row) || row[E_ATCH_ARRAY] == -1)
    {
        return -1;
    }

    return g_AtchThermal[row[E_ATCH_ARRAY]];
}

stock bool:Atch_IsVisible(playerid,slot)
{
    new row[e_ATCH];
    return Atch_Get(playerid,slot,row) && row[E_ATCH_VISIBLE];
}

stock Atch_Bone(playerid,slot)
{
    new row[e_ATCH];
    return Atch_Get(playerid,slot,row) ? row[E_ATCH_BONE] : 0;
}

stock Float:Atch_Value(playerid,slot,index)
{
    new row[e_ATCH];

    if (index < 0 || index >= ATCH_VALUES || !Atch_Get(playerid,slot,row))
    {
        return 0.0;
    }

    return row[E_ATCH_VALUES][index];
}

stock Atch_Model(playerid,slot)
{
    new row[e_ATCH];

    if (!Atch_Get(playerid,slot,row) || row[E_ATCH_ARRAY] == -1)
    {
        return -1;
    }

    return g_AtchModel[row[E_ATCH_ARRAY]];
}

static Float:Atch_Clamp(Float:value,Float:low,Float:high)
{
    if (value < low)
    {
        return low;
    }

    return value > high ? high : value;
}

static Atch_Place(playerid,slot,const row[e_ATCH])
{
    SetPlayerAttachedObject(playerid,slot,g_AtchModel[row[E_ATCH_ARRAY]],row[E_ATCH_BONE],row[E_ATCH_VALUES][0],row[E_ATCH_VALUES][1],row[E_ATCH_VALUES][2],row[E_ATCH_VALUES][3],row[E_ATCH_VALUES][4],row[E_ATCH_VALUES][5],row[E_ATCH_VALUES][6],row[E_ATCH_VALUES][7],row[E_ATCH_VALUES][8]);
}

static Atch_Show(playerid,slot)
{
    new row[e_ATCH];
    Atch_Get(playerid,slot,row);
    Atch_Place(playerid,slot,row);
}

static Atch_Apply(playerid,slot)
{
    new row[e_ATCH];
    Atch_Get(playerid,slot,row);

    if (row[E_ATCH_ARRAY] == -1 || !row[E_ATCH_VISIBLE])
    {
        RemovePlayerAttachedObject(playerid,slot);
        return;
    }

    Atch_Show(playerid,slot);
}

stock Atch_Resync(playerid)
{
    if (!Atch_IsLoaded(playerid))
    {
        return;
    }

    for (new i = 0;i < ATCH_SLOTS;i++)
    {
        if (s_AtchEdit[playerid] != i)
        {
            Atch_Apply(playerid,i);
        }
    }
}

static Atch_Save(playerid,slot)
{
    new row[e_ATCH];
    Atch_Get(playerid,slot,row);
    mysql_tquery_s(g_Mysql,str_format("INSERT INTO attachments (attach_character_id, attach_character_attach_id, attach_character_index, attach_character_array, attach_character_bone, attach_character_offsetx, attach_character_offsety, attach_character_offsetz, attach_character_rotx, attach_character_roty, attach_character_rotz, attach_character_scalex, attach_character_scaley, attach_character_scalez, attach_character_visible) VALUES (%d, %d, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %d) ON DUPLICATE KEY UPDATE attach_character_index = VALUES(attach_character_index), attach_character_array = VALUES(attach_character_array), attach_character_bone = VALUES(attach_character_bone), attach_character_offsetx = VALUES(attach_character_offsetx), attach_character_offsety = VALUES(attach_character_offsety), attach_character_offsetz = VALUES(attach_character_offsetz), attach_character_rotx = VALUES(attach_character_rotx), attach_character_roty = VALUES(attach_character_roty), attach_character_rotz = VALUES(attach_character_rotz), attach_character_scalex = VALUES(attach_character_scalex), attach_character_scaley = VALUES(attach_character_scaley), attach_character_scalez = VALUES(attach_character_scalez), attach_character_visible = VALUES(attach_character_visible)",s_AtchCharacter[playerid],slot,slot,row[E_ATCH_ARRAY],row[E_ATCH_BONE],row[E_ATCH_VALUES][0],row[E_ATCH_VALUES][1],row[E_ATCH_VALUES][2],row[E_ATCH_VALUES][3],row[E_ATCH_VALUES][4],row[E_ATCH_VALUES][5],row[E_ATCH_VALUES][6],row[E_ATCH_VALUES][7],row[E_ATCH_VALUES][8],row[E_ATCH_VISIBLE] ? 1 : 0));
}

static Atch_Load(playerid,characterid)
{
    Atch_Build(playerid);
    s_AtchCharacter[playerid] = characterid;
    mysql_tquery_s(g_Mysql,str_format("SELECT attach_character_attach_id, attach_character_array, attach_character_bone, attach_character_offsetx, attach_character_offsety, attach_character_offsetz, attach_character_rotx, attach_character_roty, attach_character_rotz, attach_character_scalex, attach_character_scaley, attach_character_scalez, attach_character_visible FROM attachments WHERE attach_character_id = %d",characterid),"Atch_OnLoaded","ddd",playerid,Account_GetToken(playerid),characterid);
}

public Atch_OnLoaded(playerid,token,characterid)
{
    if (!Account_IsCurrent(playerid,token) || !Atch_IsLoaded(playerid) || s_AtchCharacter[playerid] != characterid)
    {
        return 1;
    }

    static const columns[ATCH_VALUES][28] =
    {
        "attach_character_offsetx","attach_character_offsety","attach_character_offsetz","attach_character_rotx","attach_character_roty","attach_character_rotz","attach_character_scalex","attach_character_scaley","attach_character_scalez"
    };

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new slot, row[e_ATCH], visible;
        cache_get_value_name_int(i,"attach_character_attach_id",slot);

        if (slot < 0 || slot >= ATCH_SLOTS)
        {
            continue;
        }

        Atch_Blank(row);
        cache_get_value_name_int(i,"attach_character_array",row[E_ATCH_ARRAY]);
        cache_get_value_name_int(i,"attach_character_bone",row[E_ATCH_BONE]);
        cache_get_value_name_int(i,"attach_character_visible",visible);

        for (new v = 0;v < ATCH_VALUES;v++)
        {
            cache_get_value_name_float(i,columns[v],row[E_ATCH_VALUES][v]);
        }

        if (row[E_ATCH_ARRAY] < -1 || row[E_ATCH_ARRAY] >= ATCH_ITEMS)
        {
            row[E_ATCH_ARRAY] = -1;
        }

        if (row[E_ATCH_BONE] < 1 || row[E_ATCH_BONE] > ATCH_BONES)
        {
            row[E_ATCH_BONE] = 1;
        }

        row[E_ATCH_VISIBLE] = visible != 0 && row[E_ATCH_ARRAY] != -1;
        Atch_Set(playerid,slot,row);
    }

    Atch_Resync(playerid);
    return 1;
}

static Atch_BoneList(body[],size = sizeof(body))
{
    body[0] = EOS;

    for (new i = 0;i < ATCH_BONES;i++)
    {
        if (i > 0)
        {
            strcat(body,"\n",size);
        }

        strcat(body,s_AtchBones[i],size);
    }
}

static bool:Atch_BadgeItem(item)
{
    new model = g_AtchModel[item];
    return model == 19347 || model == 19774 || model == 19775 || model == 19776;
}

static Atch_BeginEdit(playerid,slot,bool:buying,item = -1)
{
    s_AtchEdit[playerid] = slot;
    s_AtchBuyItem[playerid] = buying ? item : -1;
    EditAttachedObject(playerid,slot);
}

static Atch_Shop(playerid,token)
{
    yield 1;
    new characterid = Character_GetId(playerid);

    for (;;)
    {
        new response[DIALOG_RESPONSE];
        Picker_Begin(playerid);

        for (new i = 0;i < ATCH_ITEMS;i++)
        {
            new group = g_AtchPreviewGroup[i];
            Picker_Add(playerid,g_AtchModel[i],g_AtchName[i],g_AtchPreview[group][0],g_AtchPreview[group][1],g_AtchPreview[group][2],g_AtchPreview[group][3]);
        }

        await_arr(response) Picker_Show(playerid,"Attachments Store","Select","Cancel");

        if (!Account_IsCurrent(playerid,token) || Character_GetId(playerid) != characterid || !response[DIALOG_RESPONSE_RESPONSE])
        {
            return;
        }

        new item = response[DIALOG_RESPONSE_LISTITEM];

        if (item < 0 || item >= ATCH_ITEMS)
        {
            return;
        }

        if (!Money_CanAfford(playerid,ATCH_PRICE))
        {
            SendServerMessage(playerid,"You don't have enough money. All attachments cost $0.50!",MSG_TYPE_ERROR);
            return;
        }

        if (Atch_BadgeItem(item) && !Posse_IsLawMember(playerid))
        {
            SendServerMessage(playerid,"You need to be in a law enforcement posse to buy this attachment.",MSG_TYPE_ERROR);
            continue;
        }

        new bones[ATCH_BONES * 16];
        Atch_BoneList(bones);
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,"Choose Attachment Bone",bones,"Select","Cancel");

        if (!Account_IsCurrent(playerid,token) || Character_GetId(playerid) != characterid)
        {
            return;
        }

        if (!response[DIALOG_RESPONSE_RESPONSE])
        {
            continue;
        }

        new bone = response[DIALOG_RESPONSE_LISTITEM] + 1;

        if (bone < 1 || bone > ATCH_BONES)
        {
            return;
        }

        SendServerMessage(playerid,"Adjust the model to your needs. Once you click save, the money will be taken from you.",MSG_TYPE_INFO);
        new slot = Atch_FreeSlot(playerid);

        if (slot == -1)
        {
            SendServerMessage(playerid,"You don't seem to have a free attachment slot. Please unequip an item first.",MSG_TYPE_ERROR);
            return;
        }

        new row[e_ATCH];
        Atch_Blank(row);
        row[E_ATCH_ARRAY] = item;
        row[E_ATCH_BONE] = bone;
        Atch_Place(playerid,slot,row);
        Atch_BeginEdit(playerid,slot,true,item);
        return;
    }
}

static Atch_Menu(playerid,token)
{
    yield 1;
    new characterid = Character_GetId(playerid), phase = 0, slot = -1;

    for (;;)
    {
        new response[DIALOG_RESPONSE], row[e_ATCH];

        if (phase == 0)
        {
            new body[ATCH_LIST_LEN];
            strcopy(body,"ID \t Name",sizeof(body));

            for (new i = 0;i < ATCH_SLOTS;i++)
            {
                new line[ATCH_NAME_LEN + 24];
                Atch_Get(playerid,i,row);

                if (row[E_ATCH_ARRAY] == -1)
                {
                    format(line,sizeof(line),"\nNone");
                }
                else
                {
                    format(line,sizeof(line),"\n%d \t %s%s",i,g_AtchName[row[E_ATCH_ARRAY]],row[E_ATCH_VISIBLE] ? (" [WEARING]") : (""));
                }

                strcat(body,line);
            }

            await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_TABLIST_HEADERS,"Display Attachments",body,"Continue","Cancel");

            if (!Account_IsCurrent(playerid,token) || Character_GetId(playerid) != characterid || !response[DIALOG_RESPONSE_RESPONSE])
            {
                return;
            }

            slot = response[DIALOG_RESPONSE_LISTITEM];
            Atch_Get(playerid,slot,row);

            if (slot < 0 || slot >= ATCH_SLOTS || row[E_ATCH_ARRAY] == -1)
            {
                SendServerMessage(playerid,"You don't have an attachment in this slot.",MSG_TYPE_ERROR);
                continue;
            }

            phase = 1;
            continue;
        }

        if (phase == 1)
        {
            await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_TABLIST_HEADERS,"Display Attachments: Edit Menu","Choose an action\n(Un)equip Attachment\nModify Attachment\nDiscard Attachment","Continue","Back");

            if (!Account_IsCurrent(playerid,token) || Character_GetId(playerid) != characterid)
            {
                return;
            }

            if (!response[DIALOG_RESPONSE_RESPONSE])
            {
                phase = 0;
                continue;
            }

            Atch_Get(playerid,slot,row);

            if (row[E_ATCH_ARRAY] == -1 || s_AtchEdit[playerid] != -1)
            {
                phase = 0;
                continue;
            }

            new line[96];

            switch (response[DIALOG_RESPONSE_LISTITEM])
            {
                case 0:
                {
                    row[E_ATCH_VISIBLE] = !row[E_ATCH_VISIBLE];
                    Atch_Set(playerid,slot,row);
                    Atch_Apply(playerid,slot);
                    Atch_Save(playerid,slot);
                    format(line,sizeof(line),"You have %s your \"%s\".",row[E_ATCH_VISIBLE] ? ("equipped") : ("unequipped"),g_AtchName[row[E_ATCH_ARRAY]]);
                    SendServerMessage(playerid,line,MSG_TYPE_INFO);
                    phase = 0;
                }
                case 1:
                {
                    phase = 2;
                }
                case 2:
                {
                    format(line,sizeof(line),"You have removed your \"%s\".",g_AtchName[row[E_ATCH_ARRAY]]);
                    SendServerMessage(playerid,line,MSG_TYPE_INFO);
                    new name[MAX_PLAYER_NAME + 1];
                    GetPlayerName(playerid,name,sizeof(name));
                    Log_Info("money/clothing_abuse","%s has sold their attachment. If continued use, they are trying to do the money bug (+15$)",name);
                    RemovePlayerAttachedObject(playerid,slot);
                    Atch_Blank(row);
                    Atch_Set(playerid,slot,row);
                    Atch_Save(playerid,slot);
                    return;
                }
                default:
                {
                    phase = 0;
                }
            }

            continue;
        }

        if (phase == 2)
        {
            await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_TABLIST_HEADERS,"Display Attachments","Choose an action\nEdit placement\nChange bone","Continue","Back");

            if (!Account_IsCurrent(playerid,token) || Character_GetId(playerid) != characterid)
            {
                return;
            }

            if (!response[DIALOG_RESPONSE_RESPONSE])
            {
                phase = 0;
                continue;
            }

            Atch_Get(playerid,slot,row);

            if (row[E_ATCH_ARRAY] == -1 || s_AtchEdit[playerid] != -1)
            {
                phase = 0;
                continue;
            }

            if (response[DIALOG_RESPONSE_LISTITEM] == 0)
            {
                Atch_Show(playerid,slot);
                Atch_BeginEdit(playerid,slot,false);
                return;
            }

            phase = 3;
            continue;
        }

        new bones[ATCH_BONES * 16 + 16];
        strcopy(bones,"Select a bone\n",sizeof(bones));
        new list[ATCH_BONES * 16];
        Atch_BoneList(list);
        strcat(bones,list);
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_TABLIST_HEADERS,"Display Attachments: Editing Bones",bones,"Continue","Back");

        if (!Account_IsCurrent(playerid,token) || Character_GetId(playerid) != characterid)
        {
            return;
        }

        if (!response[DIALOG_RESPONSE_RESPONSE])
        {
            phase = 0;
            continue;
        }

        Atch_Get(playerid,slot,row);

        if (row[E_ATCH_ARRAY] == -1 || response[DIALOG_RESPONSE_LISTITEM] < 0 || response[DIALOG_RESPONSE_LISTITEM] >= ATCH_BONES)
        {
            phase = 0;
            continue;
        }

        new line[96];
        row[E_ATCH_BONE] = response[DIALOG_RESPONSE_LISTITEM] + 1;
        Atch_Set(playerid,slot,row);
        Atch_Apply(playerid,slot);
        Atch_Save(playerid,slot);
        format(line,sizeof(line),"You have changed the bone of your \"%s\" to %s",g_AtchName[row[E_ATCH_ARRAY]],s_AtchBones[row[E_ATCH_BONE] - 1]);
        SendServerMessage(playerid,line,MSG_TYPE_INFO);
        return;
    }
}

public Atch_ShopDeferred(playerid,token)
{
    Atch_Shop(playerid,token);
    return 1;
}

public Atch_MenuDeferred(playerid,token)
{
    Atch_Menu(playerid,token);
    return 1;
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
CMD:attachments(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Atch_IsLoaded(playerid))
    {
        SendServerMessage(playerid,"You can't do this right now.",MSG_TYPE_ERROR);
        return 1;
    }

    SetTimerEx("Atch_MenuDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
    return 1;
}

ALT:atch=CMD:attachments;

CMD:resyncattachments(cmdid,playerid,params[])
{
    #pragma unused cmdid, params
    Atch_Resync(playerid);
    return 1;
}

CMD:reloadattachments(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (Atch_IsLoaded(playerid))
    {
        Atch_Load(playerid,s_AtchCharacter[playerid]);
    }

    if (Weapons_IsLoaded(playerid))
    {
        Weapons_Attachments(playerid);
    }

    SendServerMessage(playerid,"Reloaded gun and player attachments.",MSG_TYPE_WARN);
    return 1;
}

CMD:reloadgui(cmdid,playerid,params[])
{
    #pragma unused cmdid, params
    Hud_Hide(playerid);
    Hud_Show(playerid);
    SendServerMessage(playerid,"GUI has been reloaded.",MSG_TYPE_INFO);
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
    Migration_Add("attachments-1-toys","CREATE TABLE IF NOT EXISTS attachments (attach_character_id INT UNSIGNED NOT NULL, attach_character_attach_id TINYINT NOT NULL, attach_character_index TINYINT NOT NULL DEFAULT 0, attach_character_array INT NOT NULL DEFAULT -1, attach_character_bone INT NOT NULL DEFAULT 1, attach_character_offsetx FLOAT NOT NULL DEFAULT 0, attach_character_offsety FLOAT NOT NULL DEFAULT 0, attach_character_offsetz FLOAT NOT NULL DEFAULT 0, attach_character_rotx FLOAT NOT NULL DEFAULT 0, attach_character_roty FLOAT NOT NULL DEFAULT 0, attach_character_rotz FLOAT NOT NULL DEFAULT 0, attach_character_scalex FLOAT NOT NULL DEFAULT 1, attach_character_scaley FLOAT NOT NULL DEFAULT 1, attach_character_scalez FLOAT NOT NULL DEFAULT 1, attach_character_visible TINYINT NOT NULL DEFAULT 0, PRIMARY KEY (attach_character_id, attach_character_attach_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}

hook OnPlayerConnect(playerid)
{
    s_AtchSlots[playerid] = INVALID_LIST;
    s_AtchEdit[playerid] = -1;
    s_AtchBuyItem[playerid] = -1;
    s_AtchCharacter[playerid] = 0;
}

hook OnPlayerDisconnect(playerid,reason)
{
    Atch_Free(playerid);
}

hook Character_OnLoad(playerid,characterid)
{
    Atch_Load(playerid,characterid);
}

hook Character_OnUnload(playerid,characterid)
{
    for (new i = 0;i < ATCH_SLOTS;i++)
    {
        RemovePlayerAttachedObject(playerid,i);
    }

    Atch_Free(playerid);
}

hook Shop_OnToys(playerid,pointid)
{
    SetTimerEx("Atch_ShopDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
}

hook OnPlayerEditAttachedObject(playerid,EDIT_RESPONSE:response,index,modelid,boneid,Float:fOffsetX,Float:fOffsetY,Float:fOffsetZ,Float:fRotX,Float:fRotY,Float:fRotZ,Float:fScaleX,Float:fScaleY,Float:fScaleZ)
{
    if (index < 0 || index >= ATCH_SLOTS || s_AtchEdit[playerid] != index || response == EDIT_RESPONSE_UPDATE)
    {
        return;
    }

    new buying = s_AtchBuyItem[playerid];
    s_AtchEdit[playerid] = -1;
    s_AtchBuyItem[playerid] = -1;

    if (response != EDIT_RESPONSE_FINAL)
    {
        SendServerMessage(playerid,"You cancelled editing the object.",MSG_TYPE_INFO);
        RemovePlayerAttachedObject(playerid,index);
        Atch_Apply(playerid,index);
        return;
    }

    new row[e_ATCH];
    Atch_Get(playerid,index,row);

    if (buying != -1)
    {
        if (row[E_ATCH_ARRAY] != -1)
        {
            RemovePlayerAttachedObject(playerid,index);
            return;
        }

        if (!Money_Take(playerid,ATCH_PRICE))
        {
            RemovePlayerAttachedObject(playerid,index);
            SendServerMessage(playerid,"You don't have enough money. All attachments cost $0.50!",MSG_TYPE_ERROR);
            return;
        }

        row[E_ATCH_ARRAY] = buying;
    }

    if (boneid >= 1 && boneid <= ATCH_BONES)
    {
        row[E_ATCH_BONE] = boneid;
    }

    row[E_ATCH_VALUES][0] = Atch_Clamp(fOffsetX,-ATCH_OFFSET_LIMIT,ATCH_OFFSET_LIMIT);
    row[E_ATCH_VALUES][1] = Atch_Clamp(fOffsetY,-ATCH_OFFSET_LIMIT,ATCH_OFFSET_LIMIT);
    row[E_ATCH_VALUES][2] = Atch_Clamp(fOffsetZ,-ATCH_OFFSET_LIMIT,ATCH_OFFSET_LIMIT);
    row[E_ATCH_VALUES][3] = Atch_Clamp(fRotX,-ATCH_ROTATION_LIMIT,ATCH_ROTATION_LIMIT);
    row[E_ATCH_VALUES][4] = Atch_Clamp(fRotY,-ATCH_ROTATION_LIMIT,ATCH_ROTATION_LIMIT);
    row[E_ATCH_VALUES][5] = Atch_Clamp(fRotZ,-ATCH_ROTATION_LIMIT,ATCH_ROTATION_LIMIT);
    row[E_ATCH_VALUES][6] = Atch_Clamp(fScaleX,ATCH_SCALE_MIN,ATCH_SCALE_MAX);
    row[E_ATCH_VALUES][7] = Atch_Clamp(fScaleY,ATCH_SCALE_MIN,ATCH_SCALE_MAX);
    row[E_ATCH_VALUES][8] = Atch_Clamp(fScaleZ,ATCH_SCALE_MIN,ATCH_SCALE_MAX);
    row[E_ATCH_VISIBLE] = true;
    Atch_Set(playerid,index,row);
    Atch_Show(playerid,index);
    Atch_Save(playerid,index);

    if (buying != -1)
    {
        SendServerMessage(playerid,"You've paid $0.50 for the attachment. You can access it by using /attachments.",MSG_TYPE_INFO);
    }
    else
    {
        SendServerMessage(playerid,"You have adjusted your attachment.",MSG_TYPE_INFO);
    }

    #pragma unused modelid
}
