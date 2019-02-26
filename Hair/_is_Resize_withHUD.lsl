/*---
    Resize & Stretch Script (HUD 対応)
  
        July 14 . 2018  Ishikawa Sou
---*/
string product_id = "000";
integer hud_ch;
integer hud_handle;

string store_name = "";
string dialog_title = "\n\nResize & Stretch\n\n                         Produced by [BMS]";

integer dlg_ch;
integer dlg_color_ch;

integer handle;
integer prim_num;
list link_data = [];
string last_saved;
list cmd;
list cmd_minus = ["-1%", "-5%", "-10%"];
list cmd_plus = ["+1%", "+5%", "+10%"];
list cmd_deactive = ["-", "-", "-"];
list gain = [-0.10, -0.05, -0.01, 0.01, 0.05, 0.10];
list advanced = ["[Delete]", "-- XYZ --", "[CLOSE]", "Restore", "Pose ON", "FullBright ON"];
list stretch_type_list = ["-- XYZ --", "-- X --", "-- Y --", "-- Z --"];
integer stretch_index = 0;
string pose_on_str = "Pose ON";
string pose_off_str = "Pose OFF";
string fullbright_on_str = "FullBright ON";
string fullbright_off_str = "FullBright OFF";
string anim = "turn_180";
string language;

string color_target = "";


change_stretch_type()
{
    integer type_max = llGetListLength(stretch_type_list);
    stretch_index++;
    if(stretch_index == type_max)
    {
        stretch_index = 0;
    }
    
    advanced = llListReplaceList( advanced, 
                    llList2List(stretch_type_list, stretch_index, stretch_index), 1, 1 );
}

string get_stretch_type()
{
    return llList2String(advanced, 1);
}

integer genCh()
{
    integer gen;
    key id = llGetKey();
    string str = llGetSubString((string)id,0,3);
    gen = -1-(integer)("0x"+str);
    
    return gen;
}

integer genCh_fromHUD()
{
    integer gen;
    key id = llGetOwner();
    string str = llGetSubString((string)id,0,3);
    gen = -1-(integer)("0x"+str) + (integer)product_id;
    return gen;
}

limit_check()
{
    integer n;
    integer min;
    integer max;
    if(prim_num == 1)
    {
        vector root_size = llList2Vector(llGetLinkPrimitiveParams(0,[PRIM_SIZE]),0);
        if((0.90 * root_size.x < 0.01) || (0.90 * root_size.y < 0.01) || (0.90 * root_size.z < 0.01))
        {
            min = TRUE;
        }
        if((1.10 * root_size.x > 10.0) ||(1.10 * root_size.y > 10.0) ||(1.10 * root_size.z > 10.0))
        {
            max = TRUE;
        }
    }
    else
    {
        for(n = 1;n<=prim_num;n++)
        {
            vector link_size = llList2Vector(llGetLinkPrimitiveParams(n,[PRIM_SIZE]),0);
            if((0.90 * link_size.x < 0.01) || (0.90 * link_size.y < 0.01) || (0.90 * link_size.z < 0.01))
            {
                min = TRUE;
            }
            if((1.10 * link_size.x > 10.0) ||(1.10 * link_size.y > 10.0) ||(1.10 * link_size.z > 10.0))
            {
                max = TRUE;
            }
        }
    }
    
    if(min)
    {
        cmd = cmd_deactive;
    }
    else
    {
        cmd = cmd_minus;
    }
    if(max)
    {
        cmd += cmd_deactive;
    }
    else
    {
        cmd += cmd_plus;
    }
}

vector getResizeRetio()
{
    vector org_vec;
    vector now_vec;
    // original size
    if(prim_num == 1)
    {
        org_vec = (vector)llList2String(link_data,0);
        now_vec = (vector)llList2String(llGetLinkPrimitiveParams(0,[ PRIM_SIZE ]),0);
    }
    else
    {
        // Link Num 2 のサイズを取り出す
        org_vec = (vector)llList2String(link_data,0);
        now_vec = (vector)llList2String(llGetLinkPrimitiveParams(1,[ PRIM_SIZE ]),0);
    }

    vector ret_vec;
    ret_vec.x = now_vec.x / org_vec.x;
    ret_vec.y = now_vec.y / org_vec.y;
    ret_vec.z = now_vec.z / org_vec.z;

    return ret_vec;
}

dlg_menu()
{
    limit_check();
    
    string disp_msg = dialog_title + "\n\n";
    
    vector ratio = getResizeRetio();
    integer ratio_x = (integer)(ratio.x * 100.0);
    integer ratio_y = (integer)(ratio.y * 100.0);
    integer ratio_z = (integer)(ratio.z * 100.0);
    
    disp_msg += "    Resize ratio\n\n";
    disp_msg += "        X : " + (string)ratio_x + "%\n";
    disp_msg += "        Y : " + (string)ratio_y + "%\n";
    disp_msg += "        Z : " + (string)ratio_z + "%\n";
    
    llDialog(llGetOwner(),disp_msg, advanced + cmd, dlg_ch);
}

