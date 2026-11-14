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
enum _:E_FURNI_MODE
{
    FURNI_MODE_NONE = 0,
    FURNI_MODE_ADD,
    FURNI_MODE_EDIT,
    FURNI_MODE_TEXTURE,
    FURNI_MODE_DELETE,
}

static s_FurniMode[MAX_PLAYERS];
static s_FurniObject[MAX_PLAYERS];
static s_FurniModel[MAX_PLAYERS];
static s_FurniPoint[MAX_PLAYERS];
static s_FurniEditing[MAX_PLAYERS];
static Text3D:s_FurniLabels[MAX_PLAYERS][FURNITURE_LIMIT];

forward Furniture_MenuDeferred(playerid,token,pointid);
forward Furniture_TextureDeferred(playerid,token,furnitureid);
forward Furniture_DeleteDeferred(playerid,token,furnitureid);

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
stock Furniture_GetMode(playerid)
{
    return s_FurniMode[playerid];
}

stock Furniture_GetBuilderObject(playerid)
{
    return s_FurniObject[playerid];
}

stock Furniture_GetEditing(playerid)
{
    return s_FurniEditing[playerid];
}

static Furniture_HideLabels(playerid)
{
    for (new i = 0;i < FURNITURE_LIMIT;i++)
    {
        if (s_FurniLabels[playerid][i] != Text3D:0)
        {
            DestroyDynamic3DTextLabel(DynamicText3D:s_FurniLabels[playerid][i]);
            s_FurniLabels[playerid][i] = Text3D:0;
        }
    }
}

static Furniture_ShowLabels(playerid,pointid)
{
    Furniture_HideLabels(playerid);
    new slot = 0;

    for (new Iter:it = Furniture_Iterator();iter_inside(it) && slot < FURNITURE_LIMIT;iter_move_next(it))
    {
        new furniture[e_FURNITURE], text[24];
        iter_get_arr(it,furniture);

        if (furniture[E_FURNITURE_POINT] != pointid)
        {
            continue;
        }

        format(text,sizeof(text),"ID: %d",iter_get_key(it));
        s_FurniLabels[playerid][slot++] = Text3D:CreateDynamic3DTextLabel(text,COLOR_DEFAULT,furniture[E_FURNITURE_X],furniture[E_FURNITURE_Y],furniture[E_FURNITURE_Z] + 0.5,FURNITURE_LABEL_RANGE,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,furniture[E_FURNITURE_WORLD],furniture[E_FURNITURE_INTERIOR],playerid);
    }
}

stock Furniture_Reset(playerid)
{
    if (s_FurniMode[playerid] == FURNI_MODE_ADD && s_FurniObject[playerid] != 0)
    {
        DestroyDynamicObject(STREAMER_TAG_OBJECT:s_FurniObject[playerid]);
    }

    if (s_FurniMode[playerid] != FURNI_MODE_NONE)
    {
        CancelEdit(playerid);
    }

    Furniture_HideLabels(playerid);
    s_FurniMode[playerid] = FURNI_MODE_NONE;
    s_FurniObject[playerid] = 0;
    s_FurniModel[playerid] = 0;
    s_FurniPoint[playerid] = 0;
    s_FurniEditing[playerid] = 0;
}

stock Furniture_Open(playerid,pointid)
{
    SetTimerEx("Furniture_MenuDeferred",0,false,"ddd",playerid,Account_GetToken(playerid),pointid);
}

static Furniture_StartAdd(playerid,pointid,model)
{
    new Float:x, Float:y, Float:z, Float:angle;
    GetPlayerPos(playerid,x,y,z);
    GetPlayerFacingAngle(playerid,angle);
    x += FURNITURE_FRONT_DISTANCE * floatsin(-angle,degrees);
    y += FURNITURE_FRONT_DISTANCE * floatcos(-angle,degrees);
    s_FurniMode[playerid] = FURNI_MODE_ADD;
    s_FurniPoint[playerid] = pointid;
    s_FurniModel[playerid] = model;
    s_FurniObject[playerid] = _:CreateDynamicObject(model,x,y,z,0.0,0.0,0.0,GetPlayerVirtualWorld(playerid),GetPlayerInterior(playerid));
    EditDynamicObject(playerid,STREAMER_TAG_OBJECT:s_FurniObject[playerid]);
    SendServerMessage(playerid,"Press \"ESC\" to cancel furniture placement. Press the save icon to confirm placement and purchase of furniture.",MSG_TYPE_INFO);
}

