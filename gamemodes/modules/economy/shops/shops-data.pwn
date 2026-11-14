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
#define SHOP_LABEL_LEN (48)
#define SHOP_NOUN_LEN (24)
#define SHOP_BOUGHT_LEN (112)
#define SHOP_SKIN_PRICE (125)
#define SHOP_MASK_LEVEL (10)
#define SHOP_GUN_LEVEL (3)
#define SHOP_MAX_LIST (140)

enum _:E_SHOP_KINDS
{
    SHOP_KIND_ITEM = 0,
    SHOP_KIND_WEAPON,
    SHOP_KIND_SMALL,
    SHOP_KIND_LARGE,
}

enum e_SHOP_ITEM
{
    E_SHOP_LABEL[SHOP_LABEL_LEN],
    E_SHOP_NOUN[SHOP_NOUN_LEN],
    E_SHOP_PRICE,
    E_SHOP_PARAM,
    E_SHOP_EXTRA,
    E_SHOP_AMOUNT,
    E_SHOP_LEVEL,
    E_SHOP_KIND,
    E_SHOP_WEAPON,
    E_SHOP_AMMO,
    E_SHOP_BOUGHT[SHOP_BOUGHT_LEN],
}

enum _:E_SHOP
{
    SHOP_GENERAL = 0,
    SHOP_GUN,
    SHOP_BLACKSMITH,
    SHOP_MISC,
    SHOP_LIQUOR,
    SHOP_HUNTING,
    SHOP_SKINS,
}

enum e_SHOP_SKIN
{
    E_SHOP_SKIN_ID,
    E_SHOP_SKIN_ETHNICITY,
    E_SHOP_SKIN_GENDER,
}

static const s_ShopGeneral[30][e_SHOP_ITEM] =
{
    {"Pocket Watch ($5.50)","pocket watch",550,E_ITEM_PARAM_MISC,E_ITEM_EXTRA_POCKET_WATCH,1,0,0,0,0,""},
    {"Camera ($45.00)","camera",4500,E_ITEM_PARAM_WEAPON,E_ITEM_EXTRA_CAMERA,1,0,0,0,0,""},
    {"Hatchet ($12.00)","hatchet",1200,E_ITEM_PARAM_LUMBER,E_ITEM_EXTRA_LUMBER_HATCHET,1,2,0,0,0,""},
    {"Bandage ($3.46)","bandage",346,E_ITEM_PARAM_HEAL,E_ITEM_EXTRA_BANDAGE,1,0,0,0,0,""},
    {"Red Apple ($0.20)","red apple",20,E_ITEM_PARAM_HUNGER,E_ITEM_EXTRA_FOOD_APPLE_RED,1,0,0,0,0,""},
    {"Green Apple ($0.20)","green apple",20,E_ITEM_PARAM_HUNGER,E_ITEM_EXTRA_FOOD_APPLE_GREEN,1,0,0,0,0,""},
    {"Water Bottle ($0.75)","water bottle",75,E_ITEM_PARAM_THIRST,E_ITEM_EXTRA_FOOD_WATER_FULL,1,0,0,0,0,""},
    {"Canned Salmon ($2.00)","canned salmon",200,E_ITEM_PARAM_HUNGER,E_ITEM_EXTRA_FOOD_CANNED_SALMON,1,0,0,0,0,""},
    {"Canned Corned Beef ($1.75)","canned corned beef",175,E_ITEM_PARAM_HUNGER,E_ITEM_EXTRA_FOOD_CANNED_CORNED_BEEF,1,0,0,0,0,""},
    {"Canned Pineapples ($1.50)","canned pineapples",150,E_ITEM_PARAM_HUNGER,E_ITEM_EXTRA_FOOD_CANNED_PINEAPPLES,1,0,0,0,0,""},
    {"Canned Strawberries ($1.20)","canned strawberries",120,E_ITEM_PARAM_HUNGER,E_ITEM_EXTRA_FOOD_CANNED_STRAWBERRIES,1,0,0,0,0,""},
    {"Canned Kidney Beans ($1.50)","canned kidney beans",150,E_ITEM_PARAM_HUNGER,E_ITEM_EXTRA_FOOD_CANNED_KIDNEY_BEANS,1,0,0,0,0,""},
    {"Canned Peaches ($1.00)","canned peaches",100,E_ITEM_PARAM_HUNGER,E_ITEM_EXTRA_FOOD_CANNED_PEACHES,1,0,0,0,0,""},
    {"Canned Sweetcorn ($1.00)","canned sweetcorn",100,E_ITEM_PARAM_HUNGER,E_ITEM_EXTRA_FOOD_CANNED_SWEETCORN,1,0,0,0,0,""},
    {"Baked Beans ($1.20)","baked beans",120,E_ITEM_PARAM_HUNGER,E_ITEM_EXTRA_FOOD_CANNED_BAKED_BEANS,1,0,0,0,0,""},
    {"Canned Apricots ($0.75)","canned apricots",75,E_ITEM_PARAM_HUNGER,E_ITEM_EXTRA_FOOD_CANNED_APRICOTS,1,0,0,0,0,""},
    {"Canned Peas ($0.75)","canned peas",75,E_ITEM_PARAM_HUNGER,E_ITEM_EXTRA_FOOD_CANNED_PEAS,1,0,0,0,0,""},
    {"Cigar Pack ($2.12), 20 in a pack","cigar pack",212,E_ITEM_PARAM_SMOKES,E_ITEM_EXTRA_SMOKE_CIGARPACK,20,0,0,0,0,""},
    {"Blunt Pack ($2.50), 20 in a pack","blunt pack",250,E_ITEM_PARAM_SMOKES,E_ITEM_EXTRA_SMOKE_BLUNTPACK,20,0,0,0,0,""},
    {"Small Backpack ($20.00)","small backpack",2000,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_NONE,1,0,SHOP_KIND_SMALL,0,0,"You bought a small backpack for $20."},
    {"Large Backpack ($45.00)","large backpack",4500,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_NONE,1,0,SHOP_KIND_LARGE,0,0,"You bought a large backpack for $45."},
    {"Farming Soil Bag ($0.85)","soil bag",85,E_ITEM_PARAM_FARMING,E_ITEM_EXTRA_FARMING_SOIL_BAG,1,0,0,0,0,""},
    {"Orange Seed ($0.10)","orange seed",10,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_SEED_ORANGE,1,0,0,0,0,""},
    {"Red Apple Seed ($0.12)","red apple seed",12,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_SEED_APPLE_RED,1,0,0,0,0,""},
    {"Green Apple Seed ($0.12)","green apple seed",12,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_SEED_APPLE_GREEN,1,0,0,0,0,""},
    {"Tomato Seed ($0.15)","tomato seed",15,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_SEED_TOMATO,1,0,0,0,0,""},
    {"Pumpkin Seed ($0.11)","pumpkin seed",11,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_SEED_PUMPKIN,1,0,0,0,0,""},
    {"Cabbage Seed ($0.14)","cabbage seed",14,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_SEED_CABBAGE,1,0,0,0,0,""},
    {"Wheat Seed ($0.15)","wheat seed",15,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_SEED_WHEAT,1,0,0,0,0,""},
    {"Basket ($2.78)","basket",278,E_ITEM_PARAM_FARMING,E_ITEM_EXTRA_EMPTY_BASKET,1,0,0,0,0,""}
};

