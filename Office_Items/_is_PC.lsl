string media_URL =  "http://www.google.com";
string last_url = "";

integer dlg_channel = 0;
integer listen_handle = 0;
string check_1_str = "🗸 ";
string current_select = "OFF";

integer link_num = 0;
integer face_num = 2;

key off_tex = "f718d636-a8db-479d-8f5b-ab6d8effd9e5";
key ready_tex = "";
//key ready_tex = "37808013-b0c4-4a89-8966-f4bab97510da";

// 文字列置換
string strReplace(string str, string search, string replace)
{
    return llDumpList2String(llParseStringKeepNulls(str, [search], []), replace);
}

integer genCh()
{
    integer gen;
    key id = llGetKey();
    string str = llGetSubString((string)id,0,3);
    gen = -1-(integer)("0x"+str);
    if(gen < 0 ) gen *= -1;
    return gen;
}

open_setting_dlg(key user)
{
    if(listen_handle != 0)
    {
        llListenRemove(listen_handle);
        listen_handle = 0;
    }
    listen_handle = llListen(dlg_channel, "", NULL_KEY, "");
    
    string msg = "\nMonitor Settings";
    list btns = [/*"ON",*/"Internet","OFF","[URL Reset]","[CLOSE]"];
    
    integer index = llListFindList(btns, [current_select]);
    btns = llListReplaceList(btns, [check_1_str + llList2String(btns,index)], index,index);
    
    llDialog( user, msg, btns, dlg_channel );
    
    btns = [];    
}

default
{
    state_entry()
    {
        dlg_channel = genCh();
        listen_handle = llListen(dlg_channel, "", NULL_KEY, "");
        last_url = media_URL;
        
        // Monitor OFF 設定
        current_select = "OFF";
        llClearPrimMedia(face_num);
        llSetLinkPrimitiveParams( link_num,
            [
                PRIM_TEXTURE, face_num, off_tex, <1,1,0>, ZERO_VECTOR, 0,
                PRIM_FULLBRIGHT, face_num, FALSE
            ]);
    }

    touch_start(integer total_number)
    {
        integer touch_face = llDetectedTouchFace(0);
        if(touch_face == face_num)
        {
            open_setting_dlg(llDetectedKey(0));
            
                llSetLinkPrimitiveParams( 0,
                [
                    PRIM_TEXTURE, face_num, ready_tex, <1,1,0>, ZERO_VECTOR, 0,
                    PRIM_FULLBRIGHT, face_num, TRUE
                ]);

            integer ret = 
                llSetPrimMediaParams( face_num, 
                [
                    PRIM_MEDIA_CONTROLS, PRIM_MEDIA_CONTROLS_MINI ,
                    PRIM_MEDIA_CURRENT_URL, last_url,
                    PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_OWNER,
                    PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_OWNER,
                    PRIM_MEDIA_AUTO_SCALE, TRUE,
                    PRIM_MEDIA_AUTO_PLAY, TRUE//,
                    //PRIM_MEDIA_FIRST_CLICK_INTERACT, FALSE
                ]);
        }
        else
        {
            open_setting_dlg(llDetectedKey(0));
        }
    }
    
    listen( integer channel, string name, key user, string message )
    {
        message = strReplace(message, check_1_str, "");

        if(message == "[CLOSE]")
        {
            return;
        }
        else if(message == "[URL Reset]")
        {
            last_url = media_URL;
            message = "OFF";
        }
        
        current_select = message;

        if(message == "OFF")
        {
            if(last_url != media_URL)
            {
                last_url = 
                    llList2String(llGetPrimMediaParams(face_num, [PRIM_MEDIA_CURRENT_URL]),0);
            }
            llClearPrimMedia(face_num);
            
            llSetLinkPrimitiveParams( link_num,
                [
                    PRIM_TEXTURE, face_num, off_tex, <-1,1,0>, ZERO_VECTOR, 180*DEG_TO_RAD,
                    PRIM_FULLBRIGHT, face_num, FALSE
                ]);

        }
        else if(message == "Internet")
        {
            llSetLinkPrimitiveParams( link_num,
                [
                    PRIM_TEXTURE, face_num, ready_tex, <-1,1,0>, ZERO_VECTOR, 180*DEG_TO_RAD,
                    PRIM_COLOR, face_num, <1,1,1>, 1.0,
                    PRIM_FULLBRIGHT, face_num, TRUE
                ]);

            integer ret = 
                llSetPrimMediaParams( face_num, 
                [
                    PRIM_MEDIA_CONTROLS, PRIM_MEDIA_CONTROLS_MINI ,
                    PRIM_MEDIA_CURRENT_URL, last_url,
                    PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_OWNER,
                    PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_OWNER,
                    PRIM_MEDIA_AUTO_SCALE, TRUE,
                    PRIM_MEDIA_AUTO_PLAY, TRUE//,
                    //PRIM_MEDIA_FIRST_CLICK_INTERACT, FALSE
                ]);
        }
        
        //open_setting_dlg(user);
    }
}