static Furniture_AddMenu(playerid,pointid)
{
    new token = Account_GetToken(playerid);

    if (!Money_CanAfford(playerid,FURNITURE_PRICE))
    {
        SendServerMessage(playerid,"You need at least $0.25 to buy furniture.",MSG_TYPE_ERROR);
        return;
    }

    if (Furniture_Count(pointid) >= FURNITURE_LIMIT)
    {
        SendServerMessage(playerid,"You're at the furniture limit (100), you cannot add anymore furniture.",MSG_TYPE_ERROR);
        return;
    }

    for (;;)
    {
        new response[DIALOG_RESPONSE];
        Picker_Begin(playerid);
        Picker_Add(playerid,18635,"Construction");
        Picker_Add(playerid,19996,"House Furniture");
        Picker_Add(playerid,18631,"Other");
        await_arr(response) Picker_Show(playerid,"Furniture - Pick A Catagory (All furniture costs $0.25)","Select","Exit");

        if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE])
        {
            return;
        }

        new category = response[DIALOG_RESPONSE_LISTITEM], title[64];
        Picker_Begin(playerid);

        for (new i = 0,count = Furniture_GetItemCount(category);i < count;i++)
        {
            new item[e_FURNI_ITEM];
            Furniture_GetItem(category,i,item);
            Picker_Add(playerid,item[E_FURNI_ITEM_MODEL],item[E_FURNI_ITEM_NAME]);
        }

        switch (category)
        {
            case FURNITURE_CATEGORY_CONSTRUCTION:
            {
                title = "Construction Furniture (All furniture costs $0.25)";
            }
            case FURNITURE_CATEGORY_HOUSE:
            {
                title = "House Furniture (All furniture costs $0.25)";
            }
            default:
            {
                title = "Other Furniture (All furniture costs $0.25)";
            }
        }

        new picked[DIALOG_RESPONSE];
        await_arr(picked) Picker_Show(playerid,title,"Select","Exit");

        if (!Account_IsCurrent(playerid,token))
        {
            return;
        }

        if (!picked[DIALOG_RESPONSE_RESPONSE])
        {
            continue;
        }

        new item[e_FURNI_ITEM];

        if (Furniture_GetItem(category,picked[DIALOG_RESPONSE_LISTITEM],item))
        {
            Furniture_StartAdd(playerid,pointid,item[E_FURNI_ITEM_MODEL]);
        }

        return;
    }
}

static Furniture_Menu(playerid,pointid)
{
    yield 1;

    new token = Account_GetToken(playerid), response[DIALOG_RESPONSE];
    Furniture_Reset(playerid);
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,"Furniture Menu","Add Furniture\nEdit Furniture\nRemove Furniture","Select","Exit");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE] || !Point_IsOwner(playerid,pointid) || Point_GetPlayerPoint(playerid) != pointid)
    {
        return;
    }

    switch (response[DIALOG_RESPONSE_LISTITEM])
    {
        case 0:
        {
            Furniture_AddMenu(playerid,pointid);
        }
        case 1:
        {
            new picked[DIALOG_RESPONSE];
            await_arr(picked) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,"Edit Furniture - Select Edit Type","Furniture Placement\nFurniture Texture","Select","Exit");

            if (!Account_IsCurrent(playerid,token) || !picked[DIALOG_RESPONSE_RESPONSE])
            {
                return;
            }

            s_FurniMode[playerid] = picked[DIALOG_RESPONSE_LISTITEM] == 0 ? FURNI_MODE_EDIT : FURNI_MODE_TEXTURE;
            s_FurniPoint[playerid] = pointid;
            Furniture_ShowLabels(playerid,pointid);
            SelectObject(playerid);
            SendServerMessage(playerid,picked[DIALOG_RESPONSE_LISTITEM] == 0 ? ("Select the furniture object you want to move.") : ("Select the furniture object you want to edit."),MSG_TYPE_INFO);
        }
        case 2:
        {
            s_FurniMode[playerid] = FURNI_MODE_DELETE;
            s_FurniPoint[playerid] = pointid;
            Furniture_ShowLabels(playerid,pointid);
            SelectObject(playerid);
            SendServerMessage(playerid,"Click on the furniture object you wish to delete.",MSG_TYPE_INFO);
        }
    }
}

