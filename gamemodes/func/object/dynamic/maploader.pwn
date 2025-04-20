#define MAX_MPARSE_PREFIX (128+1)

enum MPARSE_PREFIX_DATA {
    MPARSE_PREFIX_NAME[MAX_MPARSE_PREFIX char],
    MPARSE_PREFIX_ID
} ;

new g_ObjectVariables[MAX_OBJECTS][MPARSE_PREFIX_DATA], g_ObjectsAdded ;

MapHandler () {

    new count ;

    print("\n[map] Starting map import\n") ;

    new dir:MapsDir = dir_open("./scriptfiles/maps"), fname[128], ftype;

    while ( dir_list ( MapsDir, fname, ftype ) ) {

        if(ftype == FM_DIR) continue;

        printf("\n[map] Started loading %s", fname ) ;

        LoadMap(fname);

        count ++ ;
    }

    dir_close(MapsDir);

    printf("\n[map] Finished map import: loaded %d maps\n", count ) ;
}

mparse_SetPrefixData ( prefix [], id ) {
    strtrim ( prefix, " " ) ;

    //if ( g_ObjectsAdded == MAX_OBJECTS ) return 0;

    strpack ( g_ObjectVariables [ g_ObjectsAdded ] [ MPARSE_PREFIX_NAME], prefix, MAX_MPARSE_PREFIX ) ;
    g_ObjectVariables [ g_ObjectsAdded ++ ] [ MPARSE_PREFIX_ID ] = id ;

    return 1;
}

mparse_GetPrefixData ( prefix [] ) {

    new prefix_packed[MAX_MPARSE_PREFIX] ;

    strtrim(prefix, " ");
    strpack(prefix_packed, prefix, MAX_MPARSE_PREFIX);

    for ( new index = g_ObjectsAdded - 1; index >= 0; index -- ) {

        if(strcmp(g_ObjectVariables[index][MPARSE_PREFIX_NAME], prefix_packed) == 0)
            return g_ObjectVariables[index][MPARSE_PREFIX_ID];
    }

    return INVALID_OBJECT_ID;
}