static const s_ShopGun[10][e_SHOP_ITEM] =
{
    {"Baseball Bat ($5.00)","baseball bat",500,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_NONE,1,3,SHOP_KIND_WEAPON,5,1,"You've purchased a baseball bat."},
    {"Knife ($7.50)","knife",750,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_NONE,1,4,SHOP_KIND_WEAPON,4,1,"You've purchased a knife."},
    {"Pistol ($40.00)","revolver",4000,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_NONE,1,6,SHOP_KIND_WEAPON,24,0,"You've purchased a revolver. You need to buy the appropiate ammo pack to add bullets to your magazine!"},
    {"Shotgun ($66.00)","shotgun",6600,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_NONE,1,8,SHOP_KIND_WEAPON,25,0,"You've purchased a shotgun. You need to buy the appropiate ammo pack to add bullets to your magazine!"},
    {"Sawn-off ($51.00)","sawn off shotgun",5100,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_NONE,1,8,SHOP_KIND_WEAPON,26,0,"You've purchased a sawn-off shotgun. You need to buy the appropiate ammo pack to add bullets to your magazine!"},
    {"Rifle ($82.00)","rifle",8200,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_NONE,1,12,SHOP_KIND_WEAPON,33,0,"You've purchased a rifle. You need to buy the appropiate ammo pack to add bullets to your magazine!"},
    {"Scope Rifle ($104.00)","scoped rifle",10400,E_ITEM_PARAM_UNDEFINED,E_ITEM_EXTRA_NONE,1,16,SHOP_KIND_WEAPON,34,0,"You've purchased a scoped rifle. You need to buy the appropiate ammo pack to add bullets to your weapon!"},
    {"Pistol Ammo ($2.50)","pistol ammo crate",250,E_ITEM_PARAM_AMMO,E_ITEM_EXTRA_AMMO_CRATE_PISTOL,1,0,0,0,0,""},
    {"Shotgun Ammo ($1.50)","shotgun ammo crate",150,E_ITEM_PARAM_AMMO,E_ITEM_EXTRA_AMMO_CRATE_SHOTGUN,1,0,0,0,0,""},
    {"Rifle Ammo ($3.50)","rifle ammo crate",350,E_ITEM_PARAM_AMMO,E_ITEM_EXTRA_AMMO_CRATE_RIFLE,1,0,0,0,0,""}
};

