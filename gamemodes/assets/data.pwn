enum { // custom obj indexes
    OBJ_KCD_BANNER_BLACKDRAGON   = -2000,
    OBJ_KCD_BANNER_BROWNTEMPLAR, OBJ_KCD_BANNER_BYZANTINE, OBJ_KCD_BANNER_CRUSADE1, OBJ_KCD_BANNER_CRUSADE2, OBJ_KCD_BANNER_FRANCE, 
    OBJ_KCD_BANNER_HRE, OBJ_KCD_BANNER_JERUSALEM, OBJ_KCD_BANNER_REDLION, OBJ_KCD_BANNER_STRIPESTARS, OBJ_KCD_BANNER_VIKING, OBJ_ANVIL, 
    OBJ_BARREL, OBJ_CRATE, OBJ_BOOKCASE, OBJ_WEP_SHORTSWORD, OBJ_BEERGLASS, OBJ_BENCH, OBJ_BOOKSHELF, OBJ_MUG, OBJ_WOVEN_FENCE, 
    OBJ_HOUSE_VIKING1, OBJ_HOUSE_VIKING_LONG, OBJ_VIKINGFENCE, OBJ_SKULL_HUMAN, OBJ_SKULL_STEER, OBJ_LANTERN_LIT, OBJ_LANTERN_UNLIT, 
    OBJ_WELL_SMALL, OBJ_WELL_LARGE, OBJ_FRUIT_BOWL, OBJ_MELON, OBJ_ROPESTACK, OBJ_CUP_BRONZE, OBJ_CUP_SILVER, OBJ_CUP_GOLD, 
    OBJ_CHALICE_BRONZE, OBJ_CHALICE_SILVER, OBJ_CHALICE_GOLD, OBJ_KINGCUP_BRONZE, OBJ_KINGCUP_SILVER, OBJ_KINGCUP_GOLD, OBJ_VIKINGSHIP, 
    OBJ_VIKINGSHIP2, OBJ_MERCHANTSHIP, OBJ_KHANTENT, MB_EXPORT_0, MB_EXPORT_1, MB_EXPORT_2, MB_EXPORT_3, MB_EXPORT_4, MB_EXPORT_5, 
    MB_EXPORT_6, MB_EXPORT_7, MB_EXPORT_8, MB_EXPORT_9, MB_EXPORT_10, MB_EXPORT_11, MB_EXPORT_12, MB_EXPORT_13, MB_EXPORT_14, MB_EXPORT_15, 
    MB_EXPORT_16, MB_EXPORT_17, MB_EXPORT_18, MB_EXPORT_19, MB_EXPORT_20, MB_EXPORT_21, MB_EXPORT_22, MB_EXPORT_23, MB_EXPORT_24, MB_EXPORT_25, 
    MB_EXPORT_26, MB_EXPORT_27, MB_EXPORT_28, MB_EXPORT_29, MB_EXPORT_30, MB_EXPORT_31, MB_EXPORT_32, MB_EXPORT_33, MB_EXPORT_34, MB_EXPORT_35, 
    MB_EXPORT_36, MB_EXPORT_37, MB_EXPORT_38, MB_EXPORT_39, MB_EXPORT_40, MB_EXPORT_41, MB_EXPORT_42, MB_EXPORT_43, MB_EXPORT_45, MB_EXPORT_46, 
    MB_EXPORT_47, MB_EXPORT_48, MB_EXPORT_49, MB_EXPORT_50, MB_EXPORT_51, MB_EXPORT_52, MB_EXPORT_53, MB_EXPORT_54, MB_EXPORT_55, MB_EXPORT_56, 
    MB_EXPORT_57, MB_EXPORT_58, MB_EXPORT_59, MB_EXPORT_60, MB_EXPORT_61, MB_EXPORT_62, MB_EXPORT_63, MB_EXPORT_64, MB_EXPORT_65, MB_EXPORT_66, 
    MB_EXPORT_67, MB_EXPORT_68, MB_EXPORT_69, MB_EXPORT_70, MB_EXPORT_71, MB_EXPORT_72, MB_EXPORT_73, MB_EXPORT_74, MB_EXPORT_75, MB_EXPORT_76, 
    MB_EXPORT_77, MB_EXPORT_78, MB_EXPORT_79, MB_EXPORT_80, MB_EXPORT_81, MB_EXPORT_82, MB_EXPORT_83, MB_EXPORT_84, MB_EXPORT_85, MB_EXPORT_86, 
    MB_EXPORT_87, MB_EXPORT_88, OBJ_KHAN_THRONE, OBJ_YURT_1, OBJ_YURT_2, ARCH_WALL_0, ARCH_WALL_1, ARCH_WALL_2, ARCH_WALL_3, SICK_DEVIL_STATUE, 
    WATER_POOL, WATER_POOL_MED, WATER_POOL_LARGE, HORSE_ANIMATED, MB_EXPORT_2_1, MB_EXPORT_2_2, MB_EXPORT_2_3, MB_EXPORT_2_4, MB_EXPORT_2_5, 
    MB_EXPORT_2_6, MB_EXPORT_2_7, MB_EXPORT_2_8, MB_EXPORT_2_9, MB_EXPORT_2_10, MB_EXPORT_2_11, MB_EXPORT_2_12, MB_EXPORT_2_13, MB_EXPORT_2_14, 
    MB_EXPORT_2_15, MB_EXPORT_2_16, MB_EXPORT_2_17, MB_EXPORT_2_18, MB_EXPORT_2_19, MB_EXPORT_2_20, MB_EXPORT_2_21, MB_EXPORT_2_22, MB_EXPORT_2_23, 
    MB_EXPORT_2_24, MB_EXPORT_2_25, MB_EXPORT_2_26, MB_EXPORT_2_27, MB_EXPORT_2_28, MB_EXPORT_2_29, MB_EXPORT_2_30, MB_EXPORT_2_31, MB_EXPORT_2_32, 
    MB_EXPORT_2_33, MB_EXPORT_2_34, MB_EXPORT_2_35, MB_EXPORT_2_36, MB_EXPORT_2_37, MB_EXPORT_2_38, MB_EXPORT_2_39, MB_EXPORT_2_40, MB_EXPORT_2_41, 
    MB_EXPORT_2_42, MB_EXPORT_2_43, MB_EXPORT_2_44, MB_EXPORT_2_45, MB_EXPORT_2_46, MB_EXPORT_2_47, MB_EXPORT_2_48, MB_EXPORT_2_49, MB_EXPORT_2_50, 
    MB_EXPORT_2_51, MB_EXPORT_2_52, MB_EXPORT_2_53, MB_EXPORT_2_54, MB_EXPORT_2_55, MB_EXPORT_2_56, MB_EXPORT_2_57, MB_EXPORT_2_58, MB_EXPORT_2_59, 
    MB_EXPORT_2_60, MB_EXPORT_2_61, MB_EXPORT_2_62, MB_EXPORT_2_63, MB_EXPORT_2_64, MB_EXPORT_2_65, MB_EXPORT_2_66, MB_EXPORT_3_01, MB_EXPORT_3_02, 
    MB_EXPORT_3_03, MB_EXPORT_3_04, MB_EXPORT_3_05, MB_EXPORT_3_06, MB_EXPORT_3_07, MB_EXPORT_3_08, MB_EXPORT_3_09, MB_EXPORT_3_10, MB_EXPORT_3_11, 
    MB_EXPORT_3_12, MB_EXPORT_3_13, MB_EXPORT_3_14, MB_EXPORT_3_15, MB_EXPORT_3_16, MB_EXPORT_3_17, MB_EXPORT_3_18, MB_EXPORT_3_19, MB_EXPORT_3_20, 
    MB_EXPORT_3_21, MB_EXPORT_3_22, MB_EXPORT_3_23, MB_EXPORT_3_24, MB_EXPORT_3_25, MB_EXPORT_3_26, MB_EXPORT_3_27, MB_EXPORT_3_28, MB_EXPORT_3_29, 
    MB_EXPORT_3_30, MB_EXPORT_3_31, MB_EXPORT_3_32, MB_EXPORT_3_33, MB_EXPORT_3_34, MB_EXPORT_3_35, MB_EXPORT_3_36, MB_EXPORT_3_37, MB_EXPORT_3_38, 
    MB_EXPORT_3_39, MB_EXPORT_3_40, MB_EXPORT_3_41, MB_EXPORT_3_42, MB_EXPORT_3_43, MB_EXPORT_3_44, MB_EXPORT_3_45, MB_EXPORT_3_46, MB_EXPORT_3_47, 
    MB_EXPORT_3_48, MB_EXPORT_3_49, MB_EXPORT_3_50, MB_EXPORT_3_51, MB_EXPORT_3_52, MB_EXPORT_3_53, MB_EXPORT_3_54, MB_EXPORT_3_55, MB_EXPORT_3_56, 
    MB_EXPORT_3_57, MB_EXPORT_3_58, MB_EXPORT_3_59, MB_EXPORT_3_60, MB_EXPORT_3_61, MB_EXPORT_3_62, MB_EXPORT_3_63, MB_EXPORT_3_64, RIVER, RIVER2, 
    WATER_SMALL, CHURCH_GLASS_A, CHURCH_GLASS_B, CHURCH_GLASS_C, CHURCH_GLASS_D, CHURCH_GLASS_E, CHURCH_GLASS_F, CHURCH_GLASS_G, PALACE_PILLAR, 
    PALACE_WALL, SKYBOX, BYZ_THRONE, SEABED_WATER,

    // reyo

    REYO_BRIDGE,

    CARRIAGE_SMALL, REYO_DOOR, REYO_BOAT,
    REYO_CRATE_BOTTLE, REYO_CRATE_FISH,   REYO_CRATE_FRUITS, REYO_CRATE_HALFBOTTLES, REYO_CRATE_MEAT,   REYO_CRATE_SALAD,
    REYO_CROWMAN, REYO_DUMMY, REYO_WINDMILL,

    REYO_BARRIER, REYO_HEADLOCK, REYO_SIEGETOWER, REYO_LYNCH, REYO_MAPS,
    REYO_DRUM, REYO_LUTE, REYO_PSALTERY,

    RIVER3, RIVER4, RIVER5, RIVER6,

    TRAINTRACKS_RAISED,
    TRAINTRACKS_STONE,
    TRAINTRACKS_LOW,  
    TRAINTRACKS_HOLE, 
    TRAINTRACKS_BIG,

    JANICE_WAGON,
    JANICE_TRAILER,
    JANICE_STAGECOACH,
    JANICE_SALOON,
    JANICE_PRISONERWAGON,
    JANICE_OBJECTS,
    JANICE_DEATH,
    JANICE_CANNON,
    JANICE_CABIN,

    JANICE_TEPEE1,
    JANICE_TEPEE2,
    JANICE_TEPEE3,

    FARMING_RAWGROUND,FARMING_DUGUP,FARMING_PLANTSOIL,TRAP_FOOTLOCK,

    BANDANA_BROWN,BANDANA_GREEN,BANDANA_OLIVE,BANDANA_ORANGE,BANDANA_PURPLE,BANDANA_RED,
    BELT_BLACK,BELT_BLACKB,BELT_BROWN,BELT_BROWNB,BELT_BULLETS,BELT_ORANGE,
    TRAY_1,TRAY_2,TRAY_3,
    BANDOLIER,HOLSTER_1,HOLSTER_2,HOLSTER_3,HOLSTER_4,HOLSTER_5,HOLSTER_6,SHEATH_1,SHEATH_2,
    KERCHIEF_BLUE,KERCHIEF_GREY,KERCHIEF_OLIVE,KERCHIEF_ORANGE,KERCHIEF_PURPLE,KERCHIEF_RED,
    PONCHO_1,PONCHO_2,PONCHO_3,PONCHO_4,PONCHO_5,PONCHO_6,PONCHO_7,PONCHO_8,
    POUCH_1,POUCH_2,POUCH_3,
    VEST_BLACK,VEST_BLUE,VEST_BROWN,VEST_GREEN,VEST_GREY,VEST_REDA,VEST_REDB,

    LONGJOHNS_OBJ,

    BEARD_BLACK1,BEARD_BLACK2,BEARD_BLACK3,BEARD_BLACK4,BEARD_BLACK5,BEARD_BLACK6,
    BEARD_BROWN1,BEARD_BROWN2,BEARD_BROWN3,BEARD_BROWN4,BEARD_BROWN5,BEARD_BROWN6,
    BEARD_GREY1,BEARD_GREY2,BEARD_GREY3,BEARD_GREY4,BEARD_GREY5,BEARD_GREY6,
    BEARD_PURPLE1,BEARD_PURPLE2,BEARD_PURPLE3,BEARD_PURPLE4,BEARD_PURPLE5,BEARD_PURPLE6,

    FARM_BASKET_RAPPLE, FARM_BASKET_GAPPLE, FARM_BASKET_CABBAGE, FARM_BASKET_TOMATO,
    FARM_BASKET_WHEAT, FARM_BASKET_PUMPKIN, FARM_BASKET_EMPTY,

    GLOVES_BLACK,GLOVES_BROWN,

    NUGGET_GOLD,

    ORE_COAL,ORE_COPPER,ORE_GOLD,ORE_IRON,ORE_TIN,

    HATCHET,PICKAXE,

    NUGGET_COAL,NUGGET_COPPER,NUGGET_IRON,NUGGET_TIN,

    FARMING_BASEPLOT, FARMING_CABBAGEPLOT, FARMING_PUMPKINPLOT, FARMING_TOMATOPLOT, FARMING_APPLEPLOT,
    FARMING_WHEATPLOT,

    ARROW_SIGN_OBJ,BANK_SIGN_OBJ,GENERALSTORE_SIGN_OBJ,GUNSMITH_SIGN_OBJ,HOTEL_SIGN_OBJ,JAIL_SIGN_OBJ,SALOON_SIGN_OBJ,
    SHERIFFS_SIGN_OBJ,STABLE_SIGN_OBJ,TELEGRAPH_SIGN_OBJ,TRADINGPOST_SIGN_OBJ,WELLSFARGO_SIGN_OBJ,

    REYO_SCHOOLMAP,
    DIGNITY_TABLE0,
    DIGNITY_TABLE1,
    DIGNITY_TABLE2,
    DIGNITY_TABLE3
} ;

