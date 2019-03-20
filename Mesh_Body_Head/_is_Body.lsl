string product_id = "BMS_MESH_BODY";

list prim_list;
list prim_trans_list;

integer channel;
integer listen_handle;

integer ALL_flag = FALSE;

// Prim List 作成
createIndex()
{
    prim_list = [];
    
    integer i;
    prim_list = [""];    // ルート ( 1 : 起算 )
    prim_trans_list = [""];
    
    prim_list += [llGetObjectName()];
    for(i = 2; i <= llGetNumberOfPrims() ; i++)
    {
        string prim_name = llGetLinkName(i);
        prim_list += [prim_name];
        
        prim_trans_list +=
            llList2Integer(llGetLinkPrimitiveParams(i, [PRIM_COLOR, ALL_SIDES]),1);
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
    return llDumpList2String(llParseStringKeepNulls(str, [search], []), replace);
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

// 全身消す
all_clear()
{
    float trans = 0.0;
    if(ALL_flag == TRUE)
    {
        trans = 1.0; // 全身表示
        ALL_flag = FALSE;
    }
    else
    {
        trans = 0.0; // 全身非表示
        ALL_flag = TRUE;
    }
    
    prim_trans_list = [];
    prim_trans_list = [""];
    
    integer child_index = 2; // 子プリム開始 Index : 2
    list cmd = [PRIM_COLOR, ALL_SIDES, <1,1,1>, trans];
    integer i;
    for(i = child_index + 1 ; i < llGetListLength(prim_list); i++)
    {
        cmd += [PRIM_LINK_TARGET, i, PRIM_COLOR, ALL_SIDES, <1,1,1>, trans];
        prim_trans_list += (integer)trans;
    }
    
    llSetLinkPrimitiveParams(child_index, cmd);
}

default
{
    state_entry()
    {       
        createIndex();
        channel = genCh();
        
        listen_handle = llListen(channel, "", NULL_KEY, "");
    }
    
    attach(key id)
    {
        if(id)
        {
            channel = genCh();
        }
    }
    
    listen( integer channel, string name, key user, string message )
    {
        if(llGetOwnerKey(user) != llGetOwner()) return;
        
        integer prim_num = getIndex(message);
        integer flag;
        
        if(message == "ALL")
        {
            all_clear();
        }
        else if(prim_num != -1)
        {
            float alpha = llList2Float(
                llGetLinkPrimitiveParams(prim_num, [PRIM_COLOR, ALL_SIDES]),
                1);
                
            if(alpha == 0.0)
            {
                llSetLinkPrimitiveParams(prim_num,
                    [PRIM_COLOR, ALL_SIDES, <1,1,1>, 1.0]);
                prim_trans_list = llListReplaceList(prim_trans_list, [1], prim_num, prim_num);
            }
            else
            {
                llSetLinkPrimitiveParams(prim_num,
                    [PRIM_COLOR, ALL_SIDES, <1,1,1>, 0.0]);
                prim_trans_list = llListReplaceList(prim_trans_list, [0], prim_num, prim_num);
            }
        }
        
        // HUD に状態 送信
        llSay(channel+1, "parts" + llList2CSV(prim_list));
        llSay(channel+1, "info" + llList2CSV(prim_trans_list));
    }
}