static Furniture_TextureFlow(playerid,furnitureid)
{
    yield 1;

    new token = Account_GetToken(playerid), body[512], response[DIALOG_RESPONSE];

    for (new i = 0;i < FURNITURE_MATERIAL_SLOTS;i++)
    {
        format(body,sizeof(body),"%sMaterial Index %d\n",body,i);
    }

    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,"Furniture Edit - Material Indexes",body,"Select","Exit");

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE] || !Furniture_Exists(furnitureid))
    {
        return;
    }

    new slot = response[DIALOG_RESPONSE_LISTITEM], list[1024], picked[DIALOG_RESPONSE];

    for (new i = 0,count = Furniture_GetMaterialCount();i < count;i++)
    {
        new material[e_FURNI_MATERIAL];
        Furniture_GetMaterial(i,material);
        format(list,sizeof(list),"%s%s\n",list,material[E_FURNI_MATERIAL_NAME]);
    }

    await_arr(picked) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,"Furniture Texture - Select Texture",list,"Confirm","Cancel");

    if (!Account_IsCurrent(playerid,token) || !picked[DIALOG_RESPONSE_RESPONSE] || !Furniture_Exists(furnitureid) || !Point_IsOwner(playerid,s_FurniPoint[playerid]))
    {
        return;
    }

    if (Furniture_SetTexture(furnitureid,slot,picked[DIALOG_RESPONSE_LISTITEM]))
    {
        SendServerMessage(playerid,"You've successfully retextured a furniture object.",MSG_TYPE_INFO);
    }
}

static Furniture_DeleteFlow(playerid,furnitureid)
{
    yield 1;

    new token = Account_GetToken(playerid), response[DIALOG_RESPONSE];
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"Furniture Deletion","WARNING: You've selected a furniture object to delete.\nThis dialog is to prevent accidental deletion of a furniture object.\nIf you're sure about your decision, click \"Confirm\".","Confirm","Cancel");

    if (Account_IsCurrent(playerid,token) && !response[DIALOG_RESPONSE_RESPONSE])
    {
        SendServerMessage(playerid,"You've cancelled removing a furniture object.",MSG_TYPE_WARN);
        return;
    }

    if (!Account_IsCurrent(playerid,token) || !response[DIALOG_RESPONSE_RESPONSE] || !Furniture_Exists(furnitureid) || !Point_IsOwner(playerid,s_FurniPoint[playerid]))
    {
        return;
    }

    Furniture_Delete(furnitureid);
    SendServerMessage(playerid,"You've successfully deleted a furniture object.",MSG_TYPE_INFO);
    Furniture_HideLabels(playerid);
    s_FurniMode[playerid] = FURNI_MODE_NONE;
}

