// import 'dart:async';
// import 'dart:collection';
// import 'dart:math';

// import 'package:dnd5e_dm_tools/core/data/models/backpack.dart';
// import 'package:dnd5e_dm_tools/core/data/models/character.dart';
// import 'package:dnd5e_dm_tools/core/util/enum.dart';
// import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
// import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class BackpackWidget extends StatefulWidget {
//   const BackpackWidget({
//     super.key,
//     required this.backpack,
//     required this.characterSlug,
//   });
//   final Backpack backpack;
//   final String characterSlug;

//   @override
//   State<BackpackWidget> createState() => _BackpackWidgetState();
// }

// class _BackpackWidgetState extends State<BackpackWidget> {
//   EquipSort sortCriteria = EquipSort.name;
//   EquipFilter filterCriteria = EquipFilter.all;
//   Map<String, Map<String, dynamic>> items = {};

//   @override
//   void initState() {
//     super.initState();
//     sortCriteria = context.read<SettingsCubit>().state.selectedEquipSort;
//     filterCriteria = context.read<SettingsCubit>().state.selectedEquipFilter;
//   }

//   List<DropdownMenuItem<EquipSort>> get dropdownItems {
//     return [
//       const DropdownMenuItem(value: EquipSort.name, child: Text('Name')),
//       const DropdownMenuItem(value: EquipSort.value, child: Text('Value')),
//       const DropdownMenuItem(
//         value: EquipSort.canEquip,
//         child: Text('Can Equip'),
//       ),
//     ];
//   }

//   Widget buildAddItemButton() {
//     // return AddItemButton(
//     //   onAdd: (itemSlug, isMagic) {
//     //     if (!isMagic) {
//     //       showDialog(
//     //         context: context,
//     //         builder: (BuildContext context) {
//     //           return _buildQuantityDialog(context, itemSlug);
//     //         },
//     //       );
//     //     } else {
//     //       _addItemToBackpack(itemSlug, 1);
//     //       Navigator.pop(context);
//     //     }
//     //   },
//     // );
//     return Container();
//   }

//   AlertDialog _buildQuantityDialog(BuildContext context, String itemSlug) {
//     int quantity = 1;
//     Timer? timer;
//     final TextEditingController controller = TextEditingController();
//     controller.text = quantity.toString();

//     void incrementQuantity() {
//       setState(() {
//         quantity++;
//         controller.text = quantity.toString();
//       });
//     }

//     void decrementQuantity() {
//       setState(() {
//         quantity = max(1, quantity - 1);
//         controller.text = quantity.toString();
//       });
//     }

//     return AlertDialog(
//       title: const Text('Quantity'),
//       content: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: <Widget>[
//           GestureDetector(
//             onTap: decrementQuantity,
//             onLongPressStart: (details) {
//               timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
//                 decrementQuantity();
//               });
//             },
//             onLongPressEnd: (details) {
//               timer?.cancel();
//             },
//             child: const Icon(Icons.remove_circle_outline),
//           ),
//           SizedBox(
//             width: 100,
//             child: TextField(
//               textAlign: TextAlign.center,
//               decoration: const InputDecoration(border: OutlineInputBorder()),
//               controller: controller,
//               keyboardType: TextInputType.number,
//               onChanged: (value) {
//                 final int newQuantity = int.tryParse(value) ?? 1;
//                 setState(() {
//                   quantity = max(1, newQuantity);
//                 });
//               },
//             ),
//           ),
//           GestureDetector(
//             onTap: incrementQuantity,
//             onLongPressStart: (details) {
//               timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
//                 incrementQuantity();
//               });
//             },
//             onLongPressEnd: (details) {
//               timer?.cancel();
//             },
//             child: const Icon(Icons.add_circle_outline),
//           ),
//         ],
//       ),
//       actionsAlignment: MainAxisAlignment.spaceBetween,
//       actions: <Widget>[
//         TextButton(
//           child: const Icon(Icons.close),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         TextButton(
//           child: const Icon(Icons.done),
//           onPressed: () {
//             _addItemToBackpack(itemSlug, quantity);
//             Navigator.pop(context);
//           },
//         ),
//       ],
//     );
//   }

//   void _addItemToBackpack(
//     String itemSlug,
//     int quantity, {
//     bool isEquipped = false,
//   }) {
//     // final items =
//     //     (widget.character['backpack'] as Map?)?['items']
//     //         as Map<String, dynamic>? ??
//     //     {};
//     // final currQuantity =
//     //     (items[itemSlug] != null
//     //         ? int.tryParse(
//     //             (items[itemSlug] as Map)['quantity']?.toString() ?? '0',
//     //           )
//     //         : 0) ??
//     //     0;
//     // items[itemSlug] = {
//     //   'quantity': currQuantity + quantity,
//     //   'isEquipped': isEquipped,
//     };
//   }

