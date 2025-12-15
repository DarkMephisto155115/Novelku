// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
//
// class ProfileStoryPage extends GetView<> {
//   const ProfileStoryPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final arguments = Get.arguments as Map<String, dynamic>;
//     final storyId = arguments['id'] as String;
//     controller.setStoryId(storyId);
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Colors.deepPurple.shade900, Colors.black],
//           ),
//         ),
//         child: SafeArea(
//           child: CustomScrollView(
//             slivers: [
//               SliverAppBar(
//                 expandedHeight: 200.0,
//                 floating: false,
//                 pinned: true,
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.edit, color: Colors.black),
//                     onPressed: () {
//                       // Navigate to the edit page or open a modal for editing
//                       Get.toNamed('/edit_read', arguments: {
//                         'id': controller.storyId.value,
//                         'title': controller.title.value,
//                         'content': controller.content.value,
//                         // Add other story-related data if needed
//                       });
//                     },
//                   ),
//                 ],
//                 flexibleSpace: FlexibleSpaceBar(
//                   title: Obx(() {
//                     if (controller.title.isEmpty) {
//                       return const Text('Loading...', style: TextStyle(color: Colors.red));
//                     }
//                     // print(controller.title.value);
//                     return Text(
//                       controller.title.value,
//                       style: const TextStyle(color: Colors.white),
//                     );
//                   }),
//                   background: Obx(() {
//                     if (controller.imagePath.value.isEmpty) {
//                       // return CircularProgressIndicator();
//                       return Container(
//                         height: 200,
//                         width: double.infinity,
//                         decoration: const BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                             colors: [
//                               Color.fromARGB(255, 188, 249, 244),
//                               Color.fromARGB(255, 103, 144, 255),
//                             ],
//                           ),
//                         ),
//                       );
//                     }
//                     return Hero(
//                       tag: 'story-image-${controller.storyId.value}',
//                       child: Image.network(
//                         controller.imagePath.value,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) =>
//                             Image.asset('assets/placeholder.png', fit: BoxFit.cover),
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: AnimationLimiter(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: AnimationConfiguration.toStaggeredList(
//                       duration: const Duration(milliseconds: 375),
//                       childAnimationBuilder: (widget) => SlideAnimation(
//                         verticalOffset: 50.0,
//                         child: FadeInAnimation(child: widget),
//                       ),
//                       children: [
//                         _buildAuthorInfo(),
//                         _buildStoryContent(),
//                         _buildActionButtons(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAuthorInfo() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           Obx(() {
//             return CircleAvatar(
//                 radius: 24,
//                 backgroundImage: controller.writerImage.value.isNotEmpty
//                     ? NetworkImage(controller.writerImage.value)
//                     : const AssetImage('assets/images/default_profile.jpeg')
//             );
//           }),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Obx(() {
//                 return Text(
//                   controller.writerName.value,
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold),
//                 );
//               }),
//               Obx(() {
//                 return Text(
//                   "@${controller.writerUsername.value}",
//                   style: const TextStyle(
//                     color: Colors.grey,
//                     fontSize: 12,
//                     fontWeight: FontWeight.normal,
//                   ),
//                 );
//               }),
//               Obx(() {
//                 return Text(
//                   'Diterbitkan pada ${controller.date.value}',
//                   style: TextStyle(color: Colors.grey[400], fontSize: 14),
//                 );
//               }),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStoryContent() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Obx(() {
//         return Text(
//           controller.content.value.isNotEmpty
//               ? controller.content.value.replaceAll('\\n', '\n')
//               : 'Tidak ada konten',
//           style: const TextStyle(color: Colors.white, fontSize: 16),
//         );
//       }),
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildActionButton(
//             icon: Icons.favorite,
//             label: 'Suka',
//             onPressed: () {
//               // Implementasi aksi suka
//             },
//           ),
//           _buildActionButton(
//             icon: Icons.comment,
//             label: 'Komentar',
//             onPressed: () {
//               // Implementasi aksi komentar
//             },
//           ),
//           _buildActionButton(
//             icon: Icons.share,
//             label: 'Bagikan',
//             onPressed: () {
//               // Implementasi aksi bagikan
//             },
//           ),
//           _buildActionButton(
//             icon: Icons.edit,
//             label: 'Edit',
//             onPressed: () {
//               // Navigate to the edit page or open a modal for editing
//               Get.toNamed('/edit_read', arguments: {
//                 'id': controller.storyId.value,
//                 'title': controller.title.value,
//                 'content': controller.content.value,
//                 // Add other story-related data if needed
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onPressed,
//   }) {
//     return InkWell(
//       onTap: onPressed,
//       child: Column(
//         children: [
//           Icon(icon, color: Colors.white),
//           const SizedBox(height: 4),
//           Text(label, style: const TextStyle(color: Colors.white)),
//         ],
//       ),
//     );
//   }
// }