static const s_ShopBlacksmith[3][e_SHOP_ITEM] =
{
    {"Pickaxe ($8.04)","pickaxe",804,E_ITEM_PARAM_MINING,E_ITEM_EXTRA_MINE_PICKAXE,1,2,0,0,0,""},
    {"Pail ($2.45)","pail",245,E_ITEM_PARAM_FARMING,E_ITEM_EXTRA_FARMING_PAIL,1,0,0,0,0,""},
    {"Shovel ($4.02)","shovel",402,E_ITEM_PARAM_FARMING,E_ITEM_EXTRA_FARMING_SHOVEL,1,0,0,0,0,""}
};

static const s_ShopMisc[2][e_SHOP_ITEM] =
{
    {"Gloves ($3.50)","gloves",350,E_ITEM_PARAM_MISC,E_ITEM_EXTRA_GLOVES,1,0,0,0,0,""},
    {"Long Johns ($6.25)","long johns",625,E_ITEM_PARAM_MISC,E_ITEM_EXTRA_LONG_JOHNS,1,0,0,0,0,""}
};

static const s_ShopLiquor[9][e_SHOP_ITEM] =
{
    {"Pale Lager ($1.23)","pale lager",123,E_ITEM_PARAM_LIQUOR,E_ITEM_EXTRA_LIQUOR_PALELAGER,1,0,0,0,0,""},
    {"Mild Ale ($1.20)","mild ale",120,E_ITEM_PARAM_LIQUOR,E_ITEM_EXTRA_LIQUOR_MILDALE,1,0,0,0,0,""},
    {"Malt Liquor ($2.00)","malt liquor",200,E_ITEM_PARAM_LIQUOR,E_ITEM_EXTRA_LIQUOR_MALTLIQUOR,1,0,0,0,0,""},
    {"Wheat Beer ($1.89)","wheat beer",189,E_ITEM_PARAM_LIQUOR,E_ITEM_EXTRA_LIQUOR_WHEATBEER,1,0,0,0,0,""},
    {"White Wine ($2.05)","white wine",205,E_ITEM_PARAM_LIQUOR,E_ITEM_EXTRA_LIQUOR_WHITEWINE,1,0,0,0,0,""},
    {"Red Wine ($2.11)","red wine",211,E_ITEM_PARAM_LIQUOR,E_ITEM_EXTRA_LIQUOR_REDWINE,1,0,0,0,0,""},
    {"Grain Whiskey ($2.33)","grain whiskey",233,E_ITEM_PARAM_LIQUOR,E_ITEM_EXTRA_LIQUOR_GRAINWHISKEY,1,0,0,0,0,""},
    {"Malt Whiskey ($2.64)","malt whiskey",264,E_ITEM_PARAM_LIQUOR,E_ITEM_EXTRA_LIQUOR_MALTWHISKEY,1,0,0,0,0,""},
    {"Moonshine Vodka ($3.05)","moonshine",305,E_ITEM_PARAM_LIQUOR,E_ITEM_EXTRA_LIQUOR_VODKA,1,0,0,0,0,""}
};

static const s_ShopHunting[3][e_SHOP_ITEM] =
{
    {"Fishing Rod ($1.04)","fishing rod",104,E_ITEM_PARAM_FISHING,E_ITEM_EXTRA_FISHING_ROD,1,0,0,0,0,""},
    {"Hunting Knife ($17.50)","hunting knife",1750,E_ITEM_PARAM_HUNTING,E_ITEM_EXTRA_HUNTING_KNIFE,1,0,0,0,0,""},
    {"Animal Trap ($11.32)","animal trap",1132,E_ITEM_PARAM_HUNTING,E_ITEM_EXTRA_HUNTING_TRAP,1,0,0,0,0,""}
};