stock bool:Furniture_Pick(playerid,furnitureid)
{
    new furniture[e_FURNITURE], pointid = s_FurniPoint[playerid];

    if (s_FurniMode[playerid] != FURNI_MODE_EDIT && s_FurniMode[playerid] != FURNI_MODE_TEXTURE && s_FurniMode[playerid] != FURNI_MODE_DELETE)
    {
        return false;
    }

    if (!Furniture_Get(furnitureid,furniture) || furniture[E_FURNITURE_POINT] != pointid || Point_GetPlayerPoint(playerid) != pointid || !Point_IsOwner(playerid,pointid))
    {
        return false;
    }

    new token = Account_GetToken(playerid);

    switch (s_FurniMode[playerid])
    {
        case FURNI_MODE_EDIT:
        {
            s_FurniEditing[playerid] = furnitureid;
            Furniture_HideLabels(playerid);
            EditDynamicObject(playerid,STREAMER_TAG_OBJECT:furniture[E_FURNITURE_OBJECT]);
            SendServerMessage(playerid,"Move the furniture object and click the \"Save\" icon to save its placement.",MSG_TYPE_INFO);
        }
        case FURNI_MODE_TEXTURE:
        {
            Furniture_HideLabels(playerid);
            SetTimerEx("Furniture_TextureDeferred",0,false,"ddd",playerid,token,furnitureid);
        }
        case FURNI_MODE_DELETE:
        {
            SetTimerEx("Furniture_DeleteDeferred",0,false,"ddd",playerid,token,furnitureid);
        }
    }

    return true;
}

static Furniture_SetObjectMode(playerid,const params[],mode,const usage[])
{
    new furnitureid;

    if (s_FurniMode[playerid] != mode && !(mode == FURNI_MODE_EDIT && s_FurniMode[playerid] == FURNI_MODE_TEXTURE))
    {
        return;
    }

    if (sscanf(params,"d",furnitureid))
    {
        SendServerMessage(playerid,usage,MSG_TYPE_ERROR);
        return;
    }

    if (furnitureid < 0)
    {
        SendServerMessage(playerid,"Furniture IDs cannot be negative.",MSG_TYPE_ERROR);
        return;
    }

    if (!Furniture_Pick(playerid,furnitureid))
    {
        SendServerMessage(playerid,"Invalid furniture ID.",MSG_TYPE_ERROR);
    }
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
CMD:editfurnitureobject(cmdid,playerid,params[])
{
    #pragma unused cmdid

    Furniture_SetObjectMode(playerid,params,FURNI_MODE_EDIT,"Syntax: /editfurni(ture)object [id]");
    return 1;
}

ALT:editfurniobject=CMD:editfurnitureobject;

CMD:removefurnitureobject(cmdid,playerid,params[])
{
    #pragma unused cmdid

    Furniture_SetObjectMode(playerid,params,FURNI_MODE_DELETE,"Syntax: /removefurni(ture)object [id]");
    return 1;
}

ALT:removefurniobject=CMD:removefurnitureobject;

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
    s_FurniMode[playerid] = FURNI_MODE_NONE;
    s_FurniObject[playerid] = 0;
    s_FurniEditing[playerid] = 0;
    s_FurniPoint[playerid] = 0;

    for (new i = 0;i < FURNITURE_LIMIT;i++)
    {
        s_FurniLabels[playerid][i] = Text3D:0;
    }
}

hook OnPlayerDisconnect(playerid,reason)
{
    Furniture_Reset(playerid);
}

hook Point_OnFurniture(playerid,pointid)
{
    Furniture_Open(playerid,pointid);
}

hook Point_OnLeft(playerid,pointid)
{
    if (s_FurniMode[playerid] != FURNI_MODE_NONE)
    {
        Furniture_Reset(playerid);
    }
}

hook Point_OnCleared(pointid)
{
    Furniture_DeleteAll(pointid);
}

hook Point_OnRemoved(pointid)
{
    Furniture_DeleteAll(pointid);
}

