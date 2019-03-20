/*
    --- [BMS] MESH Body HUD Scripts ---
    
                                Ishikawa Sou March 20 / 2019
                                
*/

string product_id = "BMS_MESH_BODY";
integer channel = 0;
integer listen_handle;
list body_parts_list;
list body_info_list;

//string url_twitter = "https://twitter.com/Blossom_Adamski";
//string url_flicker = "https://www.flickr.com/photos/158701349@N08/";
//string url_market = "https://marketplace.secondlife.com/ja-JP/stores/180063";

string touch_sound = "5ad44c3e-1404-cf17-bb3d-cbbc36465762";
string open_sound = "5ad44c3e-1404-cf17-bb3d-cbbc36465762";
string close_sound = "5ad44c3e-1404-cf17-bb3d-cbbc36465762";

float sound_valume = 1.0;//0.3;
float sound_touch_valume = 1.0;

vector touch_start_pos;
vector touch_offset_pos;

vector root_pos;
vector org_size;
vector move_size;

integer my_link_num = 1;
string title_name;

integer win_open_flag = FALSE;
integer move_flag = FALSE;

list prim_list = [];
vector win_org_size;// = <0.01, 0.8, 0.4>;
vector win_min_size = <0.01,0.01,0.01>;

list btn_control_db = [];
integer btn_face = 2;
float btn_tex_offset = 0;
string btn_tex = "";//"e2d0d45b-8aca-5d31-7e06-e00ae9aadb7b";

list move_cmd_list = [];

set_moveLocal_cmd(integer linknumber, vector position, vector size )
{
    move_cmd_list += [linknumber, size , position];
}
do_moveLocal_cmd()
{
    integer i = 0;
    list cmd = [];
    integer linknumber = llList2Integer(move_cmd_list, 0);
    
    vector size = llList2Vector(move_cmd_list, 1);
    vector pos = llList2Vector(move_cmd_list, 2);
    cmd += [PRIM_SIZE, size , PRIM_POS_LOCAL , pos];
    
    for(i = 3 ; i < llGetListLength(move_cmd_list) ; i+=3)
    {
        cmd += [PRIM_LINK_TARGET];
        linknumber = llList2Integer(move_cmd_list, 0);
        size = llList2Vector(move_cmd_list, i+1);
        pos = llList2Vector(move_cmd_list, i+2);
        cmd += [linknumber, PRIM_SIZE, size , PRIM_POS_LOCAL , pos];
    }
    
    linknumber = llList2Integer(move_cmd_list, 0);
    llSetLinkPrimitiveParamsFast(linknumber, cmd);
    
    cmd = [];
    move_cmd_list = [];
}


// Prim List 作成
createIndex()
{
    integer i;
    prim_list = [title_name];    // ルート ( 1 : 起算 )
    for(i = 1; i <= llGetNumberOfPrims() ; i++)
    {
        string prim_name = llGetLinkName(i);
        prim_list += [prim_name];
        
        if(llGetSubString(prim_name, 0, 0) == "_")
        {
            btn_control_db += [prim_name]; // ボタン名
            
            string btn_description = llList2String(llGetLinkPrimitiveParams(i, [ PRIM_DESC ]),0);
            
            
            if(btn_description == "")
            {
                // Original Size
                vector size = llList2Vector(llGetLinkPrimitiveParams(i,[PRIM_SIZE]),0);
                btn_control_db += [size];
                // Original Position
                vector pos = llList2Vector(llGetLinkPrimitiveParams(i,[PRIM_POS_LOCAL]),0);
                btn_control_db += [pos];
                
                btn_description = llList2CSV([size.x, size.y, size.z, pos.x, pos.y, pos.z]);
                        
                llSetLinkPrimitiveParams(i, [PRIM_DESC, btn_description]);
            }
            else
            {
                list dat = llCSV2List(btn_description);
                vector size = <llList2Float(dat,0), llList2Float(dat,1), llList2Float(dat,2)>;
                vector pos = <llList2Float(dat,3), llList2Float(dat,4), llList2Float(dat,5)>;
                btn_control_db += [size];
                btn_control_db += [pos];
            }
            
            // ボタン表示オフセット取得
            vector offset = llList2Vector(llGetLinkPrimitiveParams(i, [ PRIM_TEXTURE, btn_face ]),2);
            btn_tex_offset = offset.x;
        }
    }
}


