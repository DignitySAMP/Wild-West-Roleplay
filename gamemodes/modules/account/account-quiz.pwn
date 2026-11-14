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
#define QUIZ_QUESTIONS (18)
#define QUIZ_GROUPS (6)
#define QUIZ_GROUP_SIZE (3)
#define QUIZ_TEXT_LEN (80)

static const s_QuizBank[QUIZ_QUESTIONS][4][QUIZ_TEXT_LEN] =
{
    {"What is metagaming?", "Using OOC information IC.", "Using IC information OOC.", "Forcing actions upon another player."},
    {"What is powergaming?", "Forcing actions onto another player.", "Roleplay being powerful.", "Playing to win."},
    {"What is revenge killing?", "Killing a player you've already killed within 30 minutes.", "Killing someone who killed your friend.", "Planning a revenge attack against someone."},
    {"What is deathmatching?", "Killing someone without a roleplay reason.", "Killing someone with a good roleplay reason.", "Duelling to the death."},
    {"What is the aim of roleplaying?", "Taking the role of a character.", "Killing everyone you see.", "Doing stuff you can't do in real life."},
    {"What's this server based on?", "The wild west.", "The medieval era.", "Modern day U.S."},
    {"When can I stop roleplaying in the server?", "With an admin's permission.", "Whenever I get bored.", "When people talk in /b."},
    {"Which of the following is grammatically correct?", "I've eaten already today.", "I've eat already today.", "I eat already today."},
    {"Can I sell ingame goods for real life stuff?", "No, never.", "Yes, with an admin's permission.", "Yes, it doesn't matter."},
    {"What's the ruleset on modifications?", "Anything that gives an advantage is disallowed.", "I can use whatever I want, since it's my game I'm customising.", "As long as admins don't catch me, it's fine."},
    {"Can I abuse physics? i.e. bunnyhop, tapping", "No, because that's unrealistic.", "If it's possible in the game, it's possible RP-wise.", "Yes, because horses are too slow."},
    {"Can I rape someone?", "Yes, with their consent and at a private area.", "Yes, with their consent.", "Yes - it's rape for a reason."},
    {"Can I kill someone after robbing them?", "No, I can not.", "Yes, because they will tell the police otherwise.", "It doesn't matter."},
    {"What type of cars can you buy?", "None, cars aren't invented yet.", "Old timers.", "Any car."},
    {"What chat are you allowed to use emoticons?", "Local/Global OOC chat.", "Normal IC chat.", "Any chat I want."},
    {"Can I PM an admin to come and assist me?", "No I can't. I must /report.", "Yes, WW-RP admins are friendly.", "Yes, because /report is only for emergencies."},
    {"Which of the following is fully OOC?", "Admin Jail.", "An event hosted by an administrator.", "When I'm losing a roleplay scene."},
    {"Which of the following is a proper ad?", "Come have some drinks at The Watering Hole!", "PM me for a easy job.", "Selling a horse, contact me on the forums."}
};

static s_QuizIndex[MAX_PLAYERS];
static s_QuizStep[MAX_PLAYERS];
static s_QuizWrong[MAX_PLAYERS];
static s_QuizCorrectRow[MAX_PLAYERS];

forward Quiz_StartDeferred(playerid,token);
forward Account_ReauthenticateAfterQuiz(playerid);

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

static Quiz_BuildAnswers(index,correctRow,body[],size)
{
    new first, second, third;

    switch (correctRow)
    {
        case 0:
        {
            first = 1;
            second = 2;
            third = 3;
        }
        case 1:
        {
            first = 2;
            second = 1;
            third = 3;
        }
        default:
        {
            first = 2;
            second = 3;
            third = 1;
        }
    }

    format(body,size,"%s\n%s\n%s",s_QuizBank[index][first],s_QuizBank[index][second],s_QuizBank[index][third]);
}

