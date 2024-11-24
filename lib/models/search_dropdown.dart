import 'package:bibliora/models/book.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class SearchDropdown extends StatelessWidget {
  final List<String> Function(String filter) filterItems;
  final void Function(String item) onItemSelected;
  final Color fillColor;
  final String? selectedItem;
  final String hintText;
  final List<Book> books = [];

  SearchDropdown({
    super.key,
    required this.filterItems,
    required this.onItemSelected,
    required this.selectedItem,
    required this.fillColor,
    this.hintText = 'Search for a book...',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: DropdownSearch<String>(
        selectedItem: selectedItem,
        onChanged: (selectedValue) {
          if (selectedValue != null) {
            onItemSelected(selectedValue);
          }
        },
        dropdownBuilder: (context, selectedItem) {
          return Text(
            selectedItem ?? "",
            style: const TextStyle(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          );
        },
        items: (filter, infiniteScrollProps) => filterItems(filter),
        filterFn: (item, search) =>
            item.toLowerCase().contains(search.toLowerCase()),
        suffixProps: DropdownSuffixProps(
          dropdownButtonProps: DropdownButtonProps(
            iconClosed:
                const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            iconOpened:
                const Icon(Icons.keyboard_arrow_up, color: Colors.white),
          ),
        ),
        decoratorProps: DropDownDecoratorProps(
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        popupProps: PopupProps.menu(
          searchDelay: const Duration(microseconds: 200),
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(fontSize: 18, color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
              filled: true,
              fillColor: Colors.white24,
              prefixIcon: const Icon(Icons.search, color: Colors.black),
            ),
            cursorColor: Colors.white24,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          itemBuilder: (context, item, isDisabled, isSelected) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                item,
                style: const TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          },
          constraints: const BoxConstraints(maxHeight: 250),
          menuProps: const MenuProps(
            backgroundColor: Color(0xFF4c4d4d),
            margin: EdgeInsets.only(top: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          scrollbarProps: const ScrollbarProps(trackVisibility: true),
        ),
      ),
    );
  }
}
