// ignore_for_file: unused_import

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_uikit/tencent_cloud_chat_uikit.dart';
import 'package:tencent_cloud_chat_uikit/ui/controller/tim_uikit_conversation_controller.dart';

import 'package:tencent_cloud_chat_uikit/ui/views/TIMUIKitSearch/tim_uikit_search.dart';
import 'package:timuikit/src/chat.dart';

import 'package:provider/provider.dart';
import 'package:timuikit/src/provider/local_setting.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/src/search.dart';

GlobalKey<_ConversationState> conversationKey = GlobalKey();

class Conversation extends StatefulWidget {
  final TIMUIKitConversationController conversationController;
  const Conversation({Key? key, required this.conversationController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  late TIMUIKitConversationController _controller;
  List<String> jumpedConversations = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.conversationController;
  }

  void _handleOnConvItemTaped(V2TimConversation? selectedConv) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chat(
            selectedConversation: selectedConv!,
          ),
        ));
    _controller.reloadData();
  }

  scrollToNextUnreadConversation(){
    final conversationList = _controller.conversationList;
    for (var element in conversationList) {
      if((element?.unreadCount ?? 0) > 0 && !jumpedConversations.contains(element!.conversationID)){
        _controller.scrollToConversation(element.conversationID);
        jumpedConversations.add(element.conversationID);
        return;
      }
    }
    jumpedConversations.clear();
    try{
      _controller.scrollToConversation(conversationList[0]!.conversationID);
    }catch(e){
      print(e);
    }
  }

  void _handleOnConvItemTapedWithPlace(V2TimConversation? selectedConv,
      [V2TimMessage? targetMsg]) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chat(
            selectedConversation: selectedConv!,
            initFindingMsg: targetMsg,
          ),
        ));
    _controller.reloadData();
  }

  _clearHistory(V2TimConversation conversationItem) {
    _controller.clearHistoryMessage(conversation: conversationItem);
  }

  _pinConversation(V2TimConversation conversation) {
    _controller.pinConversation(
        conversationID: conversation.conversationID,
        isPinned: !conversation.isPinned!);
  }

  _deleteConversation(V2TimConversation conversation) {
    _controller.deleteConversation(conversationID: conversation.conversationID);
  }


  List<ConversationItemSlidablePanel> _itemSlidableBuilder(
      V2TimConversation conversationItem) {
    return [
      if(!kIsWeb) ConversationItemSlidablePanel(
        onPressed: (context) {
          _clearHistory(conversationItem);
        },
        backgroundColor: hexToColor("006EFF"),
        foregroundColor: Colors.white,
        label: TIM_t("清除聊天"),
        autoClose: true,
      ),
      ConversationItemSlidablePanel(
        onPressed: (context) {
          _pinConversation(conversationItem);
        },
        backgroundColor: hexToColor("FF9C19"),
        foregroundColor: Colors.white,
        label: conversationItem.isPinned! ? TIM_t("取消置顶") : TIM_t("置顶"),
      ),
      ConversationItemSlidablePanel(
        onPressed: (context) {
          _deleteConversation(conversationItem);
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        label: TIM_t("删除"),
      )
    ];
  }

  Widget searchEntry(TUITheme theme) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  Search(onTapConversation: _handleOnConvItemTapedWithPlace),
            ));
      },
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
              theme.primaryColor ?? CommonColor.primaryColor
            ]),
            boxShadow: [
              BoxShadow(
                color: theme.weakDividerColor ?? hexToColor("E6E9EB"),
                offset: const Offset(0.0, 2.0),
              )
            ]),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  color: hexToColor("979797"),
                  size: 18,
                ),
                Text(TIM_t("搜索"),
                    style: TextStyle(
                      color: hexToColor("979797"),
                      fontSize: 14,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    final LocalSetting localSetting = Provider.of<LocalSetting>(context);
    return Column(
      children: [
        searchEntry(theme),
        Expanded(
            child: TIMUIKitConversation(
          onTapItem: _handleOnConvItemTaped,
          isShowOnlineStatus: localSetting.isShowOnlineStatus,
          itemSlidableBuilder: _itemSlidableBuilder,
          controller: _controller,
              emptyBuilder: () {
                return Container(
                  padding: const EdgeInsets.only(top:100),
                  child: Center(
                    child: Text(TIM_t("暂无会话")),
                  ),
                );
              },
        ))
      ],
    );
  }
}
