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
#define JOB_ACTIONS_PER_REST (10)
#define JOB_COOLDOWN_LOW (300)
#define JOB_COOLDOWN_MID (210)
#define JOB_COOLDOWN_HIGH (150)
#define JOB_KEY_COOLDOWN_MS (1000)
#define JOB_TICK_MS (500)
#define JOB_EXPIRY_TICKS (10)
#define JOB_CIRCLE_SIZE (2.0)
#define JOB_NONE (0)

enum _:E_JOB
{
    E_JOB_NONE = 0,
    E_JOB_FISHING,
    E_JOB_MINING,
    E_JOB_LUMBER,
    E_JOB_COUNT
}

new bool:g_JobLoaded[MAX_PLAYERS];
new g_JobCooldown[MAX_PLAYERS][E_JOB_COUNT];
new g_JobActions[MAX_PLAYERS][E_JOB_COUNT];
new g_JobKind[MAX_PLAYERS];
new g_JobProgress[MAX_PLAYERS];
new g_JobTarget[MAX_PLAYERS];
new STREAMER_TAG_AREA:g_JobCircle[MAX_PLAYERS];
new bool:g_JobWaiting[MAX_PLAYERS];
new bool:g_JobReeling[MAX_PLAYERS];
new STREAMER_TAG_OBJECT:g_JobRope[MAX_PLAYERS];
new g_JobDistance[MAX_PLAYERS];
new g_JobTicket[MAX_PLAYERS];
new g_JobKeyTick[MAX_PLAYERS];
new g_JobFixTick[MAX_PLAYERS];
new g_JobExpiryCount;

forward Jobs_OnAction(playerid,job);
forward Jobs_OnStarted(playerid,job);
forward Jobs_OnLoaded(playerid,token);

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
stock Jobs_RandomEx(minimum,maximum)
{
    return minimum + random(maximum - minimum + 1);
}

stock bool:Jobs_IsLoaded(playerid)
{
    return playerid >= 0 && playerid < MAX_PLAYERS && g_JobLoaded[playerid];
}

stock Jobs_GetKind(playerid)
{
    return g_JobKind[playerid];
}

stock Jobs_GetProgress(playerid)
{
    return g_JobProgress[playerid];
}

stock bool:Jobs_IsFishingWait(playerid)
{
    return g_JobWaiting[playerid];
}

stock bool:Jobs_IsReeling(playerid)
{
    return g_JobReeling[playerid];
}

stock Jobs_GetCooldown(playerid,job)
{
    return job > E_JOB_NONE && job < E_JOB_COUNT ? g_JobCooldown[playerid][job] : 0;
}

stock Jobs_GetActions(playerid,job)
{
    return job > E_JOB_NONE && job < E_JOB_COUNT ? g_JobActions[playerid][job] : 0;
}

stock Jobs_GetCircle(playerid)
{
    return _:g_JobCircle[playerid];
}

stock Jobs_GetRope(playerid)
{
    return _:g_JobRope[playerid];
}

stock Jobs_GetDistance(playerid)
{
    return g_JobDistance[playerid];
}

stock Jobs_ColumnPrefix(job,dest[],size = sizeof(dest))
{
    switch (job)
    {
        case E_JOB_FISHING:
        {
            strcopy(dest,"fish",size);
        }
        case E_JOB_MINING:
        {
            strcopy(dest,"mine",size);
        }
        default:
        {
            strcopy(dest,"wood",size);
        }
    }
}

stock Jobs_Save(playerid,job)
{
    new prefix[8];
    Jobs_ColumnPrefix(job,prefix);
    mysql_tquery_s(g_Mysql,str_format("UPDATE characters SET character_%sactionsleft = %d, character_%scd = %d WHERE character_id = %d",prefix,g_JobActions[playerid][job],prefix,g_JobCooldown[playerid][job],Character_GetId(playerid)));
}

stock Jobs_SetCooldown(playerid,job,until)
{
    g_JobCooldown[playerid][job] = until;
    Jobs_Save(playerid,job);
}

stock Jobs_SetActions(playerid,job,count)
{
    g_JobActions[playerid][job] = count;
    Jobs_Save(playerid,job);
}

stock bool:Jobs_OnCooldown(playerid,job)
{
    return g_JobCooldown[playerid][job] != 0 && g_JobCooldown[playerid][job] > gettime();
}

stock Jobs_SkillFor(job)
{
    switch (job)
    {
        case E_JOB_FISHING:
        {
            return E_SKILL_JOB_FISHING;
        }
        case E_JOB_MINING:
        {
            return E_SKILL_JOB_MINING;
        }
    }

    return E_SKILL_JOB_LUMBER;
}

stock Jobs_Skill(playerid,job)
{
    return Skills_Get(playerid,Jobs_SkillFor(job));
}

stock Jobs_CooldownLength(skill)
{
    if (skill <= 1)
    {
        return JOB_COOLDOWN_LOW;
    }

    if (skill == 2)
    {
        return JOB_COOLDOWN_MID;
    }

    return JOB_COOLDOWN_HIGH;
}

stock bool:Jobs_IsDoing(playerid)
{
    return g_JobKind[playerid] != E_JOB_NONE;
}

stock Jobs_ClearCircle(playerid)
{
    if (_:g_JobCircle[playerid] != INVALID_STREAMER_ID)
    {
        new STREAMER_TAG_AREA:area = g_JobCircle[playerid];
        g_JobCircle[playerid] = STREAMER_TAG_AREA:INVALID_STREAMER_ID;
        DestroyDynamicArea(area);
    }
}

