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
#define HORSE_IDLE_INDEX (-25000)
#define HORSE_GALLOP_INDEX (-25150)
#define HORSE_SPRINT_INDEX (-25250)
#define HORSE_WALK_INDEX (-25450)
#define HORSE_IDLE_FRAMES (66)
#define HORSE_WALK_FRAMES (28)
#define HORSE_GALLOP_FRAMES (17)
#define HORSE_SPRINT_FRAMES (19)
#define HORSE_COATS (4)
#define DEER_SPRINT_INDEX (-28000)
#define DEER_SPRINT_FRAMES (17)

static const s_MountIdle[HORSE_IDLE_FRAMES][] =
{
    "mounts/horses/idle/0.dff",
    "mounts/horses/idle/1.dff",
    "mounts/horses/idle/2.dff",
    "mounts/horses/idle/3.dff",
    "mounts/horses/idle/4.dff",
    "mounts/horses/idle/5.dff",
    "mounts/horses/idle/6.dff",
    "mounts/horses/idle/7.dff",
    "mounts/horses/idle/8.dff",
    "mounts/horses/idle/9.dff",
    "mounts/horses/idle/10.dff",
    "mounts/horses/idle/11.dff",
    "mounts/horses/idle/12.dff",
    "mounts/horses/idle/13.dff",
    "mounts/horses/idle/14.dff",
    "mounts/horses/idle/15.dff",
    "mounts/horses/idle/16.dff",
    "mounts/horses/idle/17.dff",
    "mounts/horses/idle/18.dff",
    "mounts/horses/idle/19.dff",
    "mounts/horses/idle/20.dff",
    "mounts/horses/idle/21.dff",
    "mounts/horses/idle/22.dff",
    "mounts/horses/idle/23.dff",
    "mounts/horses/idle/24.dff",
    "mounts/horses/idle/25.dff",
    "mounts/horses/idle/26.dff",
    "mounts/horses/idle/26.dff",
    "mounts/horses/idle/26.dff",
    "mounts/horses/idle/26.dff",
    "mounts/horses/idle/26.dff",
    "mounts/horses/idle/26.dff",
    "mounts/horses/idle/27.dff",
    "mounts/horses/idle/28.dff",
    "mounts/horses/idle/29.dff",
    "mounts/horses/idle/30.dff",
    "mounts/horses/idle/31.dff",
    "mounts/horses/idle/32.dff",
    "mounts/horses/idle/33.dff",
    "mounts/horses/idle/34.dff",
    "mounts/horses/idle/35.dff",
    "mounts/horses/idle/36.dff",
    "mounts/horses/idle/37.dff",
    "mounts/horses/idle/38.dff",
    "mounts/horses/idle/39.dff",
    "mounts/horses/idle/40.dff",
    "mounts/horses/idle/40.dff",
    "mounts/horses/idle/40.dff",
    "mounts/horses/idle/40.dff",
    "mounts/horses/idle/40.dff",
    "mounts/horses/idle/40.dff",
    "mounts/horses/idle/41.dff",
    "mounts/horses/idle/42.dff",
    "mounts/horses/idle/43.dff",
    "mounts/horses/idle/44.dff",
    "mounts/horses/idle/45.dff",
    "mounts/horses/idle/46.dff",
    "mounts/horses/idle/47.dff",
    "mounts/horses/idle/48.dff",
    "mounts/horses/idle/49.dff",
    "mounts/horses/idle/50.dff",
    "mounts/horses/idle/51.dff",
    "mounts/horses/idle/52.dff",
    "mounts/horses/idle/53.dff",
    "mounts/horses/idle/54.dff",
    "mounts/horses/idle/55.dff"
};

static const s_MountWalk[HORSE_WALK_FRAMES][] =
{
    "mounts/horses/walk/1.dff",
    "mounts/horses/walk/2.dff",
    "mounts/horses/walk/3.dff",
    "mounts/horses/walk/4.dff",
    "mounts/horses/walk/5.dff",
    "mounts/horses/walk/7.dff",
    "mounts/horses/walk/8.dff",
    "mounts/horses/walk/9.dff",
    "mounts/horses/walk/10.dff",
    "mounts/horses/walk/11.dff",
    "mounts/horses/walk/12.dff",
    "mounts/horses/walk/13.dff",
    "mounts/horses/walk/14.dff",
    "mounts/horses/walk/15.dff",
    "mounts/horses/walk/16.dff",
    "mounts/horses/walk/17.dff",
    "mounts/horses/walk/18.dff",
    "mounts/horses/walk/19.dff",
    "mounts/horses/walk/20.dff",
    "mounts/horses/walk/21.dff",
    "mounts/horses/walk/22.dff",
    "mounts/horses/walk/23.dff",
    "mounts/horses/walk/24.dff",
    "mounts/horses/walk/25.dff",
    "mounts/horses/walk/26.dff",
    "mounts/horses/walk/27.dff",
    "mounts/horses/walk/28.dff",
    "mounts/horses/walk/29.dff"
};

