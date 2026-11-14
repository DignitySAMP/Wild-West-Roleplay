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
#define PICK_CAPTION_LEN (64)

enum e_SHOP_PICK
{
    E_SHOP_PICK_MODEL,
    E_SHOP_PICK_CAPTION[PICK_CAPTION_LEN]
}

static const s_PicksGeneral[30][e_SHOP_PICK] =
{
    {19043,"Pocket Watch ($5.50)"},
    {19623,"Camera ($45.00)"},
    {0,"Hatchet ($12.00)"},
    {11747,"Bandage ($3.46)"},
    {19575,"Red Apple ($0.20)"},
    {19576,"Green Apple ($0.20)"},
    {19570,"Water Bottle ($0.75)"},
    {19567,"Canned Salmon ($2.00)"},
    {19567,"Canned Corned Beef ($1.75)"},
    {19564,"Canned Pineapples ($1.50)"},
    {19564,"Canned Strawberries ($1.20)"},
    {19567,"Canned Kidney Beans ($1.50)"},
    {19564,"Canned Peaches ($1.00)"},
    {19567,"Canned Sweetcorn ($1.00)"},
    {19567,"Baked Beans ($1.20)"},
    {19564,"Canned Apricots ($0.75)"},
    {19567,"Canned Peas ($0.75)"},
    {19897,"Cigar Pack ($2.12)~n~20 in a pack"},
    {19896,"Blunt Pack($2.50)~n~20 in a pack"},
    {363,"Small Backpack($20.00)"},
    {363,"Large Backpack($45.00)"},
    {2060,"Farming Soil Bag($0.85)"},
    {2663,"Orange Seed ($0.10)"},
    {2663,"Red Apple Seed ($0.12)"},
    {2663,"Green Apple Seed ($0.12)"},
    {2663,"Tomato Seed ($0.15)"},
    {2663,"Pumpkin Seed ($0.11)"},
    {2663,"Cabbage Seed ($0.14)"},
    {2663,"Wheat Seed ($0.15)"},
    {19592,"Basket ($2.78)"}
};

static const s_PicksGun[10][e_SHOP_PICK] =
{
    {336,"Baseball Bat ($5.00)"},
    {335,"Knife ($7.50)"},
    {348,"Pistol ($40.00)"},
    {349,"Shotgun ($66.00)"},
    {350,"Sawn-off ($51.00)"},
    {357,"Rifle ($82.00)"},
    {358,"Scope Rifle~n~($104.00)"},
    {2037,"Pistol Ammo~n~($2.50)"},
    {2041,"Shotgun Ammo~n~($1.50)"},
    {2043,"Rifle Ammo~n~($3.50)"}
};

static const s_PicksBlacksmith[3][e_SHOP_PICK] =
{
    {0,"Pickaxe ($8.04)"},
    {19468,"Pail ($2.45)"},
    {19626,"Shovel ($4.02)"}
};

static const s_PicksMisc[2][e_SHOP_PICK] =
{
    {0,"Gloves ($3.50)"},
    {0,"Long Johns ($6.25)"}
};

static const s_PicksLiquor[9][e_SHOP_PICK] =
{
    {1544,"Pale Lager ($1.23)"},
    {1543,"Mild Ale ($1.20)"},
    {1486,"Malt Liquor ($2.00)"},
    {1484,"Wheat Beer ($1.89)"},
    {19824,"White Wine ($2.05)"},
    {19822,"Red Wine ($2.11)"},
    {19823,"Grain Whiskey~n~($2.33)"},
    {19820,"Malt Whiskey~n~($2.64)"},
    {19821,"Moonshine~n~Vodka ($3.05)"}
};

static const s_PicksHunting[3][e_SHOP_PICK] =
{
    {18632,"Fishing Rod ($1.04)"},
    {335,"Hunting Knife ($17.50)"},
    {0,"Animal Trap ($11.32)"}
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
stock bool:Shop_GetPick(shop,index,&model,caption[],size = sizeof(caption))
{
    switch (shop)
    {
        case SHOP_GENERAL:
        {
            if (index < 0 || index >= sizeof(s_PicksGeneral))
            {
                return false;
            }

            model = s_PicksGeneral[index][E_SHOP_PICK_MODEL];
            strcopy(caption,s_PicksGeneral[index][E_SHOP_PICK_CAPTION],size);
        }
        case SHOP_GUN:
        {
            if (index < 0 || index >= sizeof(s_PicksGun))
            {
                return false;
            }

            model = s_PicksGun[index][E_SHOP_PICK_MODEL];
            strcopy(caption,s_PicksGun[index][E_SHOP_PICK_CAPTION],size);
        }
        case SHOP_BLACKSMITH:
        {
            if (index < 0 || index >= sizeof(s_PicksBlacksmith))
            {
                return false;
            }

            model = s_PicksBlacksmith[index][E_SHOP_PICK_MODEL];
            strcopy(caption,s_PicksBlacksmith[index][E_SHOP_PICK_CAPTION],size);
        }
        case SHOP_MISC:
        {
            if (index < 0 || index >= sizeof(s_PicksMisc))
            {
                return false;
            }

            model = s_PicksMisc[index][E_SHOP_PICK_MODEL];
            strcopy(caption,s_PicksMisc[index][E_SHOP_PICK_CAPTION],size);
        }
        case SHOP_LIQUOR:
        {
            if (index < 0 || index >= sizeof(s_PicksLiquor))
            {
                return false;
            }

            model = s_PicksLiquor[index][E_SHOP_PICK_MODEL];
            strcopy(caption,s_PicksLiquor[index][E_SHOP_PICK_CAPTION],size);
        }
        case SHOP_HUNTING:
        {
            if (index < 0 || index >= sizeof(s_PicksHunting))
            {
                return false;
            }

            model = s_PicksHunting[index][E_SHOP_PICK_MODEL];
            strcopy(caption,s_PicksHunting[index][E_SHOP_PICK_CAPTION],size);
        }
        default:
        {
            return false;
        }
    }

    return true;
}
