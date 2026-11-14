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
CMD:respawndeers(cmdid,playerid,params[])
{
    #pragma unused cmdid,params

    if (!Staff_RequireModerator(playerid,E_STAFF_GROUP_GENERAL))
    {
        return 1;
    }

    new line[128], name[ACCOUNT_NAME_LEN];
    Wildlife_RespawnAll();
    Account_GetRoleplayName(playerid,name);
    format(line,sizeof(line),"[DEERS] (%d) %s has respawned all the wildlife.",playerid,name);
    SendModeratorWarning(line,MOD_WARNING_MED);
    return 1;
}

CMD:respawndeer(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid))
    {
        return 1;
    }

    new id;

    if (sscanf(params,"i",id))
    {
        SendServerMessage(playerid,"/respawndeer [id]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Wildlife_IsValid(id))
    {
        SendServerMessage(playerid,"That wildlife id doesn't exist. Valid ids are 0 to 143.",MSG_TYPE_ERROR);
        return 1;
    }

    new line[128], name[ACCOUNT_NAME_LEN];
    Wildlife_Respawn(id);
    Account_GetRoleplayName(playerid,name);
    format(line,sizeof(line),"[DEERS] (%d) %s has respawned wildlife ID %d.",playerid,name,id);
    SendModeratorWarning(line,MOD_WARNING_MED);
    return 1;
}

CMD:gotodeer(cmdid,playerid,params[])
{
    #pragma unused cmdid

    if (!Staff_RequireModerator(playerid))
    {
        return 1;
    }

    new id;

    if (sscanf(params,"i",id))
    {
        SendServerMessage(playerid,"/gotodeer [id]",MSG_TYPE_ERROR);
        return 1;
    }

    if (!Wildlife_IsValid(id))
    {
        SendServerMessage(playerid,"That wildlife id doesn't exist. Valid ids are 0 to 143.",MSG_TYPE_ERROR);
        return 1;
    }

    new Float:x, Float:y, Float:z, line[32];
    Wildlife_GetPosition(id,x,y,z);
    SetPlayerPos(playerid,x,y,z);
    format(line,sizeof(line),"deer id %d",id);
    SendClientMessage(playerid,-1,line);
    return 1;
}