hook OnPlayerEditDynamicObject(playerid,STREAMER_TAG_OBJECT:objectid,response,Float:x,Float:y,Float:z,Float:rx,Float:ry,Float:rz)
{
    if (s_FurniMode[playerid] == FURNI_MODE_ADD && s_FurniObject[playerid] != 0 && _:objectid == s_FurniObject[playerid])
    {
        if (response == 2)
        {
            return;
        }

        new pointid = s_FurniPoint[playerid], model = s_FurniModel[playerid];
        DestroyDynamicObject(objectid);
        s_FurniObject[playerid] = 0;
        s_FurniMode[playerid] = FURNI_MODE_NONE;

        if (response == 0)
        {
            return;
        }

        switch (Furniture_Place(playerid,pointid,model,x,y,z,rx,ry,rz))
        {
            case FURNITURE_LIMIT_REACHED:
            {
                SendServerMessage(playerid,"You're at the furniture limit (100), you cannot add anymore furniture.",MSG_TYPE_ERROR);
            }
            case FURNITURE_TOO_POOR:
            {
                SendServerMessage(playerid,"You need at least $0.25 to buy furniture.",MSG_TYPE_ERROR);
            }
            case FURNITURE_NOT_INSIDE:
            {
                SendServerMessage(playerid,"You can only place furniture inside your own house.",MSG_TYPE_ERROR);
            }
            case FURNITURE_NOT_OWNER:
            {
                SendServerMessage(playerid,"You don't own this property.",MSG_TYPE_ERROR);
            }
            case FURNITURE_FAILED:
            {
                SendServerMessage(playerid,"Something went wrong, try again later.",MSG_TYPE_ERROR);
            }
            default:
            {
                SendServerMessage(playerid,"You've bought a piece of furniture for $0.25.",MSG_TYPE_INFO);
            }
        }

        return;
    }

    if (s_FurniMode[playerid] == FURNI_MODE_EDIT && s_FurniEditing[playerid] != 0)
    {
        new furnitureid = s_FurniEditing[playerid], furniture[e_FURNITURE];

        if (!Furniture_Get(furnitureid,furniture) || furniture[E_FURNITURE_OBJECT] != _:objectid)
        {
            return;
        }

        if (response == 2)
        {
            return;
        }

        s_FurniEditing[playerid] = 0;
        s_FurniMode[playerid] = FURNI_MODE_NONE;

        if (response == 0)
        {
            SetDynamicObjectPos(objectid,furniture[E_FURNITURE_X],furniture[E_FURNITURE_Y],furniture[E_FURNITURE_Z]);
            SetDynamicObjectRot(objectid,furniture[E_FURNITURE_RX],furniture[E_FURNITURE_RY],furniture[E_FURNITURE_RZ]);
            return;
        }

        if (!Furniture_CheckInside(playerid,furniture[E_FURNITURE_POINT],x,y,z))
        {
            SetDynamicObjectPos(objectid,furniture[E_FURNITURE_X],furniture[E_FURNITURE_Y],furniture[E_FURNITURE_Z]);
            SetDynamicObjectRot(objectid,furniture[E_FURNITURE_RX],furniture[E_FURNITURE_RY],furniture[E_FURNITURE_RZ]);
            SendServerMessage(playerid,"You can only place furniture inside your own house.",MSG_TYPE_ERROR);
            return;
        }

        Furniture_Move(furnitureid,x,y,z,rx,ry,rz);
        SendServerMessage(playerid,"You've edited a furniture's placement.",MSG_TYPE_INFO);
    }
}

hook OnPlayerSelectDynamicObject(playerid,STREAMER_TAG_OBJECT:objectid,modelid,Float:x,Float:y,Float:z)
{
    if (s_FurniMode[playerid] == FURNI_MODE_NONE || s_FurniMode[playerid] == FURNI_MODE_ADD)
    {
        return;
    }

    new furnitureid = Furniture_FindByObject(s_FurniPoint[playerid],_:objectid);

    if (furnitureid != 0)
    {
        Furniture_Pick(playerid,furnitureid);
    }
}

public Furniture_MenuDeferred(playerid,token,pointid)
{
    if (Account_IsCurrent(playerid,token))
    {
        Furniture_Menu(playerid,pointid);
    }

    return 1;
}

public Furniture_TextureDeferred(playerid,token,furnitureid)
{
    if (Account_IsCurrent(playerid,token))
    {
        Furniture_TextureFlow(playerid,furnitureid);
    }

    return 1;
}

public Furniture_DeleteDeferred(playerid,token,furnitureid)
{
    if (Account_IsCurrent(playerid,token))
    {
        Furniture_DeleteFlow(playerid,furnitureid);
    }

    return 1;
}
