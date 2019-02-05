float rot_deg = 180; // HUD 回転量
rotation rot_rad;
integer rot_flag = FALSE;
rotation ini_local_rot;
list prim_list;
integer channel;

// Prim List 作成
createIndex()
{
    prim_list = [];
    
    integer i;
    prim_list = [""];    // ルート ( 1 : 起算 )
    prim_list += [llGetObjectName()];
    for(i = 2; i <= llGetNumberOfPrims() ; i++)
    {
        string prim_name = llGetLinkName(i);
        prim_list += [prim_name];
    }
}

// Prim Nmae から インデックス を返す
integer getIndex(string prim_name)
{
    return llListFindList(prim_list, [prim_name]);   
}

// 文字列置換
string strReplace(string str, string search, string replace)
{
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}

integer genCh()
{
    integer gen;
    key id = llGetOwner();
    string str = llGetSubString((string)id,0,3);
    gen = -1-(integer)("0x"+str);
    if(gen<0) gen*=-1;
    return gen;
}

default
{
    state_entry()
    {
        ini_local_rot = llGetLocalRot();
        rot_rad = llEuler2Rot( <0.0, rot_deg, 0.0> * DEG_TO_RAD );
        
        createIndex();
        channel = genCh();
    }
 
    touch_start( integer vIntTouched )
    {
        integer touch_link = llDetectedLinkNumber(0);
        integer touch_face = llDetectedTouchFace(0);

        if(getIndex(llGetObjectName()) == touch_link)
        {
            if(!rot_flag)
            {
                llSetLocalRot( ini_local_rot * rot_rad );
                rot_flag = TRUE;
            }
            else
            {
                llSetLocalRot( ini_local_rot);
                rot_flag = FALSE;
            }
        }
        else
        {
            string touch_obj_name = llList2String(prim_list, touch_link);
            llWhisper(channel, touch_obj_name);
        }
    }
}