LoadMap(map[]) {
    new path[128], count, gatecount ;

    format(path, sizeof path, "maps/%s", map);
    if(!fexist(path)) return 0;

    new File:file_handle = fopen(path, io_read), buffer[300] ;
    if ( !file_handle ) return 0;

    while( fread ( file_handle, buffer ) ) {

        new start_index;


        if ( ( start_index = strfind ( buffer, "SetObjectMaterialText" ) ) != -1 ) {
            new prefix[MAX_MPARSE_PREFIX], text[128], materialindex, materialsize, fontface[128], fontsize, bold, fontcolor, backcolor, alignment ;

            if ( sscanf(buffer[start_index], "p<(>{s[128]}p<,>s[128]s[128]iis[128]iixxp<)>i", prefix, text, materialindex, materialsize, fontface, fontsize, bold, fontcolor, backcolor, alignment ) &&
                sscanf(buffer[start_index], "p<(>{s[128]}p<,>s[128]s[128]iis[128]iiiip<)>i", prefix, text, materialindex, materialsize, fontface, fontsize, bold, fontcolor, backcolor, alignment) ) {

                continue;
            }

            new objectid = mparse_GetPrefixData( prefix);
            if ( objectid == INVALID_OBJECT_ID ) continue;

            strtrim(text, "\"");
            strtrim(fontface, "\"");

            SetDynamicObjectMaterialText( objectid, materialindex,  text, materialsize, fontface, fontsize, bold, fontcolor, backcolor, alignment );
        }

        if ( ( start_index = strfind ( buffer, "SetObjectMaterialTextEx" ) ) != -1 ) {
            new prefix[MAX_MPARSE_PREFIX], text[128], materialindex, materialsize, fontface[128], fontsize, bold, fontcolor, backcolor, alignment ;

            if ( sscanf(buffer[start_index], "p<(>{s[128]}p<,>s[128]s[128]iis[128]iixxp<)>i", prefix, text, materialindex, materialsize, fontface, fontsize, bold, fontcolor, backcolor, alignment ) &&
                sscanf(buffer[start_index], "p<(>{s[128]}p<,>s[128]s[128]iis[128]iiiip<)>i", prefix, text, materialindex, materialsize, fontface, fontsize, bold, fontcolor, backcolor, alignment) ) {

                continue;
            }

            new objectid = mparse_GetPrefixData( prefix);
            if ( objectid == INVALID_OBJECT_ID ) continue;

            strtrim(text, "\"");
            strtrim(fontface, "\"");

            SetDynamicObjectMaterialText( objectid, materialindex,  text, materialsize, fontface, fontsize, bold, fontcolor, backcolor, alignment );
        }
        
        ///////////////////////////////////////////////////////// //////////////////////////////////////////////////

        else if((start_index = strfind(buffer, "SetObjectMaterial")) != -1) {

            new prefix[MAX_MPARSE_PREFIX], materialindex, modelid, txd[128], texture[128], color ;

            if( sscanf(buffer[start_index], "p<(>{s[128]}p<,>s[128]iis[128]s[128]p<)>x", prefix, materialindex, modelid, txd, texture, color) &&
                sscanf(buffer[start_index], "p<(>{s[128]}p<,>s[128]iis[128]s[128]p<)>i", prefix, materialindex, modelid, txd, texture, color) ){

                continue;
            }

            new objectid = mparse_GetPrefixData ( prefix ) ;
            if(objectid == INVALID_OBJECT_ID) continue;

            strtrim(txd, "\"");
            strtrim(texture, "\"");

            SetDynamicObjectMaterial( objectid, materialindex, modelid, txd, texture, color);
        }

        ///////////////////////////////////////////////////////// //////////////////////////////////////////////////

        else if((start_index = strfind(buffer, "CreateObject")) != -1 ) {

            new bool:prefix_found, prefix[MAX_MPARSE_PREFIX], modelid, Float:x, Float:y, Float:z, Float:rx,  Float:ry, Float:rz, Float:stream_distance ;

            if(start_index > 0 && !sscanf(buffer, "p<=>s[128]p<(>{s[128]}p<,>ifffffp<)>f", prefix, modelid, x, y, z, rx, ry, rz)) prefix_found = true, stream_distance = 1000.0;
            else if(start_index > 0 && !sscanf(buffer, "p<=>s[128]p<(>{s[128]}p<,>iffffffp<)>f", prefix, modelid, x, y, z, rx, ry, rz, stream_distance)) prefix_found = true;
            else if(!sscanf(buffer[start_index], "p<(>{s[128]}p<,>ifffffp<)>f", modelid, x, y, z, rx, ry, rz)) prefix_found = false, stream_distance = 1000.0;
            else if(!sscanf(buffer[start_index], "p<(>{s[128]}p<,>iffffffp<)>f", modelid, x, y, z, rx, ry, rz, stream_distance)) prefix_found = false;
            else continue;

            new objectid = CA_CreateDynamicObject_SC(modelid, x, y, z, rx, ry, rz);

            stream_distance = 850 ;

            Streamer_SetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_STREAM_DISTANCE, stream_distance);
            Streamer_SetFloatData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_DRAW_DISTANCE, stream_distance);

            if ( IsValidDynamicObject ( objectid ) ) {
                 count ++ ;
            }

            if(prefix_found && objectid != INVALID_OBJECT_ID) {

                mparse_SetPrefixData ( prefix, objectid ) ;
            }
        }

        ///////////////////////////////////////////////////////// //////////////////////////////////////////////////


        else if((start_index = strfind(buffer, "SetDynamicObjectMaterialText")) != -1)
        {
            new
                prefix[MAX_MPARSE_PREFIX],
                text[50],
                materialindex,
                materialsize,
                fontface[50],
                fontsize,
                bold,
                fontcolor,
                backcolor,
                alignment
            ;

            if(
                sscanf(buffer[start_index], "p<(>{s[22]}p<,>s[31]is[50]is[50]iixxp<)>i", prefix, materialindex, text, materialsize, fontface, fontsize, bold, fontcolor, backcolor, alignment) &&
                sscanf(buffer[start_index], "p<(>{s[22]}p<,>s[31]is[50]is[50]iiiip<)>i", prefix, materialindex, text, materialsize, fontface, fontsize, bold, fontcolor, backcolor, alignment)
            ){
                continue;
            }

            new objectid = mparse_GetPrefixData(prefix);
            if(objectid == INVALID_OBJECT_ID)
                continue;

            strtrim(text, "\"");
            strtrim(fontface, "\"");

            SetDynamicObjectMaterialText(
                objectid,
                materialindex,
                text,
                materialsize,
                fontface,
                fontsize,
                bold,
                fontcolor,
                backcolor,
                alignment
            );
        }
        else if((start_index = strfind(buffer, "SetDynamicObjectMaterial")) != -1)
        {
            new
                prefix[MAX_MPARSE_PREFIX],
                materialindex,
                modelid,
                txd[50],
                texture[50],
                color
            ;

            if(
                sscanf(buffer[start_index], "p<(>{s[18]}p<,>s[31]iis[50]s[50]p<)>x", prefix, materialindex, modelid, txd, texture, color) &&
                sscanf(buffer[start_index], "p<(>{s[18]}p<,>s[31]iis[50]s[50]p<)>i", prefix, materialindex, modelid, txd, texture, color)
            ){
                continue;
            }

            new objectid = mparse_GetPrefixData(prefix);
            if(objectid == INVALID_OBJECT_ID)
                continue;

            strtrim(txd, "\"");
            strtrim(texture, "\"");

            SetDynamicObjectMaterial(
                objectid,
                materialindex,
                modelid,
                txd,
                texture,
                color
            );
        }

        else if((start_index = strfind(buffer, "CreateDynamicObject")) != -1)
        {
            new
                bool:prefix_found,
                prefix[MAX_MPARSE_PREFIX],
                modelid,
                Float:x,
                Float:y,
                Float:z,
                Float:rx,
                Float:ry,
                Float:rz,
                Float:stream_distance
            ;

            if(start_index > 0 && !sscanf(buffer, "p<=>s[31]p<(>{s[14]}p<,>ifffffp<)>f", prefix, modelid, x, y, z, rx, ry, rz))
                prefix_found = true, stream_distance = 0.0;
            else if(start_index > 0 && !sscanf(buffer, "p<=>s[31]p<(>{s[14]}p<,>iffffffp<)>f", prefix, modelid, x, y, z, rx, ry, rz, stream_distance))
                prefix_found = true;
            else if(!sscanf(buffer[start_index], "p<(>{s[13]}p<,>ifffffp<)>f", modelid, x, y, z, rx, ry, rz))
                prefix_found = false, stream_distance = 0.0;
            else if(!sscanf(buffer[start_index], "p<(>{s[13]}p<,>iffffffp<)>f", modelid, x, y, z, rx, ry, rz, stream_distance))
                prefix_found = false;
            else
                continue;

            new objectid = CreateDynamicObject(modelid, x, y, z, rx, ry, rz);
            
            if(prefix_found && objectid != INVALID_OBJECT_ID)
                mparse_SetPrefixData(prefix, objectid);
        }


        ///////////////////////////////////////////////////////// //////////////////////////////////////////////////

        else if ( ( start_index = strfind ( buffer, "CreateGate" ) ) != -1 ) {

            new g_model, g_type, g_owner, g_int, g_vw, g_move, Float: g_speed, 
                Float: g_shut_x, Float: g_shut_y, Float: g_shut_z, Float: g_shut_rx, Float: g_shut_ry, Float: g_shut_rz,
                Float: g_open_x, Float: g_open_y, Float: g_open_z, Float: g_open_rx, Float: g_open_ry, Float: g_open_rz
            ;


            new bool:prefix_found, prefix[MAX_MPARSE_PREFIX] ;

            if(start_index > 0 && !sscanf(buffer, "p<=>s[128]p<(>{s[128]}p<,>iiiiifffffffffffffp<)>i", prefix, g_model, g_type, g_owner, g_int, g_vw, g_speed, g_shut_x, g_shut_y, g_shut_z, g_shut_rx, g_shut_ry, g_shut_rz,  g_open_x, g_open_y, g_open_z, g_open_rx, g_open_ry, g_open_rz, g_move ) ) {
                prefix_found = true;
            }

            else if(!sscanf(buffer[start_index], "p<(>{s[128]}p<,>iiiiifffffffffffffp<)>i", g_model, g_type, g_owner, g_int, g_vw, g_speed, g_shut_x, g_shut_y, g_shut_z, g_shut_rx, g_shut_ry, g_shut_rz,  g_open_x, g_open_y, g_open_z, g_open_rx, g_open_ry, g_open_rz, g_move ) ) {
                prefix_found = false;
            }

            else continue;

            ++ gatecount ;

            new objectid = CreateGate ( g_model, g_type, g_owner, g_int, g_vw, g_speed,
                g_shut_x, g_shut_y, g_shut_z, g_shut_rx, g_shut_ry, g_shut_rz, g_open_x, g_open_y, g_open_z, g_open_rx, g_open_ry, g_open_rz, g_move ) ;

            if(prefix_found && objectid != INVALID_OBJECT_ID) {

                mparse_SetPrefixData ( prefix, objectid ) ;
            }
        }
    }

    printf("[map] Loaded map \"%s\". %d objects and %d gates", map, count, gatecount ) ;

    g_ObjectsAdded = 0;
    count = 0 ;

    fclose(file_handle);

    return 1;
}
