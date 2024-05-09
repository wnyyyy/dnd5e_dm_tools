// import 'package:flutter/material.dart';

// class ItemWidget extends StatelessWidget {
//   final Map<String, dynamic> item;

//   const ItemWidget({super.key, required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Icon(item.icon),
//       title: Text('${item.name} x${item.quantity}'),
//       subtitle:
//           Text('Cost: ${item.cost} GP, Weight: ${item.getTotalWeight()} lbs'),
//       trailing: item.isEquippable
//           ? Checkbox(
//               value: item.isEquipped,
//               onChanged: (bool? newValue) {
//                 if (newValue != null) {
//                   // Update the state of isEquipped here
//                 }
//               },
//             )
//           : null,
//       onTap: () => showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text(item.name),
//           content: Text('Detailed info about the item.'),
//           actions: [
//             TextButton(
//               child: Text('Close'),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