static const s_ShopSkins[136][e_SHOP_SKIN] =
{
    {32,0,0},
    {33,0,0},
    {34,0,0},
    {72,0,0},
    {73,0,0},
    {95,0,0},
    {132,0,0},
    {135,0,0},
    {158,0,0},
    {159,0,0},
    {160,0,0},
    {161,0,0},
    {162,0,0},
    {101,0,0},
    {179,0,0},
    {200,0,0},
    {213,0,0},
    {234,0,0},
    {235,0,0},
    {236,0,0},
    {258,0,0},
    {259,0,0},
    {261,0,0},
    {272,0,0},
    {290,0,0},
    {291,0,0},
    {292,0,0},
    {299,0,0},
    {303,0,0},
    {304,0,0},
    {305,0,0},
    {125,0,0},
    {288,0,0},
    {181,0,0},
    {302,0,0},
    {310,0,0},
    {311,0,0},
    {CIVILIAN1,0,0},
    {CIVILIAN3,0,0},
    {CIVILIAN4,0,0},
    {CIVILIAN5,0,0},
    {CIVILIAN6,0,0},
    {CIVILIAN7,0,0},
    {CIVILIAN8,0,0},
    {COWBOY1,0,0},
    {COWBOY2,0,0},
    {COWBOY3,0,0},
    {COWBOY5,0,0},
    {COWBOY6,0,0},
    {COWBOY7,0,0},
    {COWBOY8,0,0},
    {COWBOY9,0,0},
    {COWBOY10,0,0},
    {COWBOY11,0,0},
    {COWBOY12,0,0},
    {COWBOY13,0,0},
    {COWBOY14,0,0},
    {COWBOY15,0,0},
    {COWBOY16,0,0},
    {COWBOY17,0,0},
    {COWBOY18,0,0},
    {APACHE3,0,0},
    {129,0,1},
    {130,0,1},
    {31,0,1},
    {157,0,1},
    {191,0,1},
    {192,0,1},
    {196,0,1},
    {197,0,1},
    {198,0,1},
    {199,0,1},
    {308,0,1},
    {FEMALE1,0,1},
    {FEMALE2,0,1},
    {FEMALE3,0,1},
    {FEMALE4,0,1},
    {FEMALE5,0,1},
    {FEMALE6,0,1},
    {FEMALE7,0,1},
    {FEMALE9,0,1},
    {309,0,1},
    {30,1,0},
    {43,1,0},
    {44,1,0},
    {46,1,0},
    {47,1,0},
    {48,1,0},
    {58,1,0},
    {173,1,0},
    {174,1,0},
    {175,1,0},
    {223,1,0},
    {273,1,0},
    {MEXICAN4,1,0},
    {MEXICAN5,1,0},
    {MEXICAN8,1,0},
    {131,1,1},
    {207,1,1},
    {243,1,1},
    {298,1,1},
    {122,3,0},
    {210,3,0},
    {229,3,0},
    {294,3,0},
    {224,3,1},
    {225,3,1},
    {263,3,1},
    {136,2,0},
    {142,2,0},
    {182,2,0},
    {183,2,0},
    {15,2,0},
    {220,2,0},
    {221,2,0},
    {222,2,0},
    {249,2,0},
    {17,2,0},
    {4,2,0},
    {CIVILIAN9,2,0},
    {CIVILIAN10,2,0},
    {CIVILIAN11,2,0},
    {190,2,1},
    {215,2,1},
    {245,2,1},
    {FEMALE8,2,1},
    {128,4,0},
    {APACHE1,4,0},
    {APACHE2,4,0},
    {APACHE3,4,0},
    {17,2,0},
    {125,0,0},
    {288,0,0},
    {4,2,0},
    {308,0,1},
    {181,0,0}
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
stock Shop_GetCount(shop)
{
    switch (shop)
    {
        case SHOP_GENERAL:
        {
            return sizeof(s_ShopGeneral);
        }
        case SHOP_GUN:
        {
            return sizeof(s_ShopGun);
        }
        case SHOP_BLACKSMITH:
        {
            return sizeof(s_ShopBlacksmith);
        }
        case SHOP_MISC:
        {
            return sizeof(s_ShopMisc);
        }
        case SHOP_LIQUOR:
        {
            return sizeof(s_ShopLiquor);
        }
        case SHOP_HUNTING:
        {
            return sizeof(s_ShopHunting);
        }
    }

    return 0;
}

stock bool:Shop_GetItem(shop,index,item[e_SHOP_ITEM])
{
    if (index < 0 || index >= Shop_GetCount(shop))
    {
        return false;
    }

    switch (shop)
    {
        case SHOP_GENERAL:
        {
            item = s_ShopGeneral[index];
        }
        case SHOP_GUN:
        {
            item = s_ShopGun[index];
        }
        case SHOP_BLACKSMITH:
        {
            item = s_ShopBlacksmith[index];
        }
        case SHOP_MISC:
        {
            item = s_ShopMisc[index];
        }
        case SHOP_LIQUOR:
        {
            item = s_ShopLiquor[index];
        }
        case SHOP_HUNTING:
        {
            item = s_ShopHunting[index];
        }
    }

    return true;
}

stock Shop_GetSkinCount()
{
    return sizeof(s_ShopSkins);
}

stock bool:Shop_GetSkin(index,skin[e_SHOP_SKIN])
{
    if (index < 0 || index >= sizeof(s_ShopSkins))
    {
        return false;
    }

    skin = s_ShopSkins[index];
    return true;
}
