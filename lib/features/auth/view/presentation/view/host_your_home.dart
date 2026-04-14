// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
// import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
// import 'package:freelancer/features/auth/view/presentation/view/login_view.dart';

// const _kPrimary = Color(0xFF8B1A1A);
// const _kBg = Color(0xFFF5F0E8);
// const _kCardBg = Colors.white;
// const _kTextDark = Color(0xFF1A1A1A);
// const _kTextLight = Color(0xFF888888);

// class HostYourHome extends StatefulWidget {
//   const HostYourHome({super.key});

//   @override
//   State<HostYourHome> createState() => _HostYourHomeState();
// }

// class _HostYourHomeState extends State<HostYourHome> {
//   final List<_ChatMsg> _messages = [];
//   final TextEditingController _chatCtrl = TextEditingController();
//   final ScrollController _chatScroll = ScrollController();
//   bool _isBotTyping = false;
//   final List<_Ticket> _tickets = [];

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
//   }

//   void _checkAuth() {
//     final state = context.read<AuthCubit>().state;
//     if (state is AuthSuccess || state is AuthAdminSuccess) {
//       // ✅ logged in → Welcome Back
//       final user = state is AuthSuccess
//           ? state.user
//           : (state as AuthAdminSuccess).user;
//       final name =
//           user.userMetadata?['full_name'] ??
//           user.email?.split('@')[0] ??
//           'back';
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: const Color(0xFF2E7D32),
//           duration: const Duration(seconds: 3),
//           content: Text(
//             '👋 Welcome back, $name!',
//             style: const TextStyle(color: Colors.white, fontSize: 14),
//           ),
//         ),
//       );
//     } else {
//       // ❌ not logged in → اطلب Login
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: _kPrimary,
//           duration: const Duration(seconds: 5),
//           content: const Text(
//             'من فضلك سجّل دخولك أولاً للوصول لهذه الصفحة',
//             style: TextStyle(color: Colors.white, fontSize: 14),
//           ),
//           action: SnackBarAction(
//             label: 'Login',
//             textColor: Colors.white,
//             onPressed: () => showDialog(
//               context: context,
//               builder: (_) => BlocProvider.value(
//                 value: context.read<AuthCubit>(),
//                 child: const LoginView(),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _chatCtrl.dispose();
//     _chatScroll.dispose();
//     super.dispose();
//   }

//   void _sendMessage() {
//     final text = _chatCtrl.text.trim();
//     if (text.isEmpty) return;
//     setState(() {
//       _messages.add(_ChatMsg(text: text, isUser: true));
//       _isBotTyping = true;
//     });
//     _chatCtrl.clear();
//     _scrollChat();
//     Future.delayed(const Duration(seconds: 1), () {
//       if (!mounted) return;
//       setState(() {
//         _isBotTyping = false;
//         _messages.add(
//           _ChatMsg(
//             text: 'شكراً على تواصلك! سيقوم فريقنا بالرد عليك في أقرب وقت ممكن.',
//             isUser: false,
//           ),
//         );
//       });
//       _scrollChat();
//     });
//   }

