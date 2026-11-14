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
#define LABEL_TEXT_LEN (256)
#define LABEL_DRAW_RANGE (15.0)
#define LABEL_INSPECT_RANGE (5.0)
#define LABEL_COLOUR (0x5B3A99FF)
#define LABEL_REQUEST_CREATE (0)
#define LABEL_REQUEST_LIST_LEN (4096)

forward Labels_Load();
forward Label_InspectDeferred(playerid,token,id);
forward Label_RequestsDeferred(playerid,token);

enum e_LABEL
{
    E_LABEL_CREATOR,
    E_LABEL_MESSAGE[LABEL_TEXT_LEN],
    Float:E_LABEL_X,
    Float:E_LABEL_Y,
    Float:E_LABEL_Z,
    E_LABEL_INTERIOR,
    E_LABEL_WORLD,
    E_LABEL_HANDLE
}

static Map:s_Labels;
static bool:s_LabelPending[MAX_PLAYERS];
static s_LabelMessage[MAX_PLAYERS][LABEL_TEXT_LEN];
static Float:s_LabelPosition[MAX_PLAYERS][3];
static s_LabelInterior[MAX_PLAYERS];
static s_LabelWorld[MAX_PLAYERS];

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
static Label_Handle(id,label[e_LABEL])
{
    new text[LABEL_TEXT_LEN + 48];
    format(text,sizeof(text),"{c6c6c6}/inspectlabel{5b3a99}\n(* %d) %s",id,label[E_LABEL_MESSAGE]);
    return _:CreateDynamic3DTextLabel(text,LABEL_COLOUR,label[E_LABEL_X],label[E_LABEL_Y],label[E_LABEL_Z],LABEL_DRAW_RANGE,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,label[E_LABEL_WORLD],label[E_LABEL_INTERIOR]);
}

static Label_Register(id,creator,const message[],Float:x,Float:y,Float:z,interior,world)
{
    if (!map_valid(s_Labels))
    {
        s_Labels = map_new();
    }

    if (map_has_key(s_Labels,id))
    {
        return;
    }

    new label[e_LABEL];
    label[E_LABEL_CREATOR] = creator;
    strcopy(label[E_LABEL_MESSAGE],message,LABEL_TEXT_LEN);
    label[E_LABEL_X] = x;
    label[E_LABEL_Y] = y;
    label[E_LABEL_Z] = z;
    label[E_LABEL_INTERIOR] = interior;
    label[E_LABEL_WORLD] = world;
    label[E_LABEL_HANDLE] = Label_Handle(id,label);
    map_set_arr(s_Labels,id,label);
}

static Label_Unregister(id)
{
    new label[e_LABEL];
    map_get_arr(s_Labels,id,label);

    if (IsValidDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:label[E_LABEL_HANDLE]))
    {
        DestroyDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:label[E_LABEL_HANDLE]);
    }

    map_remove(s_Labels,id);
}

static Label_Clear()
{
    if (!map_valid(s_Labels))
    {
        return;
    }

    new ids[256], count;

    for (;;)
    {
        count = 0;

        for (new Iter:it = map_iter(s_Labels);iter_inside(it) && count < sizeof(ids);iter_move_next(it))
        {
            ids[count++] = iter_get_key(it);
        }

        if (count == 0)
        {
            break;
        }

        for (new i = 0;i < count;i++)
        {
            Label_Unregister(ids[i]);
        }
    }
}

stock Label_Count()
{
    return map_valid(s_Labels) ? map_size(s_Labels) : 0;
}

stock bool:Label_Exists(id)
{
    return map_valid(s_Labels) && map_has_key(s_Labels,id);
}

stock bool:Label_Get(id,label[e_LABEL])
{
    if (!Label_Exists(id))
    {
        return false;
    }

    map_get_arr(s_Labels,id,label);
    return true;
}

stock bool:Label_HasRequest(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && s_LabelPending[playerid];
}