stock Jobs_ClearRope(playerid)
{
    if (_:g_JobRope[playerid] != INVALID_STREAMER_ID)
    {
        new STREAMER_TAG_OBJECT:rope = g_JobRope[playerid];
        g_JobRope[playerid] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
        DestroyDynamicObject(rope);
    }
}

stock Jobs_HidePanel(playerid)
{
    new mode = ActionPanel_GetMode(playerid);

    if (mode == E_ACTION_TYPE_FISH || mode == E_ACTION_TYPE_MINING || mode == E_ACTION_TYPE_LUMBER)
    {
        ActionPanel_Hide(playerid);
    }
}

stock Jobs_Reset(playerid)
{
    g_JobKind[playerid] = E_JOB_NONE;
    g_JobProgress[playerid] = 0;
    g_JobTarget[playerid] = -1;
    g_JobWaiting[playerid] = false;
    g_JobReeling[playerid] = false;
    g_JobDistance[playerid] = 0;
    g_JobTicket[playerid]++;
    Jobs_ClearCircle(playerid);
    Jobs_ClearRope(playerid);
}

stock Jobs_Fix(playerid)
{
    Jobs_Reset(playerid);

    if (IsPlayerConnected(playerid))
    {
        Jobs_HidePanel(playerid);
        ClearAnimations(playerid,SYNC_ALL);
        TogglePlayerControllable(playerid,true);
    }
}

stock Jobs_ResetData(playerid)
{
    g_JobLoaded[playerid] = false;

    for (new job = 0;job < E_JOB_COUNT;job++)
    {
        g_JobCooldown[playerid][job] = 0;
        g_JobActions[playerid][job] = 0;
    }

    g_JobKeyTick[playerid] = 0;
    g_JobFixTick[playerid] = 0;
    Jobs_Reset(playerid);
}

stock bool:Jobs_CountAction(playerid,job)
{
    new tired[64];
    g_JobActions[playerid][job]++;
    pawn_call_public("Jobs_OnAction","dd",playerid,job);

    if (g_JobActions[playerid][job] < JOB_ACTIONS_PER_REST)
    {
        Jobs_Save(playerid,job);
        return false;
    }

    g_JobActions[playerid][job] = 0;
    g_JobCooldown[playerid][job] = gettime() + Jobs_CooldownLength(Jobs_Skill(playerid,job));
    Jobs_Save(playerid,job);

    switch (job)
    {
        case E_JOB_FISHING:
        {
            strcopy(tired,"You feel tired of fishing, so you've decided to stop.");
        }
        case E_JOB_MINING:
        {
            strcopy(tired,"You feel tired of mining, so you've decided to stop.");
        }
        default:
        {
            strcopy(tired,"You feel tired of cutting trees, so you've decided to stop.");
        }
    }

    SendServerMessage(playerid,tired,MSG_TYPE_WARN);
    Jobs_Fix(playerid);
    return true;
}

stock Jobs_ExpireCooldowns(playerid)
{
    for (new job = E_JOB_FISHING;job < E_JOB_COUNT;job++)
    {
        if (g_JobCooldown[playerid][job] != 0 && g_JobCooldown[playerid][job] <= gettime())
        {
            g_JobCooldown[playerid][job] = 0;
            Jobs_Save(playerid,job);

            switch (job)
            {
                case E_JOB_FISHING:
                {
                    SendServerMessage(playerid,"You can now fish again.",MSG_TYPE_INFO);
                }
                case E_JOB_MINING:
                {
                    SendServerMessage(playerid,"You can now mine again.",MSG_TYPE_INFO);
                }
                default:
                {
                    SendServerMessage(playerid,"You can now cut trees again.",MSG_TYPE_INFO);
                }
            }
        }
    }
}

stock Jobs_CheckCooldowns(playerid)
{
    new line[128], count = 0, now = gettime();
    SendServerMessage(playerid,"..:: Job Cooldowns ::..",MSG_TYPE_WARN);
    Jobs_ExpireCooldowns(playerid);

    for (new job = E_JOB_FISHING;job < E_JOB_COUNT;job++)
    {
        if (g_JobCooldown[playerid][job] <= now)
        {
            continue;
        }

        new label[24];

        switch (job)
        {
            case E_JOB_FISHING:
            {
                strcopy(label,"Fishing");
            }
            case E_JOB_MINING:
            {
                strcopy(label,"Mining");
            }
            default:
            {
                strcopy(label,"Wood Cutting");
            }
        }

        format(line,sizeof(line),"%s Cooldown Time Remaining: {FFFFFF} %.02f minutes",label,float(g_JobCooldown[playerid][job] - now) / 60.0);
        SendClientMessage(playerid,COLOR_DEFAULT,line);
        count++;
    }

    if (count == 0)
    {
        SendClientMessage(playerid,COLOR_DEFAULT,"You have no job cooldown timers.");
    }
}

public Jobs_OnAction(playerid,job)
{
    return 1;
}

public Jobs_OnStarted(playerid,job)
{
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
CMD:fixjob(cmdid,playerid,params[])
{
    #pragma unused cmdid,params
    Jobs_Fix(playerid);
    return 1;
}

CMD:checkjobcooldown(cmdid,playerid,params[])
{
    #pragma unused cmdid,params
    Jobs_CheckCooldowns(playerid);
    return 1;
}

ALT:cooldowns=CMD:checkjobcooldown;
ALT:cooldown=CMD:checkjobcooldown;