dlg_script_delete()
{
    string msg;
    if(language == "ja")
    {
        msg = "スクリプトを削除しますがよろしいですか？";
    }
    else
    {
        msg = "Are you sure you want to delete this script ?";
    }
    llDialog(llGetOwner(),"\n\n"+msg+"\n",["OK","Cancel"],dlg_ch);
}

save_all_param()
{
    link_data = [];
    vector root = llGetRootPosition();
    rotation rot = llGetRootRotation();
    integer i;
    
    if(prim_num == 1)
    {
        vector vec = llGetScale();
        vector pos = llGetLocalPos();
        link_data = [vec,pos];
    }
    else
    {
        for(i = 1;i<=prim_num;i++)
        {
            list get = llGetLinkPrimitiveParams(i,[PRIM_SIZE,PRIM_POSITION]);
            vector vec = llList2Vector(get,0);
            vector pos = (llList2Vector(get,1)-root) / rot;
            link_data = link_data + [vec,pos];
        }
    }
    string stamp = llGetTimestamp();
    last_saved = llGetSubString(stamp,0,9)+" "+llGetSubString(stamp,11,15)+" (UTC)";
}

integer prim_count()
{
    integer pc = llGetObjectPrimCount( llGetKey() );
    if( llGetAttached() )
    {
        pc = llGetNumberOfPrims();
    }
    return pc;
}

// 文字列置換
string strReplace(string str, string search, string replace)
{
    return llDumpList2String(llParseStringKeepNulls(str, [search], []), replace);
}