static Label_ResetRequest(playerid)
{
    s_LabelPending[playerid] = false;
    s_LabelMessage[playerid][0] = EOS;
    s_LabelPosition[playerid][0] = 0.0;
    s_LabelPosition[playerid][1] = 0.0;
    s_LabelPosition[playerid][2] = 0.0;
    s_LabelInterior[playerid] = 0;
    s_LabelWorld[playerid] = 0;
}

static Label_Reload(bool:boot)
{
    yield 1;
    await mysql_aquery_s(g_Mysql,str_new("SELECT dynamic_label_id, dynamic_label_creator, dynamic_label_message, dynamic_label_x_pos, dynamic_label_y_pos, dynamic_label_z_pos, dynamic_label_interior, dynamic_label_vw FROM dynamic_labels"),false);
    Label_Clear();

    for (new i = 0,rows = cache_num_rows();i < rows;i++)
    {
        new id, creator, message[LABEL_TEXT_LEN], Float:x, Float:y, Float:z, interior, world;
        cache_get_value_name_int(i,"dynamic_label_id",id);
        cache_get_value_name_int(i,"dynamic_label_creator",creator);
        cache_get_value_name(i,"dynamic_label_message",message,LABEL_TEXT_LEN);
        cache_get_value_name_float(i,"dynamic_label_x_pos",x);
        cache_get_value_name_float(i,"dynamic_label_y_pos",y);
        cache_get_value_name_float(i,"dynamic_label_z_pos",z);
        cache_get_value_name_int(i,"dynamic_label_interior",interior);
        cache_get_value_name_int(i,"dynamic_label_vw",world);
        Label_Register(id,creator,message,x,y,z,interior,world);
    }

    Log_Info("labels","Loaded %d dynamic labels",Label_Count());

    if (boot)
    {
        Boot_LoaderDone();
    }
}

#pragma warning push
#pragma warning disable 204
public Labels_Load()
{
    Label_Reload(true);
    return 1;
}
#pragma warning pop

static Label_Create(playerid,token,creator,const message[],Float:x,Float:y,Float:z,interior,world)
{
    yield 1;
    await mysql_aquery_s(g_Mysql,str_format("INSERT INTO dynamic_labels (dynamic_label_creator, dynamic_label_message, dynamic_label_x_pos, dynamic_label_y_pos, dynamic_label_z_pos, dynamic_label_interior, dynamic_label_vw) VALUES (%d, '%e', %f, %f, %f, %d, %d)",creator,message,x,y,z,interior,world),false);
    new id = cache_insert_id();

    if (id < 1)
    {
        return;
    }

    Label_Register(id,creator,message,x,y,z,interior,world);

    if (Account_IsCurrent(playerid,token))
    {
        SendServerMessage(playerid,"Your label creation has been approved.",MSG_TYPE_INFO);
        new line[144], name[MAX_PLAYER_NAME + 1];
        GetPlayerName(playerid,name,sizeof(name));
        format(line,sizeof(line),"[LABELS]: %s (%d) has created dynamic label ID %d.",name,playerid,id);
        SendModeratorWarning(line,MOD_WARNING_MED);
    }
}

static Label_Inspect(playerid,token,id)
{
    yield 1;
    new label[e_LABEL], title[40], response[DIALOG_RESPONSE];
    Label_Get(id,label);
    format(title,sizeof(title),"Dynamic Label ID: %d",id);
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,title,label[E_LABEL_MESSAGE],"Exit","");
    #pragma unused token
}