enum { //custom skin index

    APACHE1 = 20000,
    APACHE2,APACHE3,
    CIVILIAN1,CIVILIAN2,CIVILIAN3,CIVILIAN4,CIVILIAN5,CIVILIAN6,CIVILIAN7,CIVILIAN8,CIVILIAN9,CIVILIAN10,CIVILIAN11,
    COP1,
    COWBOY1,COWBOY2,COWBOY3,COWBOY4,COWBOY5,COWBOY6,COWBOY7,COWBOY8,COWBOY9,COWBOY10,COWBOY11,COWBOY12,COWBOY13,COWBOY14,COWBOY15,COWBOY16,COWBOY17,COWBOY18,
    MEXICAN4,MEXICAN5,MEXICAN8,
    FEMALE1,FEMALE2,FEMALE3,FEMALE4,FEMALE5,FEMALE6,FEMALE7,FEMALE8,FEMALE9,
};

LoadObjectModels() {


    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KCD_BANNER_BLACKDRAGON, "banners/banner_blackdragon.dff","banners/banner_blackdragon.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KCD_BANNER_BROWNTEMPLAR,"banners/banner_browntemplars.dff", "banners/banner_browntemplars.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KCD_BANNER_BYZANTINE,"banners/banner_byzantine.dff",  "banners/banner_byzantine.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KCD_BANNER_CRUSADE1, "banners/banner_crusade1.dff","banners/banner_crusade1.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KCD_BANNER_CRUSADE2, "banners/banner_crusade2.dff","banners/banner_crusade2.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KCD_BANNER_FRANCE,"banners/banner_france.dff",  "banners/banner_france.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KCD_BANNER_HRE,"banners/banner_hre.dff",  "banners/banner_hre.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KCD_BANNER_JERUSALEM,"banners/banner_jerusalem.dff",  "banners/banner_jerusalem.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KCD_BANNER_REDLION,  "banners/banner_redlion.dff", "banners/banner_redlion.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KCD_BANNER_STRIPESTARS, "banners/banner_stripestars.dff","banners/banner_stripestars.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KCD_BANNER_VIKING,"banners/banner_viking.dff","banners/banner_viking.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_ANVIL, "anvil.dff","anvil.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_BARREL,"barrel.dff",  "barrel.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_CRATE, "crate.dff","crate.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_BOOKCASE, "bookcase.dff","bookcase.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_WEP_SHORTSWORD, "weapons/shortsword.dff",  "weapons/shortsword.txd");
  

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_BEERGLASS,"beerglass.dff",  "beerglass.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_BENCH, "bench.dff","bench.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_BOOKSHELF,"bookshelf.dff",  "bookshelf.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_MUG,"mug.dff",  "mug.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_WOVEN_FENCE, "woven_fence.dff","woven_fence.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_VIKINGFENCE, "vikingfence.dff","vikingfence.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_HOUSE_VIKING1, "houses/vikinghouse.dff", "houses/vikinghouse.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_HOUSE_VIKING_LONG,"houses/viking_longhouse.dff", "houses/viking_longhouse.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_SKULL_HUMAN,"skull_human.dff", "skull_human.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_SKULL_STEER,"skull_steer.dff", "skull_steer.txd");


    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_LANTERN_LIT,"lantern_lit.dff", "lantern_lit.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_LANTERN_UNLIT,  "lantern_unlit.dff", "lantern_unlit.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_WELL_SMALL,  "well_small.dff", "well_small.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_WELL_LARGE,  "well_big.dff", "well_big.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_FRUIT_BOWL, "fruitbowl.dff", "fruitbowl.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_MELON,"melon.dff","melon.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_ROPESTACK,  "ropestack.dff", "ropestack.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_CUP_BRONZE,"cups/bronzecup.dff", "cups/cuptexture.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_CUP_SILVER,"cups/silvercup.dff", "cups/cuptexture.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_CUP_GOLD,  "cups/goldcup.dff","cups/cuptexture.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_CHALICE_BRONZE,  "cups/chalicebronze.dff", "cups/chalicetexture.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_CHALICE_SILVER,  "cups/chalicesilver.dff", "cups/chalicetexture.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_CHALICE_GOLD, "cups/chalicegold.dff", "cups/chalicetexture.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KINGCUP_BRONZE,  "cups/kingcupbronze.dff", "cups/kingcups.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KINGCUP_SILVER,  "cups/kingcupsilver.dff", "cups/kingcups.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KINGCUP_GOLD, "cups/kingcupgold.dff", "cups/kingcups.txd");


    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_VIKINGSHIP, "vikingship.dff", "vikingship.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_VIKINGSHIP2, "vikingship2.dff", "vikingship2.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_MERCHANTSHIP, "Ship.dff", "Ship.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KHANTENT,"houses/KhanTent.dff",  "houses/KhanTent.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_KHAN_THRONE, "KhanThrone.dff", "KhanThrone.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_YURT_1, "Yurt1.dff", "Yurt1.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, OBJ_YURT_2, "Yurt2.dff", "Yurt2.txd");

    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2, "mbexports/basket.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3, "mbexports/bed_hay.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_4, "mbexports/bed_rolled.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_5, "mbexports/bed_stacked.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_6, "mbexports/bowl.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_7, "mbexports/bowl_a.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_8, "mbexports/bowl_b.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_9, "mbexports/bread_a.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_10, "mbexports/bread_b.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_11, "mbexports/bread_slice.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_12, "mbexports/bucket.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_13, "mbexports/cabbage_a.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_14, "mbexports/cabbage_b.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_15, "mbexports/cauldron.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_16, "mbexports/cheese_a.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_17, "mbexports/cheese_b.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_18, "mbexports/cheese_slice.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_19, "mbexports/chest_a.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_20, "mbexports/chest_b.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_21, "mbexports/cooker_hanger.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_22, "mbexports/eating_knife.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_23, "mbexports/fish_a.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_24, "mbexports/fish_b.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_25, "mbexports/lettuce.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_26, "mbexports/meat_hanger.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_27, "mbexports/omelet_pan.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_28, "mbexports/plate.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_29, "mbexports/soup_spoon.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_30, "mbexports/spoon.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_31, "mbexports/sticker.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_32, "mbexports/trough.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_33, "mbexports/utensil_a.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_34, "mbexports/veg_a.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_35, "mbexports/veg_b.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_36, "mbexports/veg_c.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_37, "mbexports/washer_a.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_38, "mbexports/washer_b.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_39, "mbexports/amphora_slim.dff",    "txd_goods_mesh.txd" ) ; // goods_mesh.brf
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_40, "mbexports/barrel_ale.dff",     "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_41, "mbexports/barrel_wine.dff",     "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_42, "mbexports/cheese.dff",           "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_43, "mbexports/crate.dff",           "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_45, "mbexports/fur_pack.dff",       "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_46, "mbexports/iron_bar.dff",       "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_47, "mbexports/oil.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_48, "mbexports/raw_meat.dff",       "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_49, "mbexports/sack_salt.dff",       "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_50, "mbexports/sack_spice.dff",      "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_51, "mbexports/sack_wheat.dff",      "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_52, "mbexports/sack_wool.dff",      "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_53, "mbexports/smoked_fish.dff",     "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_54, "mbexports/smoked_meat.dff",     "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_55, "mbexports/wrap_linen.dff",     "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_56, "mbexports/wrap_velvet.dff",     "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_57, "mbexports/book_a.dff",                "txd_goods_mesh.txd" ) ;    //object_b.brf
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_58, "mbexports/book_b.dff",                "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_59, "mbexports/book_c.dff",                "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_60, "mbexports/book_d.dff",                "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_61, "mbexports/book_e.dff",                "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_62, "mbexports/book_f.dff",                "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_63, "mbexports/book_open.dff",             "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_64, "mbexports/broken_boat.dff",           "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_65, "mbexports/chair_trestle.dff",         "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_66, "mbexports/garlic_a.dff",              "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_67, "mbexports/garlic_b.dff",              "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_68, "mbexports/grave_a.dff",               "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_69, "mbexports/table_trestle_large.dff",   "txd_goods_mesh.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_70, "mbexports/table_trestle_small.dff",   "txd_goods_mesh.txd" ) ;

       
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_71, "castles/a/bannerment_a.dff",              "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_72, "castles/a/bannerment_a_des.dff",          "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_73, "castles/a/bannerment_b.dff",              "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_74, "castles/a/bannerment_b_des.dff",          "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_75, "castles/a/bannerment_corner_a.dff",      "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_76, "castles/a/bannerment_corner_b.dff",      "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_77, "castles/a/bannerment_corner_c.dff",       "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_78, "castles/a/bannerment_gatehouse.dff",      "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_79, "castles/a/bannerment_gatehouse2.dff",     "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_81, "castles/a/drawbridge_down.dff",           "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_82, "castles/a/drawbridge_up.dff",             "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_83, "castles/a/guardtower.dff",                "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_84, "castles/a/keep.dff",                      "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_85, "castles/a/roundtower.dff",                "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_86, "castles/a/stairs_a.dff",                  "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_87, "castles/a/stairs_b.dff",                  "castles/a/castle_a.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_88, "castles/a/stairs_c.dff",                  "castles/a/castle_a.txd" ) ;

    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, ARCH_WALL_0,    "arch_wall_0.dff", "arch_walls.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, ARCH_WALL_1,    "arch_wall_1.dff", "arch_walls.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, ARCH_WALL_2,    "arch_wall_2.dff", "arch_walls.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, ARCH_WALL_3,    "arch_wall_3.dff", "arch_walls.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, SICK_DEVIL_STATUE, "sick.dff", "sick.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, WATER_POOL,      "waterpool.dff", "waterpool.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, WATER_POOL_MED,  "waterpool_med.dff", "waterpool.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, WATER_POOL_LARGE, "waterpool_large.dff", "waterpool.txd" ) ;

    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_1, "mbexports2/alter.dff",               "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_2, "mbexports2/arena_arms.dff",          "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_3, "mbexports2/barrel_tavern.dff",       "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_4, "mbexports2/bearskin_rug.dff",        "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_5, "mbexports2/bed.dff",                 "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_6, "mbexports2/bowl_wood.dff",           "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_7, "mbexports2/brazier.dff",             "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_8, "mbexports2/broom.dff",               "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_9, "mbexports2/bucket.dff",              "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_10, "mbexports2/campfire.dff",           "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_11, "mbexports2/candle_a.dff",           "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_12, "mbexports2/candle_b.dff",           "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_13, "mbexports2/candle_c.dff",           "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_14, "mbexports2/cart_a.dff",             "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_15, "mbexports2/cart_b.dff",             "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_16, "mbexports2/cauldron_a.dff",         "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_17, "mbexports2/cauldron_b.dff",         "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_18, "mbexports2/chandelier.dff",         "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_19, "mbexports2/chandelier_table.dff",   "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_20, "mbexports2/counter_tavern.dff",     "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_21, "mbexports2/crate.dff",              "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_22, "mbexports2/cup.dff",                "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_23, "mbexports2/curtain.dff",            "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_24, "mbexports2/dish_metal.dff",         "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_25, "mbexports2/gothic_bench.dff",       "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_26, "mbexports2/gothic_chair.dff",       "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_27, "mbexports2/gothic_table.dff",       "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_28, "mbexports2/gothic_table_b.dff",     "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_29, "mbexports2/gothic_table_c.dff",     "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_30, "mbexports2/hanginglamp.dff",        "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_31, "mbexports2/hanginglamp_empty.dff",  "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_32, "mbexports2/hay_a.dff",              "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_33, "mbexports2/hay_b.dff",              "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_34, "mbexports2/hay_c.dff",              "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_35, "mbexports2/jug.dff",                "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_36, "mbexports2/ladder.dff",             "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_37, "mbexports2/merchant_shelf.dff",     "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_38, "mbexports2/merchant_stall.dff",     "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_39, "mbexports2/potlamp.dff",            "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_40, "mbexports2/sack.dff",               "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_41, "mbexports2/shelf.dff",              "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_42, "mbexports2/sign_merchant.dff",      "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_43, "mbexports2/sign_tavern.dff",        "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_44, "mbexports2/skull_a.dff",            "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_45, "mbexports2/skull_b.dff",            "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_46, "mbexports2/skull_c.dff",            "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_47, "mbexports2/skull_d.dff",            "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_48, "mbexports2/spike_gate.dff",         "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_49, "mbexports2/tavern_barrell.dff",     "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_50, "mbexports2/tavern_chair_a.dff",     "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_51, "mbexports2/tavern_chair_b.dff",     "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_52, "mbexports2/tavern_table_a.dff",     "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_53, "mbexports2/tavern_table_b.dff",     "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_54, "mbexports2/tavern_table_c.dff",     "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_55, "mbexports2/tavern_table_d.dff",     "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_56, "mbexports2/tavern_table_e.dff",     "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_57, "mbexports2/torch.dff",              "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_58, "mbexports2/weapon_rack_a.dff",      "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_59, "mbexports2/weapon_rack_b.dff",      "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_60, "mbexports2/well_a.dff",             "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_61, "mbexports2/wheel.dff",              "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_62, "mbexports2/wood_log_a.dff",         "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_63, "mbexports2/wood_log_b.dff",         "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_64, "mbexports2/wood_pile.dff",          "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_65, "mbexports2/wooden_stall_a.dff",     "txd_goods_mesh.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_2_66, "mbexports2/woven_rug.dff",          "txd_goods_mesh.txd");


    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_01, "mbexports3/amber.dff",              "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_02, "mbexports3/barley.dff",             "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_03, "mbexports3/barley_bag.dff",         "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_04, "mbexports3/basket_big.dff",         "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_05, "mbexports3/basket_large.dff",       "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_06, "mbexports3/basket_small.dff",       "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_07, "mbexports3/bear_skin.dff",          "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_08, "mbexports3/boar.dff",               "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_09, "mbexports3/bowl_big.dff",           "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_10, "mbexports3/bowl_small.dff",         "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_11, "mbexports3/bread.dff",              "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_12, "mbexports3/brownpants_a.dff",       "mbexports3/brownpants.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_13, "mbexports3/brownpants_b.dff",       "mbexports3/brownpants.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_14, "mbexports3/butter.dff",             "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_15, "mbexports3/cheese.dff",             "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_16, "mbexports3/chick.dff",              "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_17, "mbexports3/chicken.dff",            "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_18, "mbexports3/coin_bronze.dff",        "mbexports3/coins.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_19, "mbexports3/coin_gold.dff",          "mbexports3/coins.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_20, "mbexports3/coin_silver.dff",        "mbexports3/coins.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_21, "mbexports3/date_fruit_plane.dff",   "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_22, "mbexports3/date_inv.dff",           "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_23, "mbexports3/doublenet.dff",          "mbexports3/doublenet.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_24, "mbexports3/dried_meat.dff",         "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_25, "mbexports3/drinking_horn_mug.dff",  "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_26, "mbexports3/dye_blue.dff",           "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_27, "mbexports3/dye_red.dff",            "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_28, "mbexports3/dye_yellow.dff",         "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_29, "mbexports3/dyes.dff",               "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_30, "mbexports3/fishies.dff",            "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_31, "mbexports3/flax.dff",               "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_32, "mbexports3/fox_pelt.dff",           "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_33, "mbexports3/fruits.dff",             "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_34, "mbexports3/gold_a.dff",             "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_35, "mbexports3/gold_b.dff",             "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_36, "mbexports3/grape_plane.dff",        "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_37, "mbexports3/grapes.dff",             "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_38, "mbexports3/hidestack.dff",          "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_39, "mbexports3/honey.dff",              "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_40, "mbexports3/horseshoe.dff",          "mbexports3/horseshoe.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_41, "mbexports3/jewelry.dff",            "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_42, "mbexports3/kegs_ale.dff",           "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_43, "mbexports3/logs.dff",               "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_44, "mbexports3/meat.dff",               "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_45, "mbexports3/meat_b.dff",             "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_46, "mbexports3/olive_plane.dff",        "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_47, "mbexports3/olives.dff",             "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_48, "mbexports3/piggy.dff",              "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_49, "mbexports3/piggy_uncooked.dff",     "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_50, "mbexports3/rools.dff",              "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_51, "mbexports3/salt.dff",               "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_52, "mbexports3/sausages.dff",           "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_53, "mbexports3/silk_bundle.dff",        "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_54, "mbexports3/silk_rolls.dff",         "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_55, "mbexports3/silk_single.dff",        "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_56, "mbexports3/silver.dff",             "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_57, "mbexports3/soapastone_bowl.dff",    "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_58, "mbexports3/tanning_rack.dff",       "mbexports3/raw_materials.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_59, "mbexports3/tar.dff",                "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_60, "mbexports3/tusks_ivory_walrus.dff", "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_61, "mbexports3/veggies.dff",            "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_62, "mbexports3/wine.dff",               "mbexports3/vc_food.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_63, "mbexports3/wool_cask.dff",          "mbexports3/vc_tradingitems.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, MB_EXPORT_3_64, "mbexports3/wool_cloth.dff",         "mbexports3/raw_materials.txd" );

    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, RIVER, "river.dff",         "river.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, RIVER2, "river2.dff",       "river2.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, RIVER3, "river3.dff",       "river3.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, RIVER4, "river4.dff",       "river4.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, RIVER5, "river5.dff",       "river5.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, RIVER6, "river6.dff",       "river6.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, WATER_SMALL, "water_small.dff",       "water_small.txd" );

    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, CHURCH_GLASS_A, "palace/church_glass_a.dff",       "palace/palace_items.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, CHURCH_GLASS_B, "palace/church_glass_b.dff",       "palace/palace_items.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, CHURCH_GLASS_C, "palace/church_glass_c.dff",       "palace/palace_items.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, CHURCH_GLASS_D, "palace/church_glass_d.dff",       "palace/palace_items.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, CHURCH_GLASS_E, "palace/church_glass_e.dff",       "palace/palace_items.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, CHURCH_GLASS_F, "palace/church_glass_f.dff",       "palace/palace_items.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, CHURCH_GLASS_G, "palace/church_glass_g.dff",       "palace/palace_items.txd" );

    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, PALACE_PILLAR, "palace/palace_pillar.dff",       "palace/palace_items.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, PALACE_WALL, "palace/palace_wall.dff",       "palace/palace_items.txd" );

    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, SKYBOX, "skybox.dff",       "skybox.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, BYZ_THRONE, "palace/throne.dff",       "palace/throne.txd" );

    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, SEABED_WATER, "seabed.dff",       "seabed.txd" );

    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_BRIDGE,   "reyo/bridge.dff"         , "reyo/bridge.txd" );
    
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, CARRIAGE_SMALL, "transport/carriage.dff", "transport/carriage.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_DOOR,   "reyo/door.dff"         , "reyo/door.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_BOAT,   "reyo/boat.dff"         , "reyo/boat.txd" );

    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_CRATE_BOTTLE,      "reyo/cratebottles.dff",         "reyo/cratebottles.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_CRATE_FISH,        "reyo/cratefish.dff",            "reyo/cratefish.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_CRATE_FRUITS,      "reyo/cratefruits.dff",          "reyo/cratefruits.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_CRATE_HALFBOTTLES, "reyo/cratehalfbottles.dff",     "reyo/cratehalfbottles.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_CRATE_MEAT,        "reyo/cratemeat.dff",            "reyo/cratemeat.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_CRATE_SALAD,       "reyo/cratesalad.dff",           "reyo/cratesalad.txd");

    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_CROWMAN,            "reyo/crowman.dff",             "reyo/crowman.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_DUMMY,              "reyo/dummy.dff",               "reyo/dummy.txd" ) ;
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_WINDMILL,            "reyo/windmill.dff",            "reyo/windmill.txd" ) ;

    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_BARRIER,        "reyo/barrier.dff",     "reyo/barrier.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_HEADLOCK,       "reyo/headlock.dff",    "reyo/headlock.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_SIEGETOWER,     "reyo/siegetower.dff",  "reyo/siegetower.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_LYNCH,          "reyo/lynch.dff",       "reyo/lynch.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_MAPS,           "reyo/maps.dff",        "reyo/maps.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_DRUM,           "reyo/drum.dff",        "reyo/drum.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_LUTE,           "reyo/lute.dff",        "reyo/lute.txd" );
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, REYO_PSALTERY,       "reyo/psaltery.dff",    "reyo/psaltery.txd" );
    
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, TRAINTRACKS_RAISED,    "train/trackraised.dff",  "train/traintracks.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, TRAINTRACKS_STONE,     "train/trackstone.dff",   "train/traintracks.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, TRAINTRACKS_LOW,       "train/tracklow.dff",     "train/traintracks.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, TRAINTRACKS_HOLE,      "train/trackhole.dff",    "train/traintracks.txd");
    AddSimpleModel ( -1, CUSTOM_OBJECT_BASEID, TRAINTRACKS_BIG,       "train/trackbig.dff",     "train/traintracks.txd");
    
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, JANICE_WAGON,              "wwrp/janice/wagon.dff",            "wwrp/janice/objects.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, JANICE_TRAILER,            "wwrp/janice/trailer.dff",          "wwrp/janice/objects.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, JANICE_STAGECOACH,         "wwrp/janice/stagecoach.dff",       "wwrp/janice/objects.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, JANICE_SALOON,             "wwrp/janice/saloon.dff",           "wwrp/janice/objects.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, JANICE_PRISONERWAGON,      "wwrp/janice/prisonerwagon.dff",    "wwrp/janice/objects.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, JANICE_DEATH,              "wwrp/janice/death.dff",            "wwrp/janice/objects.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, JANICE_CANNON,             "wwrp/janice/cannon.dff",           "wwrp/janice/objects.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, JANICE_CABIN,              "wwrp/janice/cabin.dff",            "wwrp/janice/objects.txd");


    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, JANICE_TEPEE1,              "wwrp/janice/tepee1.dff",            "wwrp/janice/tepee1.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, JANICE_TEPEE2,              "wwrp/janice/tepee2.dff",            "wwrp/janice/tepee2.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, JANICE_TEPEE3,              "wwrp/janice/tepee3.dff",            "wwrp/janice/tepee3.txd");


    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, FARMING_RAWGROUND, "farming/rawground.dff", "farming/rawground.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, FARMING_DUGUP, "farming/dugup.dff", "farming/dugup.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, FARMING_PLANTSOIL, "farming/plantsoil.dff", "farming/plantsoil.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, TRAP_FOOTLOCK, "traps/footlock.dff", "traps/footlock.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, BANDANA_BROWN, "ww_bandanas/bandana-brown.dff","ww_bandanas/bandana-brown.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, BANDANA_GREEN, "ww_bandanas/bandana-green.dff","ww_bandanas/bandana-green.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, BANDANA_OLIVE, "ww_bandanas/bandana-olive.dff","ww_bandanas/bandana-olive.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, BANDANA_ORANGE, "ww_bandanas/bandana-orange.dff","ww_bandanas/bandana-orange.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, BANDANA_PURPLE, "ww_bandanas/bandana-purple.dff","ww_bandanas/bandana-purple.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, BANDANA_RED, "ww_bandanas/bandana-red.dff","ww_bandanas/bandana-red.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  BELT_BLACK          ,"ww_belts/belt-black.dff","ww_belts/belt-black.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  BELT_BLACKB          ,"ww_belts/belt-blackb.dff","ww_belts/belt-blackb.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  BELT_BROWN          ,"ww_belts/belt-brown.dff","ww_belts/belt-brown.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  BELT_BROWNB          ,"ww_belts/belt-brownb.dff","ww_belts/belt-brownb.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  BELT_BULLETS          ,"ww_belts/belt-bullets.dff","ww_belts/belt-bullets.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  BELT_ORANGE          ,"ww_belts/belt-orange.dff","ww_belts/belt-orange.txd");


    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  TRAY_1          ,"ww_food/tray1.dff","ww_food/tray1.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  TRAY_2          ,"ww_food/tray2.dff","ww_food/tray2.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  TRAY_3          ,"ww_food/tray3.dff","ww_food/tray3.txd");


    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  BANDOLIER          ,"ww_holsters/bandolier.dff","ww_holsters/bandolier.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  HOLSTER_1          ,"ww_holsters/holster1.dff","ww_holsters/holster1.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  HOLSTER_2          ,"ww_holsters/holster2.dff","ww_holsters/holster2.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  HOLSTER_3          ,"ww_holsters/holster3.dff","ww_holsters/holster3.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  HOLSTER_4          ,"ww_holsters/holster4.dff","ww_holsters/holster4.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  HOLSTER_5          ,"ww_holsters/holster5.dff","ww_holsters/holster5.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  HOLSTER_6          ,"ww_holsters/holster6.dff","ww_holsters/holster6.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  SHEATH_1          ,"ww_holsters/sheath1.dff","ww_holsters/sheath1.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  SHEATH_2          ,"ww_holsters/sheath2.dff","ww_holsters/sheath2.txd");


    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  KERCHIEF_BLUE          ,"ww_kerchiefs/kerchief-blue.dff","ww_kerchiefs/kerchief-blue.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  KERCHIEF_GREY          ,"ww_kerchiefs/kerchief-grey.dff","ww_kerchiefs/kerchief-grey.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  KERCHIEF_OLIVE          ,"ww_kerchiefs/kerchief-olive.dff","ww_kerchiefs/kerchief-olive.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  KERCHIEF_ORANGE          ,"ww_kerchiefs/kerchief-orange.dff","ww_kerchiefs/kerchief-orange.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  KERCHIEF_PURPLE          ,"ww_kerchiefs/kerchief-purple.dff","ww_kerchiefs/kerchief-purple.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  KERCHIEF_RED          ,"ww_kerchiefs/kerchief-red.dff","ww_kerchiefs/kerchief-red.txd");


    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  PONCHO_1          ,"ww_ponchos/poncho1.dff","ww_ponchos/poncho1.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  PONCHO_2          ,"ww_ponchos/poncho2.dff","ww_ponchos/poncho2.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  PONCHO_3          ,"ww_ponchos/poncho3.dff","ww_ponchos/poncho3.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  PONCHO_4          ,"ww_ponchos/poncho4.dff","ww_ponchos/poncho4.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  PONCHO_5          ,"ww_ponchos/poncho5.dff","ww_ponchos/poncho5.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  PONCHO_6          ,"ww_ponchos/poncho6.dff","ww_ponchos/poncho6.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  PONCHO_7          ,"ww_ponchos/poncho7.dff","ww_ponchos/poncho7.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  PONCHO_8          ,"ww_ponchos/poncho8.dff","ww_ponchos/poncho8.txd");


    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  POUCH_1          ,"ww_pouches/pouch1.dff","ww_pouches/pouch1.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  POUCH_2          ,"ww_pouches/pouch2.dff","ww_pouches/pouch2.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  POUCH_3          ,"ww_pouches/pouch3.dff","ww_pouches/pouch3.txd");


    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  VEST_BLACK          ,"ww_vests/vest-black.dff","ww_vests/vest-black.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  VEST_BLUE          ,"ww_vests/vest-blue.dff","ww_vests/vest-blue.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  VEST_BROWN          ,"ww_vests/vest-brown.dff","ww_vests/vest-brown.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  VEST_GREEN          ,"ww_vests/vest-green.dff","ww_vests/vest-green.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  VEST_GREY          ,"ww_vests/vest-grey.dff","ww_vests/vest-grey.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  VEST_REDA          ,"ww_vests/vest-reda.dff","ww_vests/vest-reda.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  VEST_REDB          ,"ww_vests/vest-redb.dff","ww_vests/vest-redb.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,  LONGJOHNS_OBJ      ,"longjohn.dff","longjohn.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_BLACK1,"beards/beard-black1.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_BLACK2,"beards/beard-black2.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_BLACK3,"beards/beard-black3.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_BLACK4,"beards/beard-black4.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_BLACK5,"beards/beard-black5.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_BLACK6,"beards/beard-black6.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_BROWN1,"beards/beard-brown1.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_BROWN2,"beards/beard-brown2.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_BROWN3,"beards/beard-brown3.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_BROWN4,"beards/beard-brown4.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_BROWN5,"beards/beard-brown5.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_BROWN6,"beards/beard-brown6.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_GREY1,"beards/beard-grey1.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_GREY2,"beards/beard-grey2.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_GREY3,"beards/beard-grey3.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_GREY4,"beards/beard-grey4.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_GREY5,"beards/beard-grey5.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_GREY6,"beards/beard-grey6.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_PURPLE1,"beards/beard-purple1.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_PURPLE2,"beards/beard-purple2.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_PURPLE3,"beards/beard-purple3.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_PURPLE4,"beards/beard-purple4.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_PURPLE5,"beards/beard-purple5.dff","beards/beards.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,BEARD_PURPLE6,"beards/beard-purple6.dff","beards/beards.txd");

    //AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,FARM_BASKET_ORANGE,"baskets/oranges-basket.dff","baskets/oranges-basket.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,FARM_BASKET_RAPPLE,"baskets/redapple-basket.dff","baskets/redapple-basket.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,FARM_BASKET_GAPPLE,"baskets/greenapple-basket.dff","baskets/greenapple-basket.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,FARM_BASKET_PUMPKIN,"baskets/pumpkin-basket.dff","baskets/pumpkin-basket.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,FARM_BASKET_TOMATO,"baskets/tomato-basket.dff","baskets/tomato-basket.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,FARM_BASKET_CABBAGE,"baskets/cabbage-basket.dff","baskets/cabbage-basket.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,FARM_BASKET_WHEAT,"baskets/wheat-basket.dff","baskets/wheat-basket.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,FARM_BASKET_EMPTY,"empty/empty-basket.dff","baskets/empty-basket.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,GLOVES_BLACK,"ww_gloves/blackgloves.dff","ww_gloves/blackgloves.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,GLOVES_BROWN,"ww_gloves/browngloves.dff","ww_gloves/browngloves.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,NUGGET_COAL,"ww_rocks/coal-nugget.dff","ww_rocks/nuggets.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,NUGGET_COPPER,"ww_rocks/copper-nugget.dff","ww_rocks/nuggets.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,NUGGET_GOLD,"ww_rocks/gold-nugget.dff","ww_rocks/nuggets.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,NUGGET_IRON,"ww_rocks/iron-nugget.dff","ww_rocks/nuggets.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,NUGGET_TIN,"ww_rocks/tin-nugget.dff","ww_rocks/nuggets.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,ORE_COAL,"ww_rocks/coalore.dff","ww_rocks/coalore.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,ORE_COPPER,"ww_rocks/copperore.dff","ww_rocks/copperore.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,ORE_GOLD,"ww_rocks/goldore.dff","ww_rocks/goldore.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,ORE_IRON,"ww_rocks/ironore.dff","ww_rocks/ironore.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,ORE_TIN,"ww_rocks/tinore.dff","ww_rocks/tinore.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,HATCHET,"ww_tools/hatchet.dff","ww_tools/hatchet.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,PICKAXE,"ww_tools/pickaxe.dff","ww_tools/pickaxe.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,FARMING_BASEPLOT,"farming/newplot.dff","farming/newplot.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,FARMING_CABBAGEPLOT,"farming/cabbage.dff","farming/cabbage.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,FARMING_PUMPKINPLOT,"farming/pumpkins.dff","farming/pumpkins.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,FARMING_TOMATOPLOT,"farming/tomatoes.dff","farming/tomatoes.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,FARMING_APPLEPLOT,"farming/tree.dff","farming/tree.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID,FARMING_WHEATPLOT,"farming/wheat.dff","farming/wheat.txd");

    AddSimpleModel(-1,CUSTOM_OBJECT_BASEID,ARROW_SIGN_OBJ,"ww_signs/arrow-sign.dff","ww_signs/signs.txd");
    AddSimpleModel(-1,CUSTOM_OBJECT_BASEID,BANK_SIGN_OBJ,"ww_signs/bank-sign.dff","ww_signs/signs.txd");
    AddSimpleModel(-1,CUSTOM_OBJECT_BASEID,GENERALSTORE_SIGN_OBJ,"ww_signs/generalstore-sign.dff","ww_signs/signs.txd");
    AddSimpleModel(-1,CUSTOM_OBJECT_BASEID,GUNSMITH_SIGN_OBJ,"ww_signs/gunsmith-sign.dff","ww_signs/signs.txd");
    AddSimpleModel(-1,CUSTOM_OBJECT_BASEID,HOTEL_SIGN_OBJ,"ww_signs/hotel-sign.dff","ww_signs/signs.txd");
    AddSimpleModel(-1,CUSTOM_OBJECT_BASEID,JAIL_SIGN_OBJ,"ww_signs/jail-sign.dff","ww_signs/signs.txd");
    AddSimpleModel(-1,CUSTOM_OBJECT_BASEID,SALOON_SIGN_OBJ,"ww_signs/saloon-sign.dff","ww_signs/signs.txd");
    AddSimpleModel(-1,CUSTOM_OBJECT_BASEID,SHERIFFS_SIGN_OBJ,"ww_signs/sheriffs-sign.dff","ww_signs/signs.txd");
    AddSimpleModel(-1,CUSTOM_OBJECT_BASEID,STABLE_SIGN_OBJ,"ww_signs/stable-sign.dff","ww_signs/signs.txd");
    AddSimpleModel(-1,CUSTOM_OBJECT_BASEID,TELEGRAPH_SIGN_OBJ,"ww_signs/telegraph-sign.dff","ww_signs/signs.txd");
    AddSimpleModel(-1,CUSTOM_OBJECT_BASEID,TRADINGPOST_SIGN_OBJ,"ww_signs/tradingpost-sign.dff","ww_signs/signs.txd");
    AddSimpleModel(-1,CUSTOM_OBJECT_BASEID,WELLSFARGO_SIGN_OBJ,"ww_signs/wellsfargo-sign.dff","ww_signs/signs.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, REYO_SCHOOLMAP, "lsrpk/beaumont-high.dff", "lsrpk/beaumont-high.txd");

    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, DIGNITY_TABLE0, "lsrpk/props/ghetto_table_black.dff", "lsrpk/props/ghetto_table_textures.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, DIGNITY_TABLE1, "lsrpk/props/ghetto_table_blue.dff", "lsrpk/props/ghetto_table_textures.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, DIGNITY_TABLE2, "lsrpk/props/ghetto_table_green.dff", "lsrpk/props/ghetto_table_textures.txd");
    AddSimpleModel(-1, CUSTOM_OBJECT_BASEID, DIGNITY_TABLE3, "lsrpk/props/ghetto_table_red.dff", "lsrpk/props/ghetto_table_textures.txd");

    return true ;
}