//   void _scrollChat() {
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (_chatScroll.hasClients) {
//         _chatScroll.animateTo(
//           _chatScroll.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   void _showNewTicketDialog() {
//     final titleCtrl = TextEditingController();
//     final descCtrl = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('New Ticket'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: titleCtrl,
//               decoration: const InputDecoration(labelText: 'Title'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: descCtrl,
//               maxLines: 3,
//               decoration: const InputDecoration(labelText: 'Description'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
//             onPressed: () {
//               if (titleCtrl.text.trim().isEmpty) return;
//               setState(() {
//                 _tickets.add(
//                   _Ticket(
//                     title: titleCtrl.text.trim(),
//                     description: descCtrl.text.trim(),
//                     status: 'Open',
//                     date: DateTime.now(),
//                   ),
//                 );
//               });
//               Navigator.pop(ctx);
//             },
//             child: const Text('Submit', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _kBg,
//       appBar: AppBar(
//         backgroundColor: _kBg,
//         elevation: 0,
//         title: const Text(
//           'Host Your Home',
//           style: TextStyle(
//             color: _kTextDark,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: _kTextDark),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         children: [
//           _SectionTitle(title: 'Help'),
//           const SizedBox(height: 8),
//           const _FaqSection(),
//           const SizedBox(height: 24),
//           _AiChatCard(
//             messages: _messages,
//             isBotTyping: _isBotTyping,
//             controller: _chatCtrl,
//             scrollController: _chatScroll,
//             onSend: _sendMessage,
//           ),
//           const SizedBox(height: 24),
//           _SupportTicketsCard(
//             tickets: _tickets,
//             onNewTicket: _showNewTicketDialog,
//           ),
//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }
// }

// // ============================================================
// // SECTION TITLE
// // ============================================================
// class _SectionTitle extends StatelessWidget {
//   final String title;
//   const _SectionTitle({required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 28,
//         fontWeight: FontWeight.bold,
//         color: _kTextDark,
//       ),
//     );
//   }
// }

// // ============================================================
// // FAQ SECTION
// // ============================================================
// class _FaqSection extends StatelessWidget {
//   const _FaqSection();

//   static const List<Map<String, String>> _faqs = [
//     {
//       'q': 'How do I list my property?',
//       'a':
//           'Go to My Listings from the menu and tap "+ Add Listing". Fill in all required details and submit for review.',
//     },
//     {
//       'q': 'How do I get paid?',
//       'a':
//           'Payments are processed automatically after each confirmed checkout. Funds appear in your Earnings & Balance within 24 hours.',
//     },
//     {
//       'q': 'Can I block dates on my calendar?',
//       'a':
//           'Yes! Open your listing, go to the Calendar tab, and tap any date to block or unblock it.',
//     },
//     {
//       'q': 'What if a guest damages my property?',
//       'a':
//           'Open a Support Ticket below with photos and details. Our team will review your claim within 48 hours.',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _kCardBg,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: _faqs.asMap().entries.map((entry) {
//           final isLast = entry.key == _faqs.length - 1;
//           return Column(
//             children: [
//               _FaqItem(q: entry.value['q']!, a: entry.value['a']!),
//               if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// class _FaqItem extends StatefulWidget {
//   final String q;
//   final String a;
//   const _FaqItem({required this.q, required this.a});

//   @override
//   State<_FaqItem> createState() => _FaqItemState();
// }

// class _FaqItemState extends State<_FaqItem> {
//   bool _open = false;

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(16),
//       onTap: () => setState(() => _open = !_open),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     widget.q,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                       color: _kTextDark,
//                     ),
//                   ),
//                 ),
//                 Icon(
//                   _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
//                   color: _kTextLight,
//                 ),
//               ],
//             ),
//             if (_open) ...[
//               const SizedBox(height: 8),
//               Text(
//                 widget.a,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   color: _kTextLight,
//                   height: 1.5,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ============================================================
// // AI CHAT CARD
// // ============================================================
// class _AiChatCard extends StatelessWidget {
//   final List<_ChatMsg> messages;
//   final bool isBotTyping;
//   final TextEditingController controller;
//   final ScrollController scrollController;
//   final VoidCallback onSend;

//   const _AiChatCard({
//     required this.messages,
//     required this.isBotTyping,
//     required this.controller,
//     required this.scrollController,
//     required this.onSend,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _kCardBg,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             decoration: const BoxDecoration(
//               color: Color(0xFFF2EDE4),
//               borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//             ),
//             child: Row(
//               children: const [
//                 Icon(Icons.smart_toy_outlined, color: _kPrimary, size: 20),
//                 SizedBox(width: 8),
//                 Text(
//                   'How can we help?',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                     color: _kTextDark,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(
//             height: 260,
//             child: messages.isEmpty && !isBotTyping
//                 ? const Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.smart_toy_outlined,
//                           size: 48,
//                           color: Color(0xFFCCCCCC),
//                         ),
//                         SizedBox(height: 12),
//                         Text(
//                           "Hi! I'm your AI assistant. Ask me anything.",
//                           style: TextStyle(color: _kTextLight, fontSize: 14),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView(
//                     controller: scrollController,
//                     padding: const EdgeInsets.all(12),
//                     children: [
//                       ...messages.map((m) => _ChatBubble(msg: m)),
//                       if (isBotTyping)
//                         const Align(
//                           alignment: Alignment.centerLeft,
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(vertical: 4),
//                             child: _TypingIndicator(),
//                           ),
//                         ),
//                     ],
//                   ),
//           ),
//           const Divider(height: 1),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: controller,
//                     onSubmitted: (_) => onSend(),
//                     decoration: InputDecoration(
//                       hintText: 'Type your message...',
//                       hintStyle: const TextStyle(color: _kTextLight),
//                       filled: true,
//                       fillColor: const Color(0xFFF5F0E8),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 10,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(25),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 GestureDetector(
//                   onTap: onSend,
//                   child: Container(
//                     width: 44,
//                     height: 44,
//                     decoration: BoxDecoration(
//                       color: _kPrimary.withOpacity(0.7),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.send,
//                       color: Colors.white,
//                       size: 18,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ChatMsg {
//   final String text;
//   final bool isUser;
//   _ChatMsg({required this.text, required this.isUser});
// }

// class _ChatBubble extends StatelessWidget {
//   final _ChatMsg msg;
//   const _ChatBubble({required this.msg});

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.65,
//         ),
//         decoration: BoxDecoration(
//           color: msg.isUser ? _kPrimary : const Color(0xFFF2EDE4),
//           borderRadius: BorderRadius.only(
//             topLeft: const Radius.circular(16),
//             topRight: const Radius.circular(16),
//             bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
//             bottomRight: Radius.circular(msg.isUser ? 4 : 16),
//           ),
//         ),
//         child: Text(
//           msg.text,
//           style: TextStyle(
//             color: msg.isUser ? Colors.white : _kTextDark,
//             fontSize: 13,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _TypingIndicator extends StatelessWidget {
//   const _TypingIndicator();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF2EDE4),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: const Text('...', style: TextStyle(color: _kTextLight)),
//     );
//   }
// }

// // ============================================================
// // SUPPORT TICKETS CARD
// // ============================================================
// class _Ticket {
//   final String title;
//   final String description;
//   final String status;
//   final DateTime date;
//   _Ticket({
//     required this.title,
//     required this.description,
//     required this.status,
//     required this.date,
//   });
// }

// class _SupportTicketsCard extends StatelessWidget {
//   final List<_Ticket> tickets;
//   final VoidCallback onNewTicket;
//   const _SupportTicketsCard({required this.tickets, required this.onNewTicket});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _kCardBg,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             child: Row(
//               children: [
//                 const Text(
//                   'Support Tickets',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: _kTextDark,
//                   ),
//                 ),
//                 const Spacer(),
//                 GestureDetector(
//                   onTap: onNewTicket,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _kPrimary,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Row(
//                       children: [
//                         Icon(Icons.add, color: Colors.white, size: 16),
//                         SizedBox(width: 4),
//                         Text(
//                           'New Ticket',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           tickets.isEmpty
//               ? const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 40),
//                   child: Center(
//                     child: Text(
//                       'No support tickets found.',
//                       style: TextStyle(color: _kTextLight, fontSize: 14),
//                     ),
//                   ),
//                 )
//               : Column(
//                   children: tickets.map((t) => _TicketItem(ticket: t)).toList(),
//                 ),
//         ],
//       ),
//     );
//   }
// }

// class _TicketItem extends StatelessWidget {
//   final _Ticket ticket;
//   const _TicketItem({required this.ticket});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   ticket.title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                     color: _kTextDark,
//                   ),
//                 ),
//                 if (ticket.description.isNotEmpty) ...[
//                   const SizedBox(height: 4),
//                   Text(
//                     ticket.description,
//                     style: const TextStyle(fontSize: 12, color: _kTextLight),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: const Color(0xFFE8F5E9),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               ticket.status,
//               style: const TextStyle(
//                 color: Color(0xFF2E7D32),
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
