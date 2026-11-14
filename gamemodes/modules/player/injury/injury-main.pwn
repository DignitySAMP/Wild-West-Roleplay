#include <pp-hooks>

hook OnMigrationRun()
{
    Migration_Add("injury-1-columns","ALTER TABLE characters ADD COLUMN IF NOT EXISTS character_health FLOAT NOT NULL DEFAULT 100, ADD COLUMN IF NOT EXISTS character_dmgmode TINYINT NOT NULL DEFAULT 0");
}

hook OnGameModeInit()
{
    Corpse_InitPool();
    Timer_Start(Injury_Timer,1000);
    Inventory_RegisterUse(E_ITEM_TYPE_USE,E_ITEM_EXTRA_BANDAGE,"Injury_UseBandage");
}

Timer_Declare(Injury_Timer)
{

    Injury_Tick();
    return 1;
}

public Injury_OnLoaded(playerid,token)
{
    if (!Account_IsCurrent(playerid,token))
    {
        return 1;
    }

    Injury_ResetHealthState(playerid);
    new Float:health = INJURY_MAX_HEALTH, mode = 0;

    if (cache_num_rows() > 0)
    {
        cache_get_value_name_float(0,"character_health",health);
        cache_get_value_name_int(0,"character_dmgmode",mode);
    }

    if (health <= 0.0)
    {
        health = INJURY_MAX_HEALTH;
    }

    Injury_LoadState(playerid,health,mode);
    return 1;
}

public Injury_OnHealthChanged(playerid,Float:health)
{
    return 1;
}

public Injury_OnCollapsed(playerid,issuerid)
{
    return 1;
}

public Injury_OnRevived(playerid,helperid)
{
    return 1;
}

public Injury_OnDied(playerid,issuerid)
{
    return 1;
}

public Injury_OnRespawned(playerid)
{
    return 1;
}

public Injury_OnLegsHurt(playerid)
{
    return 1;
}

hook Character_OnLoad(playerid,characterid)
{
    mysql_tquery_s(g_Mysql,str_format("SELECT character_health, character_dmgmode FROM characters WHERE character_id = %d",characterid),"Injury_OnLoaded","dd",playerid,Account_GetToken(playerid));
}

hook Character_OnUnload(playerid,characterid)
{
    Injury_FlushHealth(playerid);
    Injury_StopBleeding(playerid);
    Injury_ResetWounds(playerid);
    Corpse_RemoveOwned(characterid);
    Injury_ResetHealthState(playerid);
}

hook OnPlayerDisconnect(playerid,reason)
{
    Injury_StopBleeding(playerid);
    Injury_ResetWounds(playerid);
    Injury_ResetHealthState(playerid);
}

hook OnPlayerConnect(playerid)
{
    Injury_InitWounds(playerid);
    Injury_ResetHealthState(playerid);
    Injury_SetBleeding(playerid,false);
}

hook OnPlayerSpawn(playerid)
{
    Injury_StopBleeding(playerid);
    Injury_SetLegs(playerid,false);

    if (Player_IsReady(playerid))
    {
        SetPlayerSkin(playerid,Character_GetSkin(playerid));
        Injury_RefreshClient(playerid);
    }
}

hook Needs_OnHealthDamage(playerid,Float:amount)
{
    Injury_Damage(playerid,amount);
}

hook Staff_OnSetHealth(playerid,Float:health)
{
    Injury_SetHealth(playerid,health,INVALID_PLAYER_ID,false);
}

hook Bounty_OnPickRequest(playerid)
{
    new corpseid = Corpse_FindNear(playerid), corpse[e_CORPSE];

    if (corpseid == 0 || !Corpse_Get(corpseid,corpse))
    {
        SendServerMessage(playerid,"You have not killed your bounty.",MSG_TYPE_ERROR);
        return;
    }

    if (!Bounty_PickCorpse(playerid,corpse[E_CORPSE_NAME]))
    {
        SendServerMessage(playerid,"You are not near the right corpse!",MSG_TYPE_ERROR);
        return;
    }

    new rp[ACCOUNT_NAME_LEN], line[128];
    strcopy(rp,corpse[E_CORPSE_NAME]);

    for (new i = 0;rp[i] != EOS;i++)
    {
        if (rp[i] == '_')
        {
            rp[i] = ' ';
        }
    }

    Corpse_Remove(corpseid);
    format(line,sizeof(line),"You've picked up the corpse of %s.",rp);
    SendServerMessage(playerid,line,MSG_TYPE_INFO);
}

public Injury_UseBandage(playerid,uid,item,extra)
{
    if (Injury_GetMode(playerid) != INJURY_MODE_NORMAL)
    {
        SendServerMessage(playerid,"You can't use this right now.",MSG_TYPE_ERROR);
        return 1;
    }

    if (Injury_IsBandaging(playerid))
    {
        return 1;
    }

    new rp[ACCOUNT_NAME_LEN], line[128];
    SendServerMessage(playerid,"Press ~k~~PED_FIREWEAPON~ to cancel bandaging yourself. The bandage will be used once it finished bandaging you.",MSG_TYPE_WARN);
    Injury_StartBandage(playerid);
    TogglePlayerControllable(playerid,false);
    Account_GetRoleplayName(playerid,rp);
    format(line,sizeof(line),"** %s has started bandaging themselves.",rp);
    ProxDetector(playerid,20.0,COLOR_ACTION,line);
    return 1;
}