LoadSkinModels() {

    AddCharModel(CUSTOM_SKIN_MALE_BASEID,APACHE1,"ww_skins/apache1.dff","ww_skins/apache1.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,APACHE2,"ww_skins/apache2.dff","ww_skins/apache2.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,APACHE3,"ww_skins/apache3.dff","ww_skins/apache3.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,CIVILIAN1,"ww_skins/civilian1.dff","ww_skins/civilian1.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,CIVILIAN1,"ww_skins/civilian2.dff","ww_skins/civilian2.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,CIVILIAN1,"ww_skins/civilian3.dff","ww_skins/civilian3.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,CIVILIAN1,"ww_skins/civilian4.dff","ww_skins/civilian4.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,CIVILIAN1,"ww_skins/civilian5.dff","ww_skins/civilian5.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,CIVILIAN1,"ww_skins/civilian6.dff","ww_skins/civilian6.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,CIVILIAN1,"ww_skins/civilian7.dff","ww_skins/civilian7.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,CIVILIAN8,"ww_skins/civilian8.dff","ww_skins/civilian8.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,CIVILIAN9,"ww_skins/civilian9.dff","ww_skins/civilian9.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,CIVILIAN10,"ww_skins/civilian10.dff","ww_skins/civilian10.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,CIVILIAN11,"ww_skins/civilian11.dff","ww_skins/civilian11.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COP1,"ww_skins/cop1.dff","ww_skins/cop1.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY1,"ww_skins/cowboy1.dff","ww_skins/cowboy1.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY2,"ww_skins/cowboy2.dff","ww_skins/cowboy2.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY3,"ww_skins/cowboy3.dff","ww_skins/cowboy3.txd");
    //AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY4,"ww_skins/cowboy4.dff","ww_skins/cowboy4.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY5,"ww_skins/cowboy5.dff","ww_skins/cowboy5.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY6,"ww_skins/cowboy6.dff","ww_skins/cowboy6.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY7,"ww_skins/cowboy7.dff","ww_skins/cowboy7.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY8,"ww_skins/cowboy8.dff","ww_skins/cowboy8.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY9,"ww_skins/cowboy9.dff","ww_skins/cowboy9.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY10,"ww_skins/cowboy10.dff","ww_skins/cowboy10.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY11,"ww_skins/cowboy11.dff","ww_skins/cowboy11.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY12,"ww_skins/cowboy12.dff","ww_skins/cowboy12.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY13,"ww_skins/cowboy13.dff","ww_skins/cowboy13.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY14,"ww_skins/cowboy14.dff","ww_skins/cowboy14.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY15,"ww_skins/cowboy15.dff","ww_skins/cowboy15.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY16,"ww_skins/cowboy16.dff","ww_skins/cowboy16.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY17,"ww_skins/cowboy17.dff","ww_skins/cowboy17.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,COWBOY18,"ww_skins/cowboy18.dff","ww_skins/cowboy18.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,MEXICAN4,"ww_skins/mexican4.dff","ww_skins/mexican4.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,MEXICAN5,"ww_skins/mexican4.dff","ww_skins/mexican4.txd");
    AddCharModel(CUSTOM_SKIN_MALE_BASEID,MEXICAN8,"ww_skins/mexican4.dff","ww_skins/mexican4.txd");
    AddCharModel(CUSTOM_SKIN_FEMALE_BASEID,FEMALE1,"ww_skins/female1.dff","ww_skins/female1.txd");
    AddCharModel(CUSTOM_SKIN_FEMALE_BASEID,FEMALE2,"ww_skins/female2.dff","ww_skins/female2.txd");
    AddCharModel(CUSTOM_SKIN_FEMALE_BASEID,FEMALE3,"ww_skins/female3.dff","ww_skins/female3.txd");
    AddCharModel(CUSTOM_SKIN_FEMALE_BASEID,FEMALE4,"ww_skins/female4.dff","ww_skins/female4.txd");
    AddCharModel(CUSTOM_SKIN_FEMALE_BASEID,FEMALE5,"ww_skins/female5.dff","ww_skins/female5.txd");
    AddCharModel(CUSTOM_SKIN_FEMALE_BASEID,FEMALE6,"ww_skins/female6.dff","ww_skins/female6.txd");
    AddCharModel(CUSTOM_SKIN_FEMALE_BASEID,FEMALE7,"ww_skins/female7.dff","ww_skins/female7.txd");
    AddCharModel(CUSTOM_SKIN_FEMALE_BASEID,FEMALE8,"ww_skins/female8.dff","ww_skins/female8.txd");
    AddCharModel(CUSTOM_SKIN_FEMALE_BASEID,FEMALE9,"ww_skins/female9.dff","ww_skins/female9.txd");
    return true;
}