static Label_Requests(playerid,token)
{
    yield 1;
    new body[LABEL_REQUEST_LIST_LEN], response[DIALOG_RESPONSE], found;
    strcopy(body,"Player\tType\tMessage\n",sizeof(body));

    for (new i = 0;i < MAX_PLAYERS;i++)
    {
        if (!IsPlayerConnected(i) || !s_LabelPending[i])
        {
            continue;
        }

        new line[LABEL_TEXT_LEN + 48], name[MAX_PLAYER_NAME + 1];
        GetPlayerName(i,name,sizeof(name));
        format(line,sizeof(line),"%s (%d)\t%d\t%s\n",name,i,LABEL_REQUEST_CREATE,s_LabelMessage[i]);

        if (strlen(body) + strlen(line) >= sizeof(body))
        {
            break;
        }

        strcat(body,line);
        found++;
    }

    if (!found)
    {
        SendServerMessage(playerid,"There are no label requests.",MSG_TYPE_ERROR);
        return;
    }

    SendServerMessage(playerid,"Label Types:",MSG_TYPE_INFO);
    SendServerMessage(playerid,"0 - Label Creation",MSG_TYPE_INFO);
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_TABLIST_HEADERS,"Label Requests",body,"Exit","");
    #pragma unused token
}

public Label_InspectDeferred(playerid,token,id)
{
    Label_Inspect(playerid,token,id);
    return 1;
}