//   bool applyFilter(
//     Map<String, dynamic> item,
//     EquipFilter filter,
//     bool isEquipped,
//   ) {
//     switch (filter) {
//       case EquipFilter.all:
//         return true;
//       case EquipFilter.equipped:
//         return isEquipped;
//       case EquipFilter.canEquip:
//         return isEquipable(item);
//       default:
//         return true;
//     }
//   }

//   Map<String, Map<String, dynamic>> sortItems(
//     Map<String, Map<String, dynamic>> items,
//     EquipSort criteria,
//   ) {
//     final sortedEntries = items.entries.toList();

//     switch (criteria) {
//       case EquipSort.name:
//         sortedEntries.sort(
//           (a, b) => (a.value['name']?.toString() ?? '').compareTo(
//             b.value['name']?.toString() ?? '',
//           ),
//         );
//       case EquipSort.value:
//         sortedEntries.sort(
//           (b, a) =>
//               getCostTotal(
//                 (a.value['cost'] as Map?)?['unit']?.toString() ?? 'none',
//                 num.tryParse(
//                       (a.value['cost'] as Map?)?['quantity']?.toString() ?? '0',
//                     ) ??
//                     0,
//                 int.tryParse(a.value['quantity']?.toString() ?? '0') ?? 0,
//               ).compareTo(
//                 getCostTotal(
//                   (b.value['cost'] as Map?)?['unit']?.toString() ?? 'none',
//                   num.tryParse(
//                         (b.value['cost'] as Map?)?['quantity']?.toString() ??
//                             '0',
//                       ) ??
//                       0,
//                   int.tryParse(b.value['quantity']?.toString() ?? '0') ?? 0,
//                 ),
//               ),
//         );
//       case EquipSort.canEquip:
//         sortedEntries.sort((a, b) {
//           if (isEquipable(a.value) && !isEquipable(b.value)) return -1;
//           if (!isEquipable(a.value) && isEquipable(b.value)) return 1;
//           return 0;
//         });
//     }
//     return Map.fromEntries(sortedEntries);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     items.clear();

//     for (final backpackItem in backpackItems.entries) {
//       final item = context.read<RulesCubit>().getItem(backpackItem.key);
//       if (item != null) {
//         final Map<String, dynamic> typedItem = Map<String, dynamic>.from(item);

//         if (applyFilter(
//           typedItem,
//           filterCriteria,
//           backpackItem.value['isEquipped'] as bool? ?? false,
//         )) {
//           items[backpackItem.key] = typedItem;
//           items[backpackItem.key]?['quantity'] =
//               backpackItem.value['quantity'] ?? 0;
//           items[backpackItem.key]?['isEquipped'] =
//               backpackItem.value['isEquipped'] ?? false;
//         }
//       }
//     }

//     final sortedItems = sortItems(items, sortCriteria);

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final bool isWide = constraints.maxWidth > 900;
//         final double horizontalPadding = isWide ? screenWidth * 0.1 : 16;

