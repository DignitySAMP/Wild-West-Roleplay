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
#define REVISION_COUNT (8)
#define REVISION_SHOWN (5)
#define REVISION_TEXT_LEN (256)

forward Updates_Deferred(playerid,token);

enum
{
    REVISION_ADDITION,
    REVISION_REMOVAL,
    REVISION_CHANGE,
    REVISION_HOTFIX
}

enum e_REVISION
{
    E_REVISION_TEXT[REVISION_TEXT_LEN],
    E_REVISION_TYPE,
    E_REVISION_DATE
}

static const s_Revisions[REVISION_COUNT][e_REVISION] =
{
    {"Farming system: you can buy the necessities at the general store and blacksmith",REVISION_ADDITION,1548331200},
    {"Trap system: you can buy a trap at the blacksmith and use it to catch animals. (and humans)",REVISION_ADDITION,1548331202},
    {"Bayside has been changed! It's now a snowy mountain!",REVISION_CHANGE,1548862920},
    {"Las Barrancas and EQ have been overhauled",REVISION_CHANGE,1548862922},
    {"Fixed /levelup (no capitalised letters needed)",REVISION_HOTFIX,1549022400},
    {"Fixed job GUI & overhauled textdraw backend",REVISION_HOTFIX,1549022402},
    {"Fixed proximity message when a player disconnects (nearby players are alerted)",REVISION_HOTFIX,1549023300},
    {"Merged M-RP's updated inventory module. The inventory should now be more smooth in general.",REVISION_CHANGE,1549110600}
};

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
stock Updates_DateText(unix,dest[],size = sizeof(dest))
{
    new days = unix / 86400, z = days + 719468, era = z / 146097, doe = z - era * 146097;
    new yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365, year = yoe + era * 400;
    new doy = doe - (365 * yoe + yoe / 4 - yoe / 100), mp = (5 * doy + 2) / 153;
    new day = doy - (153 * mp + 2) / 5 + 1, month = mp < 10 ? mp + 3 : mp - 9;

    if (month <= 2)
    {
        year++;
    }

    format(dest,size,"%02d/%02d/%d",day,month,year);
}

static Updates_TypeText(index,unix,dest[],size = sizeof(dest))
{
    switch (s_Revisions[index][E_REVISION_TYPE])
    {
        case REVISION_ADDITION:
        {
            strcopy(dest,"added{DEDEDE} \t",size);
        }
        case REVISION_REMOVAL:
        {
            strcopy(dest,"removed{DEDEDE}",size);
        }
        case REVISION_CHANGE:
        {
            strcopy(dest,"changed{DEDEDE}",size);
        }
        case REVISION_HOTFIX:
        {
            strcopy(dest,"hotfixed{DEDEDE}",size);
        }
        default:
        {
            strcopy(dest,"updated{DEDEDE}",size);
        }
    }

    if (gettime() - 3600 < unix)
    {
        strins(dest,"{87c482}",0,size);
    }
}

stock Updates_Build(dest[],size = sizeof(dest))
{
    new order[REVISION_COUNT], latest = 0, date[16];

    for (new i = 0;i < REVISION_COUNT;i++)
    {
        order[i] = i;

        if (s_Revisions[i][E_REVISION_DATE] > latest)
        {
            latest = s_Revisions[i][E_REVISION_DATE];
        }
    }

    for (new i = 0;i < REVISION_COUNT - 1;i++)
    {
        for (new j = 0;j < REVISION_COUNT - 1 - i;j++)
        {
            if (s_Revisions[order[j]][E_REVISION_DATE] > s_Revisions[order[j + 1]][E_REVISION_DATE])
            {
                new swap = order[j];
                order[j] = order[j + 1];
                order[j + 1] = swap;
            }
        }
    }

    Updates_DateText(latest,date);
    format(dest,size,"{DEDEDE}Here are the latest changes for the most recent audit (# %d), rolled out on %s.\n",REVISION_COUNT,date);

    new first = REVISION_COUNT - REVISION_SHOWN;

    if (first < 0)
    {
        first = 0;
    }

    for (new i = first;i < REVISION_COUNT;i++)
    {
        new type[40], age[48], row[REVISION_TEXT_LEN + 160], index = order[i];
        Updates_TypeText(index,s_Revisions[index][E_REVISION_DATE],type);
        Staff_FormatDuration(gettime() - s_Revisions[index][E_REVISION_DATE],age);
        format(row,sizeof(row),"\n \t %s (%s) \n \t {FFFFFF}%s{DEDEDE}\n",type,age,s_Revisions[index][E_REVISION_TEXT]);
        strcat(dest,row,size);
    }
}

static Updates_Flow(playerid,token)
{
    yield 1;
    new body[1536], response[DIALOG_RESPONSE];
    Updates_Build(body);
    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"Updates",body,"yes","no");
    #pragma unused token
}

public Updates_Deferred(playerid,token)
{
    Updates_Flow(playerid,token);
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
CMD:updates(cmdid,playerid,params[])
{
    #pragma unused cmdid, params

    SetTimerEx("Updates_Deferred",0,false,"dd",playerid,Account_GetToken(playerid));
    return 1;
}
