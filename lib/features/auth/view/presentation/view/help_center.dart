import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/auth/view/presentation/view/login_view.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';
// استدعاء الفوتر الخاص بك

const _kPrimary = Color(0xFF8B1A1A);
const _kBg = Color(0xFFF5F0E8);
const _kCardBg = Colors.white;
const _kTextDark = Color(0xFF1A1A1A);
const _kTextLight = Color(0xFF888888);

class HelpCenter extends StatefulWidget {
  const HelpCenter({super.key});

  @override
  State<HelpCenter> createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  final List<_ChatMsg> _messages = [];
  final TextEditingController _chatCtrl = TextEditingController();
  final ScrollController _chatScroll = ScrollController();
  bool _isBotTyping = false;
  final List<_Ticket> _tickets = [];

  void _sendMessage() {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(text: text, isUser: true));
      _isBotTyping = true;
    });
    _chatCtrl.clear();
    _scrollChat();
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isBotTyping = false;
        _messages.add(
          _ChatMsg(
            text: 'شكراً على تواصلك! سيقوم فريقنا بالرد عليك في أقرب وقت ممكن.',
            isUser: false,
          ),
        );
      });
      _scrollChat();
    });
  }

  void _scrollChat() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showNewTicketDialog() {
    final state = context.read<AuthCubit>().state;
    if (state is! AuthSuccess && state is! AuthAdminSuccess) {
      _showLoginSnackBar();
      return;
    }

    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              setState(() {
                _tickets.add(
                  _Ticket(
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    status: 'Open',
                    date: DateTime.now(),
                  ),
                );
              });
              Navigator.pop(ctx);
            },
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLoginSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _kPrimary,
        content: const Text('من فضلك سجّل دخولك أولاً'),
        action: SnackBarAction(
          label: 'Login',
          textColor: Colors.white,
          onPressed: () => showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<AuthCubit>(),
              child: const LoginView(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: const CustomAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const _FaqSection(),
          const SizedBox(height: 24),
          _AiChatCard(
            messages: _messages,
            isBotTyping: _isBotTyping,
            controller: _chatCtrl,
            scrollController: _chatScroll,
            onSend: _sendMessage,
          ),
          const SizedBox(height: 24),
          _SupportTicketsCard(
            tickets: _tickets,
            onNewTicket: _showNewTicketDialog,
          ),
          const SizedBox(height: 32),

          // استدعاء الفوتر الخاص بك هنا بدلاً من القديم
          const CustomFooter(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// --- FAQ Widgets ---
class _FaqSection extends StatelessWidget {
  const _FaqSection();
  static const List<Map<String, String>> _faqs = [
    {'q': 'Test Q', 'a': 'Answer 1'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _faqs.map((f) => _FaqItem(q: f['q']!, a: f['a']!)).toList(),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String q, a;
  const _FaqItem({required this.q, required this.a});
  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            widget.q,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          trailing: Icon(
            _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          ),
          onTap: () => setState(() => _open = !_open),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              widget.a,
              style: const TextStyle(color: _kTextLight, fontSize: 13),
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}

// --- AI Chat Widgets ---
class _AiChatCard extends StatelessWidget {
  final List<_ChatMsg> messages;
  final bool isBotTyping;
  final TextEditingController controller;
  final ScrollController scrollController;
  final VoidCallback onSend;

  const _AiChatCard({
    required this.messages,
    required this.isBotTyping,
    required this.controller,
    required this.scrollController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFF2EDE4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.smart_toy_outlined, color: _kPrimary, size: 20),
                SizedBox(width: 8),
                Text(
                  'How can we help?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 260,
            child: messages.isEmpty && !isBotTyping
                ? const Center(
                    child: Text(
                      "Hi! I'm your AI assistant.",
                      style: TextStyle(color: _kTextLight),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length + (isBotTyping ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == messages.length) return const Text('...');
                      return _ChatBubble(msg: messages[i]);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      filled: true,
                      fillColor: _kBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onSend,
                  icon: const Icon(Icons.send, color: _kPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  final String text;
  final bool isUser;
  _ChatMsg({required this.text, required this.isUser});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMsg msg;
  const _ChatBubble({required this.msg});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: msg.isUser ? _kPrimary : const Color(0xFFF2EDE4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.white : _kTextDark,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// --- Ticket Widgets ---
class _Ticket {
  final String title, description, status;
  final DateTime date;
  _Ticket({
    required this.title,
    required this.description,
    required this.status,
    required this.date,
  });
}

class _SupportTicketsCard extends StatelessWidget {
  final List<_Ticket> tickets;
  final VoidCallback onNewTicket;
  const _SupportTicketsCard({required this.tickets, required this.onNewTicket});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'Support Tickets',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: ElevatedButton.icon(
              onPressed: onNewTicket,
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text('New', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
            ),
          ),
          if (tickets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No tickets found.'),
            )
          else
            ...tickets.map(
              (t) => ListTile(
                title: Text(t.title),
                subtitle: Text(
                  t.status,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