// Prim Nmae から インデックス を返す
integer getIndex(string prim_name)
{
    return llListFindList(prim_list, [prim_name]);   
}

//win_init()
//{
//    llSetLinkPrimitiveParamsFast(getIndex("win_1"),[PRIM_SIZE , win_min_size]);
//}

integer conrol_win(string win_name, integer flag)
{
    vector angles_radians;
    rotation rot;

    if(flag == TRUE) // Open
    {
        llSetLinkPrimitiveParamsFast(getIndex(win_name),
            [
                PRIM_SIZE , win_org_size
            ]);
        llSetLocalRot(llGetLocalRot()*llEuler2Rot(<0,0,-90>*DEG_TO_RAD));
        // ボタン移動
        integer i;
        for( i = 0 ; i < llGetListLength(btn_control_db) ; i+=3)
        {
            
            string btn_name = llList2String(btn_control_db, i);
            vector size = llList2Vector(btn_control_db, i+1);
            vector pos = llList2Vector(btn_control_db, i+2);
            
            set_moveLocal_cmd(getIndex(btn_name), pos, size);
            do_moveLocal_cmd();
        }
    }
    else // Close
    {
        llSetLocalRot(llGetLocalRot()*llEuler2Rot(<0,0,90>*DEG_TO_RAD));
        
//        llSetLinkPrimitiveParamsFast(getIndex(win_name),[PRIM_SIZE , win_min_size]);
        llSetLinkPrimitiveParamsFast(getIndex(win_name),
            [
                PRIM_SIZE , win_min_size
            ]);
        // ボタン移動
        integer i;
        for( i = 0 ; i < llGetListLength(btn_control_db) ; i+=3)
        {
            string btn_name = llList2String(btn_control_db, i);
            
            set_moveLocal_cmd(getIndex(btn_name), root_pos, win_min_size);
            do_moveLocal_cmd();

        }
        
        return FALSE;
    }
    
    return TRUE;
}

control_options_btn_check(string btn_name)
{
    // 1, 2, 3, 4, 5, 6
    llSetLinkPrimitiveParams(getIndex("_1"),
        [
            PRIM_TEXTURE, btn_face, btn_tex, <0.5,1,0>, <-btn_tex_offset,0,0>, 0.0,
            PRIM_LINK_TARGET, getIndex("_2"),
            PRIM_TEXTURE, btn_face, btn_tex, <0.5,1,0>, <-btn_tex_offset,0,0>, 0.0,
            PRIM_LINK_TARGET, getIndex("_3"),
            PRIM_TEXTURE, btn_face, btn_tex, <0.5,1,0>, <-btn_tex_offset,0,0>, 0.0,
            PRIM_LINK_TARGET, getIndex("_4"),
            PRIM_TEXTURE, btn_face, btn_tex, <0.5,1,0>, <-btn_tex_offset,0,0>, 0.0,
            PRIM_LINK_TARGET, getIndex("_5"),
            PRIM_TEXTURE, btn_face, btn_tex, <0.5,1,0>, <-btn_tex_offset,0,0>, 0.0,
            PRIM_LINK_TARGET, getIndex("_6"),
            PRIM_TEXTURE, btn_face, btn_tex, <0.5,1,0>, <-btn_tex_offset,0,0>, 0.0
        ]);
        
    llSetLinkPrimitiveParams(getIndex(btn_name),
        [PRIM_TEXTURE, btn_face, btn_tex, <0.5,1,0>, <btn_tex_offset,0,0>, DEG_TO_RAD*180.0]);
}

integer genCh()
{
    integer gen;
    key id = llGetOwner();
    string str = llGetSubString((string)id,0,3);
    gen = -1-(integer)("0x"+str) + (integer)product_id;
    if(gen<0) gen*=-1;
    return gen;
}

// 文字列置換
string strReplace(string str, string search, string replace)
{
    return llDumpList2String(llParseStringKeepNulls(str, [search], []), replace);
}

update_btn_enable()
{
    integer i = 2;
    list cmd;
    integer start_index;
    integer face = 4;
    vector color = <1.0,0.8,0.8>;
    for(i = 2 ; i < llGetListLength(body_parts_list) ; i++)
    {
        string parts_name = "_" + llList2String(body_parts_list,i);
        integer btn_index = getIndex(parts_name);
        integer trans = llList2Integer(body_info_list,i);

        if(i == 2)
        {
            start_index = btn_index;
            cmd = [ PRIM_COLOR, face, color, trans ];
        }
        else
        {
            cmd += [ PRIM_LINK_TARGET,  btn_index];
            cmd += [ PRIM_COLOR, face, color, trans ];
        }
    }
    
    llSetLinkPrimitiveParams(start_index, cmd);
}