static const s_MountGallop[HORSE_GALLOP_FRAMES][] =
{
    "mounts/horses/gallop/1.dff",
    "mounts/horses/gallop/2.dff",
    "mounts/horses/gallop/3.dff",
    "mounts/horses/gallop/4.dff",
    "mounts/horses/gallop/5.dff",
    "mounts/horses/gallop/6.dff",
    "mounts/horses/gallop/7.dff",
    "mounts/horses/gallop/8.dff",
    "mounts/horses/gallop/9.dff",
    "mounts/horses/gallop/10.dff",
    "mounts/horses/gallop/11.dff",
    "mounts/horses/gallop/12.dff",
    "mounts/horses/gallop/13.dff",
    "mounts/horses/gallop/14.dff",
    "mounts/horses/gallop/15.dff",
    "mounts/horses/gallop/16.dff",
    "mounts/horses/gallop/17.dff"
};

static const s_MountSprint[HORSE_SPRINT_FRAMES][] =
{
    "mounts/horses/sprint/1.dff",
    "mounts/horses/sprint/2.dff",
    "mounts/horses/sprint/3.dff",
    "mounts/horses/sprint/4.dff",
    "mounts/horses/sprint/5.dff",
    "mounts/horses/sprint/6.dff",
    "mounts/horses/sprint/7.dff",
    "mounts/horses/sprint/8.dff",
    "mounts/horses/sprint/9.dff",
    "mounts/horses/sprint/10.dff",
    "mounts/horses/sprint/11.dff",
    "mounts/horses/sprint/12.dff",
    "mounts/horses/sprint/13.dff",
    "mounts/horses/sprint/14.dff",
    "mounts/horses/sprint/15.dff",
    "mounts/horses/sprint/16.dff",
    "mounts/horses/sprint/17.dff",
    "mounts/horses/sprint/18.dff",
    "mounts/horses/sprint/19.dff"
};

static const s_MountCoats[HORSE_COATS][] =
{
    "mounts/horses/horse_txd_a.txd",
    "mounts/horses/horse_txd_b.txd",
    "mounts/horses/horse_txd_c.txd",
    "mounts/horses/horse_txd_d.txd"
};

static const s_DeerSprint[DEER_SPRINT_FRAMES][] =
{
    "wwrp/wildlife/deer/sprint/1.dff",
    "wwrp/wildlife/deer/sprint/2.dff",
    "wwrp/wildlife/deer/sprint/3.dff",
    "wwrp/wildlife/deer/sprint/4.dff",
    "wwrp/wildlife/deer/sprint/5.dff",
    "wwrp/wildlife/deer/sprint/6.dff",
    "wwrp/wildlife/deer/sprint/7.dff",
    "wwrp/wildlife/deer/sprint/8.dff",
    "wwrp/wildlife/deer/sprint/9.dff",
    "wwrp/wildlife/deer/sprint/10.dff",
    "wwrp/wildlife/deer/sprint/11.dff",
    "wwrp/wildlife/deer/sprint/12.dff",
    "wwrp/wildlife/deer/sprint/13.dff",
    "wwrp/wildlife/deer/sprint/14.dff",
    "wwrp/wildlife/deer/sprint/15.dff",
    "wwrp/wildlife/deer/sprint/16.dff",
    "wwrp/wildlife/deer/sprint/17.dff"
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
static Models_RegisterFrames(base,frames,const files[][],count)
{
    for (new coat = 0;coat < HORSE_COATS;coat++)
    {
        for (new i = 1;i < count;i++)
        {
            AddSimpleModel(-1,MODEL_OBJECT_BASE,base + (frames * coat) + i,files[i],s_MountCoats[coat]);
        }
    }
}

stock Models_RegisterMounts()
{
    for (new coat = 0;coat < HORSE_COATS;coat++)
    {
        for (new i = 0;i < HORSE_IDLE_FRAMES;i++)
        {
            AddSimpleModel(-1,MODEL_OBJECT_BASE,HORSE_IDLE_INDEX + (HORSE_IDLE_FRAMES * coat) + i,s_MountIdle[i],s_MountCoats[coat]);
        }
    }

    Models_RegisterFrames(HORSE_GALLOP_INDEX,HORSE_GALLOP_FRAMES,s_MountGallop,HORSE_GALLOP_FRAMES);
    Models_RegisterFrames(HORSE_SPRINT_INDEX,HORSE_SPRINT_FRAMES,s_MountSprint,HORSE_SPRINT_FRAMES);
    Models_RegisterFrames(HORSE_WALK_INDEX,HORSE_WALK_FRAMES,s_MountWalk,HORSE_WALK_FRAMES);

    for (new i = 1;i < DEER_SPRINT_FRAMES;i++)
    {
        AddSimpleModel(-1,MODEL_OBJECT_BASE,DEER_SPRINT_INDEX + i,s_DeerSprint[i],"wwrp/wildlife/deer/deer.txd");
    }
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

hook OnGameModeInit()
{
    Models_RegisterMounts();
}