default
{
    state_entry()
    {
        language = llGetAgentLanguage(llGetOwner());
        dlg_ch = genCh();
        handle = llListen(dlg_ch, "", NULL_KEY, "");
        hud_ch = genCh_fromHUD();
        hud_handle = llListen(hud_ch, "", NULL_KEY, "");
        
        llSetTouchText("resize");
        prim_num = prim_count();
        save_all_param();
        
        if(store_name == "")
        {
            dialog_title = strReplace(dialog_title, "[storename]", llGetObjectDesc());
        }
        else
        {
            dialog_title = strReplace(dialog_title, "[storename]", store_name);
        }
    }

    listen(integer channel, string name, key id, string message)
    {
        if(llGetOwner() != llGetOwnerKey(id)) return;
        
        if(channel == hud_ch && message == "resize")
        {
            dlg_menu();
        }
        
        integer index0 = llListFindList(cmd_minus+cmd_plus,[message]);
        integer index1 = llListFindList(advanced,[message]);

        if(index0 == 0) { index0 = 2; }
        else if(index0 == 2) { index0 = 0; }

        string stretch_type = get_stretch_type();

        if(index0 != -1)
        {
            if(prim_num <= 1)
            {
                float x = llList2Float(gain,index0);
                vector vec = llGetScale();
                vector revec = vec;
                if(stretch_type == "-- X --")
                {
                    revec.x = vec.x * (1+x);
                }
                else if(stretch_type == "-- Y --")
                {
                    revec.y = vec.y * (1+x);
                }
                else if(stretch_type == "-- Z --")
                {
                    revec.z = vec.z * (1+x);
                }
                else if(stretch_type == "-- XYZ --")
                {
                    revec.x = vec.x * (1+x);
                    revec.y = vec.y * (1+x);
                    revec.z = vec.z * (1+x);
                }
                
                llSetScale(revec);
                
                dlg_menu();
                return;
            }
            
            integer i;
            vector root = llGetRootPosition();
            for(i = 1; i<=prim_num; i++)
            {
                list get = llGetLinkPrimitiveParams(i,[PRIM_SIZE,PRIM_POSITION]);
                vector vec = llList2Vector(get,0);
                vector pos = llList2Vector(get,1)-root;
                vector revec = vec;
                vector repos = pos;
                float x = llList2Float(gain,index0);

                if(stretch_type == "-- X --")
                {
                    revec.x = vec.x * (1+x);
                }
                else if(stretch_type == "-- Y --")
                {
                    revec.y = vec.y * (1+x);
                }
                else if(stretch_type == "-- Z --")
                {
                    revec.z = vec.z * (1+x);
                }
                else if(stretch_type == "-- XYZ --")
                {
                    revec.x = vec.x * (1+x);
                    revec.y = vec.y * (1+x);
                    revec.z = vec.z * (1+x);
                    repos.x = pos.x * (1+x);
                    repos.y = pos.y * (1+x);
                    repos.z = pos.z * (1+x);
                }
                
                if(i == 1)
                {
                    llSetLinkPrimitiveParams(i,[
                        PRIM_SIZE, revec
                            ]);
                }
                else
                {
                    llSetLinkPrimitiveParams(i,[
                        PRIM_SIZE, revec,
                        PRIM_POSITION, repos/llGetRootRotation()
                            ]);
                }
            }
            dlg_menu();
        }

        if(index1 != -1)
        {
            // ["[Delete]", "Color", "[CLOSE]", "Restore", "Pose ON", "Full Bright ON"];
            if(index1 == 3)
            {
                if(prim_num == 1)
                {
                    if(llGetAttached() != 0)
                    {
                        vector vec = llList2Vector(link_data,0);
                        llSetScale(vec);
                        vector pos = llList2Vector(link_data,1);
                        llSetPos(pos);
                    }
                    else
                    {
                        llOwnerSay("リンクプリムがない場合、Restore は装着時にしか行えません");
                    }
                }
                else
                {
                    integer i;
                    integer j;
                    rotation rot = llGetRootRotation();
                    list cmd_list = [];              
                    
                    cmd_list =
                        [
                            PRIM_SIZE,llList2Vector(link_data,0)
                            //PRIM_POSITION,llList2Vector(link_data,1)
                        ];
                    
                    for(i = 1 ; i<=prim_num; i++)
                    {
                        cmd_list +=
                            [
                                PRIM_LINK_TARGET, i+1,
                                PRIM_SIZE,llList2Vector(link_data,i*2),
                                PRIM_POSITION,llList2Vector(link_data,i*2+1)
                            ];
                    }
                        
                    llSetLinkPrimitiveParams(1,cmd_list);

                }
                dlg_menu();
            }
            else if(index1 == 4)
            {
                string str = llList2String(advanced, index1);
                if(str == pose_on_str)
                {
                    advanced = llListReplaceList(advanced, [pose_off_str], index1, index1);
                    llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
                }
                else
                {
                    advanced = llListReplaceList(advanced, [pose_on_str], index1, index1);
                    llStopAnimation(anim);
                }
                dlg_menu();
            }
            else if(index1 == 5)
           {
                string str = llList2String(advanced, index1);
                if(str == fullbright_on_str)
                {
                    advanced = llListReplaceList(advanced, [fullbright_off_str], index1, index1);
                    llSetLinkPrimitiveParams(LINK_SET,[PRIM_FULLBRIGHT,ALL_SIDES,TRUE]);
                }
                else
                {
                    advanced = llListReplaceList(advanced, [fullbright_on_str], index1, index1);
                    llSetLinkPrimitiveParams(LINK_SET,[PRIM_FULLBRIGHT,ALL_SIDES,FALSE]);
                }
                dlg_menu();
            }
            else if(index1 == 0)
            {
                dlg_script_delete();
            }
            else if(index1 == 1)
            {
                // XYZ
                change_stretch_type();
                dlg_menu();
            }
        }
        
        if(message == "OK")
        {
            // スクリプト削除
            llRemoveInventory(llGetScriptName());
        }

        if(message == "-")
        {
            dlg_menu();
        }
    }
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TRIGGER_ANIMATION)
        {
            llStartAnimation(anim);
        }
    }

    attach(key attached)
    {
        if(llGetAttached())
        {
            llListenRemove(handle);
            dlg_ch = genCh();
            handle = llListen(dlg_ch, "", NULL_KEY, "");
            
            // 言語の判別
            language = llGetAgentLanguage(llGetOwner());
        }
    }

    changed(integer change)
    {
        if(change & CHANGED_LINK)
        {
            integer prim_n = prim_count();
            if(prim_n != prim_num)
            {
                state reset;
            }
        }
        else if(change & CHANGED_OWNER)
        {
            llResetScript();
        }
    }

    touch_start(integer total_number)
    {
        if(llGetOwner() == llDetectedKey(0))
        {
            dlg_menu();
        }
    }
}

state reset
{
    state_entry()
    {
        string msg;
            
        if(language == "ja")
        {
            msg  = "\nリンク状態が変更されたので"
            + "\n保存したサイズを復元できなくなりました."
            + "\n【RESET】\nを押すとスクリプトをリセットします.";
        }
        else
        {
            msg  = "\n This object's link was changed."
            + "\nand you cannot restore size."
            + "\nplease push【RESET】button. \nand this script can restart.\n";
        }
        handle = llListen(dlg_ch,"", llGetOwner(), "[RESET]");
        llDialog(llGetOwner(), msg, ["[RESET]"], dlg_ch);
    }

    listen(integer channel, string name, key id, string message)
    {
        if(language == "ja")
        {
            llOwnerSay("スクリプトをリセットします.");
        }
        else
        {
            llOwnerSay("This script is restarting now.");
        }
        llResetScript();
    }
}