default
{
    state_entry()
    {
        title_name = llGetObjectName();
        
        channel = genCh();
        listen_handle = llListen(channel+1, "", NULL_KEY, ""); // Body からの受信
        
        root_pos = llList2Vector(llGetLinkPrimitiveParams(0,[PRIM_POS_LOCAL]),0);
        root_pos.x += 0.1;

        org_size = llGetScale();
        move_size = <org_size.z,2,2>;
        
        createIndex();
        
        string win_description = llList2String(llGetLinkPrimitiveParams(getIndex("win_1"), [PRIM_DESC]),0);
        if(win_description == "")
        {
            win_org_size = llList2Vector(llGetLinkPrimitiveParams(getIndex("win_1"), [PRIM_SIZE]),0);
            
            llSetLinkPrimitiveParams(getIndex("win_1"), [PRIM_DESC, (string)win_org_size]);
        }
        else
        {
            win_org_size = (vector)win_description;
        }
        
        llSetLocalRot(llEuler2Rot(<0,0,0>*DEG_TO_RAD));
        win_open_flag = TRUE;
        
        float memory = 0.1*(float)llRound(10 * llGetFreeMemory() / 1024);
        llOwnerSay((string)memory);
    }

    attach(key id)
    {
        if(id)
        {
            channel = genCh();
        }
    }

    touch_start(integer total_number)
    {
        string btn_name = llGetLinkName(llDetectedLinkNumber(0));    

        integer btn_flag = FALSE;
        integer open_win_ret = FALSE;
        
        
        if(btn_name == title_name && move_flag == FALSE)
        {
            move_flag = TRUE;
            llSetLinkPrimitiveParamsFast(my_link_num,[PRIM_SIZE , move_size]);
            touch_start_pos = llDetectedTouchPos(0);
        }
        
        // Button Action
        if(btn_name == "btn_min_mix")
        {
            btn_flag = TRUE;
            //open_win_ret = open_win("win_1");
            if(win_open_flag == FALSE)
            {
                llPlaySound(open_sound, sound_valume);
                win_open_flag = TRUE;
                conrol_win("win_1", TRUE);
            }
            else
            {
                llPlaySound(close_sound, sound_valume);
                win_open_flag = FALSE;
                conrol_win("win_1", FALSE);
            }
        }
        else if(btn_name == "_resize")
        {
            llWhisper(channel, "resize");
        }        
        else
        {
            // ボタン押下
            llPlaySound(touch_sound, sound_touch_valume);
            
            integer touch_link = llDetectedLinkNumber(0);
            string touch_obj_name = llList2String(prim_list, touch_link);
            
            if(llGetSubString(touch_obj_name, 0, 0) == "_")
            {
                string send_str = llDeleteSubString(touch_obj_name,0,0);
                llWhisper(channel, send_str);
            }
        }
    }
    
    touch(integer total_number)
    {
        if(move_flag == TRUE)
        {
            vector move_pos = llDetectedTouchPos(0);
            if(move_pos != ZERO_VECTOR)
            {
                touch_offset_pos = touch_start_pos - move_pos;
                
                vector pos = llGetLocalPos() - touch_offset_pos;
                llSetLinkPrimitiveParamsFast(1, [PRIM_POSITION, pos]);
    
                touch_start_pos = move_pos;
            }
        }
    }
    
    touch_end(integer total_number)
    {
        if(move_flag == TRUE)
        {
            llSetLinkPrimitiveParamsFast(my_link_num,[PRIM_SIZE , org_size]);
            
            vector move_pos = llDetectedTouchPos(0);
            touch_offset_pos = touch_start_pos - move_pos;
            vector pos = llGetLocalPos() - touch_offset_pos;
            llSetPos(pos);

            move_flag = FALSE;
        }
        
    }
    
    listen( integer channel, string name, key user, string message )
    {
        if(llGetOwnerKey(user) != llGetOwner()) return;
        
        list cmd = llCSV2List(message);
        if(llList2String(cmd,0) == "parts")
        {
            body_parts_list = cmd;
        }
        else if(llList2String(cmd,0) == "info")
        {
            body_info_list = cmd;
            update_btn_enable();
        }
    }
}