//         return Column(
//           children: [
//             _buildFilters(horizontalPadding, isWide),
//             Expanded(
//               child: Card(
//                 margin: EdgeInsets.symmetric(
//                   horizontal: horizontalPadding,
//                   vertical: 8,
//                 ),
//                 child: isWide
//                     ? _buildWideLayout(sortedItems)
//                     : _buildNarrowLayout(sortedItems),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildFilters(double horizontalPadding, bool wide) {
//     return Padding(
//       padding: EdgeInsets.only(
//         right: horizontalPadding,
//         left: horizontalPadding,
//         top: 8,
//       ),
//       child: Flex(
//         direction: wide ? Axis.horizontal : Axis.vertical,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: wide
//             ? MainAxisAlignment.spaceBetween
//             : MainAxisAlignment.start,
//         children: [
//           Wrap(
//             spacing: 8.0,
//             children: [
//               ChoiceChip(
//                 label: const Text('All Items'),
//                 selected: filterCriteria == EquipFilter.all,
//                 onSelected: (bool selected) {
//                   setState(() {
//                     filterCriteria = EquipFilter.all;
//                   });
//                   context.read<SettingsCubit>().toggleEquipFilter(
//                     EquipFilter.all,
//                   );
//                 },
//               ),
//               ChoiceChip(
//                 label: const Text('Equipped'),
//                 selected: filterCriteria == EquipFilter.equipped,
//                 onSelected: (bool selected) {
//                   setState(() {
//                     filterCriteria = EquipFilter.equipped;
//                   });
//                   context.read<SettingsCubit>().toggleEquipFilter(
//                     EquipFilter.equipped,
//                   );
//                 },
//               ),
//               ChoiceChip(
//                 label: const Text('Can Equip'),
//                 selected: filterCriteria == EquipFilter.canEquip,
//                 onSelected: (bool selected) {
//                   setState(() {
//                     filterCriteria = EquipFilter.canEquip;
//                     context.read<SettingsCubit>().toggleEquipFilter(
//                       EquipFilter.canEquip,
//                     );
//                   });
//                 },
//               ),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 8.0),
//             child: DropdownButton<EquipSort>(
//               value: sortCriteria,
//               items: dropdownItems,
//               onChanged: (EquipSort? value) {
//                 setState(() {
//                   sortCriteria = value ?? EquipSort.name;
//                   context.read<SettingsCubit>().toggleEquipSort(
//                     value ?? EquipSort.name,
//                   );
//                 });
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWideLayout(Map<String, Map<String, dynamic>> sortedItems) {
//     return Row(
//       children: [
//         Expanded(flex: 3, child: _buildItemList(sortedItems)),
//         const VerticalDivider(),
//         SizedBox(
//           width: 200,
//           child: Column(
//             children: [
//               // Padding(
//               //   padding: const EdgeInsets.only(right: 16.0),
//               //   child: CoinsWidget(
//               //     character: widget.character,
//               //     slug: widget.slug,
//               //   ),
//               // ),
//               buildAddItemButton(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNarrowLayout(Map<String, Map<String, dynamic>> sortedItems) {
//     return Column(
//       children: [
//         Expanded(child: _buildItemList(sortedItems)),
//         const SizedBox(
//           height: 8,
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Divider(),
//           ),
//         ),
//         Row(
//           children: [
//             // Expanded(
//             //   flex: 3,
//             //   child: CoinsWidget(
//             //     character: widget.character,
//             //     slug: widget.slug,
//             //   ),
//             // ),
//             const SizedBox(width: 8, height: 80, child: VerticalDivider()),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: buildAddItemButton(),
//               ),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.only(
//                   left: 16.0,
//                   top: 8.0,
//                   bottom: 8.0,
//                 ),
//                 child: Text(
//                   'Total Weight: ${getTotalWeight(items, sortedItems)}',
//                   style: Theme.of(context).textTheme.bodySmall,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   ListView _buildItemList(Map<String, Map<String, dynamic>> sortedItems) {
//     return ListView.separated(
//       itemCount: sortedItems.length,
//       itemBuilder: (context, index) {
//         final backpackItem = sortedItems.entries.elementAt(index);
//         if (backpackItem.value.isEmpty || backpackItem.value['quantity'] == 0) {
//           return const SizedBox.shrink();
//         }
//         final item = Map<String, dynamic>.from(items[backpackItem.key] ?? {});
//         if (item.isEmpty) {
//           return const SizedBox.shrink();
//         }
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: ItemWidget(
//             item: item,
//             quantity:
//                 int.tryParse(
//                   backpackItem.value['quantity']?.toString() ?? '0',
//                 ) ??
//                 0,
//             onQuantityChange: (quantity) {
//               if (quantity == 0) {
//                 items.remove(backpackItem.key);
//               } else {
//                 (items[backpackItem.key] as Map?)?['quantity'] = quantity;
//               }
//               (widget.character['backpack'] as LinkedHashMap)['items'] = items;
//               context.read<CharacterBloc>().add(
//                 CharacterUpdate(
//                   character: widget.character,
//                   slug: widget.slug,
//                   persistData: true,
//                   offline: context.read<SettingsCubit>().state.offlineMode,
//                 ),
//               );
//             },
//             isEquipped: backpackItem.value['isEquipped'] as bool? ?? false,
//             onEquip: (itemKey, isEquipped) {
//               items[itemKey]?['isEquipped'] = isEquipped;
//               (widget.character['backpack'] as Map)['items'] = items;
//               context.read<CharacterBloc>().add(
//                 CharacterUpdate(
//                   character: widget.character,
//                   slug: widget.slug,
//                   persistData: true,
//                   offline: context.read<SettingsCubit>().state.offlineMode,
//                 ),
//               );
//             },
//           ),
//         );
//       },
//       separatorBuilder: (context, index) =>
//           const SizedBox(child: Divider(height: 0)),
//     );
//   }
// }