public Label_RequestsDeferred(playerid,token)
{
    Label_Requests(playerid,token);
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
CMD:createdynamiclabel(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new message[LABEL_TEXT_LEN];

    if (sscanf(params,"s[256]",message))
    {
        SendServerMessage(playerid,"/createdynamiclabel [message]",MSG_TYPE_ERROR);
        return 1;
    }

    if (s_LabelPending[playerid])
    {
        SendServerMessage(playerid,"You already have a label request waiting for staff. Wait for an answer first.",MSG_TYPE_ERROR);
        return 1;
    }

    new Float:x, Float:y, Float:z, line[400], name[MAX_PLAYER_NAME + 1];
    GetPlayerPos(playerid,x,y,z);
    s_LabelPending[playerid] = true;
    strcopy(s_LabelMessage[playerid],message,LABEL_TEXT_LEN);
    s_LabelPosition[playerid][0] = x;
    s_LabelPosition[playerid][1] = y;
    s_LabelPosition[playerid][2] = z;
    s_LabelInterior[playerid] = GetPlayerInterior(playerid);
    s_LabelWorld[playerid] = GetPlayerVirtualWorld(playerid);
    GetPlayerName(playerid,name,sizeof(name));
    format(line,sizeof(line),"[LABELS]: %s (%d) has requested to create a label, use /acceptlabelrequest or /denylabelrequest. Message: %s",name,playerid,message);
    SendModeratorWarning(line,MOD_WARNING_LOW);
    return 1;
}

CMD:inspectlabel(cmdid,playerid,params[])
{
    #pragma unused cmdid

    new id;

    if (sscanf(params,"d",id))
    {
        SendServerMessage(playerid,"/inspectlabel [id]",MSG_TYPE_ERROR);
        return 1;
    }

    if (id < 1)
    {
        SendServerMessage(playerid,"This is not a valid label ID.",MSG_TYPE_ERROR);
        return 1;
    }

    new label[e_LABEL];

    if (!Label_Get(id,label))
    {
        SendServerMessage(playerid,"There was no label found with this ID.",MSG_TYPE_ERROR);
        return 1;
    }

    if (GetPlayerInterior(playerid) != label[E_LABEL_INTERIOR] || GetPlayerVirtualWorld(playerid) != label[E_LABEL_WORLD] || !IsPlayerInRangeOfPoint(playerid,LABEL_INSPECT_RANGE,label[E_LABEL_X],label[E_LABEL_Y],label[E_LABEL_Z]))
    {
        SendServerMessage(playerid,"You're not close enough to inspect this label.",MSG_TYPE_ERROR);
        return 1;
    }

    SetTimerEx("Label_InspectDeferred",0,false,"ddd",playerid,Account_GetToken(playerid),id);
    return 1;
}

CMD:labelrequests(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    SetTimerEx("Label_RequestsDeferred",0,false,"dd",playerid,Account_GetToken(playerid));
    return 1;
}

CMD:acceptlabelrequest(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new targetid;

    if (sscanf(params,"u",targetid))
    {
        SendServerMessage(playerid,"/acceptlabelrequest [playerid/name]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,targetid,"Selected player doesn't exist, they might be offline."))
    {
        return 1;
    }

    if (!s_LabelPending[targetid])
    {
        SendServerMessage(playerid,"That player doesn't have a label request.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[144], name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], message[LABEL_TEXT_LEN], Float:x, Float:y, Float:z, interior = s_LabelInterior[targetid], world = s_LabelWorld[targetid];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    strcopy(message,s_LabelMessage[targetid],LABEL_TEXT_LEN);
    x = s_LabelPosition[targetid][0];
    y = s_LabelPosition[targetid][1];
    z = s_LabelPosition[targetid][2];
    format(line,sizeof(line),"[LABELS]: %s (%d) has approved %s's (%d) label creation request.",name,playerid,targetName,targetid);
    SendModeratorWarning(line,MOD_WARNING_MED);
    Label_ResetRequest(targetid);
    Label_Create(targetid,Account_GetToken(targetid),Account_GetId(targetid),message,x,y,z,interior,world);
    return 1;
}

CMD:denylabelrequest(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new targetid, reason[64];

    if (sscanf(params,"us[64]",targetid,reason))
    {
        SendServerMessage(playerid,"/denylabelrequest [playerid/name] [reason]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Staff_RequireTarget(playerid,targetid,"Selected player doesn't exist, they might be offline."))
    {
        return 1;
    }

    if (!s_LabelPending[targetid])
    {
        SendServerMessage(playerid,"That player doesn't have a label request.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[144], name[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));
    GetPlayerName(targetid,targetName,sizeof(targetName));
    Label_ResetRequest(targetid);
    format(line,sizeof(line),"%s (%d) has denied your label request. Reason: %s",name,playerid,reason);
    SendServerMessage(targetid,line,MSG_TYPE_WARN);
    format(line,sizeof(line),"You've denied %s's (%d) label request.",targetName,targetid);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
    return 1;
}

CMD:deletedynamiclabel(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new id;

    if (sscanf(params,"d",id))
    {
        SendServerMessage(playerid,"/deletedynamiclabel [id (id that's shown in 3d label)]",MSG_TYPE_ERROR);
        return 1;
    }

    if (id < 1)
    {
        SendServerMessage(playerid,"This is not a valid label ID.",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Label_Exists(id))
    {
        SendServerMessage(playerid,"There was no label found with this ID.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[144], name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));
    mysql_tquery_s(g_Mysql,str_format("DELETE FROM dynamic_labels WHERE dynamic_label_id = %d",id));
    Label_Unregister(id);
    format(line,sizeof(line),"%s (%d) has deleted dynamic label ID %d.",name,playerid,id);
    SendModeratorWarning(line,MOD_WARNING_MED);
    return 1;
}

CMD:refreshdynamiclabels(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new line[144], name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid,name,sizeof(name));
    Label_Reload(false);
    format(line,sizeof(line),"%s (%d) has reloaded all dynamic labels.",name,playerid);
    SendModeratorWarning(line,MOD_WARNING_LOW);
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
    Migration_Add("labels-1-dynamic-labels","CREATE TABLE IF NOT EXISTS dynamic_labels (dynamic_label_id INT UNSIGNED NOT NULL AUTO_INCREMENT, dynamic_label_creator INT NOT NULL DEFAULT 0, dynamic_label_message VARCHAR(256) NOT NULL DEFAULT '', dynamic_label_x_pos FLOAT NOT NULL DEFAULT 0, dynamic_label_y_pos FLOAT NOT NULL DEFAULT 0, dynamic_label_z_pos FLOAT NOT NULL DEFAULT 0, dynamic_label_interior INT NOT NULL DEFAULT 0, dynamic_label_vw INT NOT NULL DEFAULT 0, PRIMARY KEY (dynamic_label_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
}

hook OnGameModeInit()
{
    s_Labels = map_new();
    Boot_RegisterLoader("Labels_Load");
}

hook OnPlayerConnect(playerid)
{
    Label_ResetRequest(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Label_ResetRequest(playerid);
}