static Quiz_Finish(playerid,token)
{
    new response[DIALOG_RESPONSE];

    if (s_QuizWrong[playerid] > 0)
    {
        new line[96];
        format(line,sizeof(line),"You have failed the quiz with %d wrong %s.",s_QuizWrong[playerid],s_QuizWrong[playerid] == 1 ? ("answer") : ("answers"));
        SendServerMessage(playerid,line,MSG_TYPE_ERROR);
        Account_QueueKick(playerid);
        return;
    }

    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"{FF6347}WARNING: PLEASE READ","{DEDEDE}Do you agree to follow the rules whenever you feel like it along with using commands\nsuch as /report and /helpme as a way to directly communicate with staff whenever you want?","Yes","No");

    if (!Account_IsCurrent(playerid,token) || g_AccountStage[playerid] != E_ACCOUNT_STAGE_QUIZ)
    {
        return;
    }

    if (response[DIALOG_RESPONSE_RESPONSE])
    {
        mysql_pquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_rulecheck = 1 WHERE account_id = %d",g_Account[playerid][E_ACCOUNT_ID]));
        g_Account[playerid][E_ACCOUNT_RULECHECK] = 1;
        Log_Info("register","rulecheck: master account %s (%d) agreed to follow the rules",g_Account[playerid][E_ACCOUNT_NAME],g_Account[playerid][E_ACCOUNT_ID]);
    }

    await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_MSGBOX,"Passed server quiz","{DEDEDE}You passed the server quiz!\n\nYou are on your way on becoming a full pledged member of the server.\n\nYou will be taken to the character creation screen momentarily.\nIn order to continue, press \"Continue\".\n\nThanks and good luck!","Continue","");

    if (!Account_IsCurrent(playerid,token) || g_AccountStage[playerid] != E_ACCOUNT_STAGE_QUIZ)
    {
        return;
    }

    mysql_pquery_s(g_Mysql,str_format("UPDATE master_accounts SET account_registerquiz = 1 WHERE account_id = %d",g_Account[playerid][E_ACCOUNT_ID]));
    g_Account[playerid][E_ACCOUNT_REGISTERQUIZ] = 1;
    SendServerMessage(playerid,"You have passed the quiz! Enter your password once again to finish it.",MSG_TYPE_INFO);
    Account_ReauthenticateAfterQuiz(playerid);
}

static Quiz_Run(playerid)
{
    yield 1;

    new token = g_AccountToken[playerid], response[DIALOG_RESPONSE], answers[QUIZ_TEXT_LEN * 3 + 4];
    s_QuizWrong[playerid] = 0;

    for (new step = 0;step < QUIZ_GROUPS;step++)
    {
        s_QuizStep[playerid] = step;
        s_QuizIndex[playerid] = step * QUIZ_GROUP_SIZE + random(QUIZ_GROUP_SIZE);
        s_QuizCorrectRow[playerid] = random(3);
        Quiz_BuildAnswers(s_QuizIndex[playerid],s_QuizCorrectRow[playerid],answers,sizeof(answers));
        await_arr(response) ShowAsyncDialog(playerid,DIALOG_STYLE_LIST,s_QuizBank[s_QuizIndex[playerid]][0],answers,"Select","Exit");

        if (!Account_IsCurrent(playerid,token) || g_AccountStage[playerid] != E_ACCOUNT_STAGE_QUIZ)
        {
            return;
        }

        if (!response[DIALOG_RESPONSE_RESPONSE])
        {
            Kick(playerid);
            return;
        }

        if (response[DIALOG_RESPONSE_LISTITEM] != s_QuizCorrectRow[playerid])
        {
            s_QuizWrong[playerid]++;
        }
    }

    s_QuizStep[playerid] = QUIZ_GROUPS;
    Quiz_Finish(playerid,token);
}

stock Quiz_Start(playerid)
{
    SetTimerEx("Quiz_StartDeferred",0,false,"dd",playerid,g_AccountToken[playerid]);
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
public Quiz_StartDeferred(playerid,token)
{
    if (Account_IsCurrent(playerid,token) && g_AccountStage[playerid] == E_ACCOUNT_STAGE_QUIZ)
    {
        Quiz_Run(playerid);
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

hook OnPlayerConnect(playerid)
{
    s_QuizIndex[playerid] = -1;
    s_QuizStep[playerid] = 0;
    s_QuizWrong[playerid] = 0;
    s_QuizCorrectRow[playerid] = 0;
}
