// user_manual.dart

//an in-app help screen organised as an accordion list.
//each section covers a different part of the app and expands to show step-by-step cards with screenshots.

import 'package:flutter/material.dart';
import '../../designs/themes.dart';

class _StepData {
  final String title;
  final String description;
  final IconData icon;
  final String? imagePath;
  final List<String>? imagePaths;

  const _StepData({
    required this.title,
    required this.description,
    required this.icon,
    this.imagePath,
    this.imagePaths,
  });
}

final navigaton = [
  _StepData(
    title: 'Open the Navigation Menu',
    description:
        'Tap the hamburger icon (☰) in the top-right corner of any screen to open the side navigation menu.',
    icon: Icons.menu_open_rounded,
    imagePath: 'assets/manual/adding/menu-nav.png',
  ),
  _StepData(
    title: 'Go to a Section',
    description:
        'From the menu, tap any section you need:\n\n'
        '• Add: Add new products to your catalog.\n'
        '• Inventory:  View and manage your current stock.\n'
        '• Purchase: Process sales at the point of sale.\n'
        '• History: Review past transactions and reports.\n'
        '• Settings: Adjust your account and app preferences.',
    icon: Icons.grid_view_rounded,
    imagePath: 'assets/manual/inventory/drawer.png',
  ),
];

final addingSteps = [
  _StepData(
    title: 'Go to the Add Screen',
    description:
        'Open the navigation menu and tap "Add". This brings you to the Add Product screen where you can fill in all the product details.',
    icon: Icons.open_in_new_rounded,
    imagePath: 'assets/manual/adding/adding-page.png',
  ),
  _StepData(
    title: 'Add a Product Photo',
    description:
        'Tap the photo box on the left side of the screen to upload an image.\n\n'
        'You can choose from:\n'
        '• Camera: Take a photo on the spot.\n'
        '• Gallery: Pick an existing photo from your device.\n\n'
        'If prompted, tap "While using the app" to allow camera or photo access.',
    icon: Icons.add_photo_alternate_rounded,
    imagePath: 'assets/manual/adding/cam-access.png',
  ),
  _StepData(
    title: 'Enter Product Details',
    description:
        'Fill in the basic information about your product:\n\n'
        '• Product Name: The name of the item.\n'
        '• Description: A short note about the product.\n'
        '• Barcode Number: Type the barcode manually if needed.',
    icon: Icons.edit_note_rounded,
    imagePath: 'assets/manual/adding/name-des-bar.png',
  ),
  _StepData(
    title: 'Scan a Barcode (Optional)',
    description:
        'Instead of typing, tap the barcode scanner icon on the right side of the barcode field.\n\n'
        'Point your camera at the product\'s barcode and hold it steady and the app will automatically fill in the number for you.',
    icon: Icons.qr_code_scanner_rounded,
    imagePath: 'assets/manual/adding/barscan.png',
  ),
  _StepData(
    title: 'Set the Stock Quantity',
    description:
        'In the "No. of Items" field, enter how many units of this product you currently have in stock.',
    icon: Icons.inventory_2_rounded,
    imagePath: 'assets/manual/adding/items-exp.png',
  ),
  _StepData(
    title: 'Set the Expiration Date',
    description:
        'Tap "Select Date" next to the calendar icon to open the date picker.\n\n'
        'Navigate to the correct month and year, tap the exact expiration day, then tap OK to confirm.',
    icon: Icons.calendar_month_rounded,
    imagePath: 'assets/manual/adding/date-pick.png',
  ),
  _StepData(
    title: 'Enter Pricing',
    description:
        'Fill in both price fields:\n\n'
        '• Org. Price: What you paid for the product (your cost).\n'
        '• SRP: The price you sell it to customers.',
    icon: Icons.price_change_rounded,
    imagePaths: [
      'assets/manual/adding/orig-price.png',
      'assets/manual/adding/srp.png',
    ],
  ),
  _StepData(
    title: 'Choose a Category',
    description:
        'Tap the "Select or type a category…" dropdown.\n\n'
        'Pick an existing category (e.g. Drinks, Snacks, Canned Goods), or type a new name to create your own.',
    icon: Icons.label_rounded,
    imagePath: 'assets/manual/adding/save.png',
  ),
  _StepData(
    title: 'Save the Product',
    description:
        'Once everything looks good, tap the blue "+ Add" button at the bottom of the screen. Your product will be saved to the inventory.',
    icon: Icons.check_circle_rounded,
    imagePath: 'assets/manual/adding/save.png',
  ),
];

final inventorySteps = [
  _StepData(
    title: 'Open Inventory',
    description:
        'Tap "Inventory" from the navigation menu. You will see a list of all your products with their stock count and price.',
    icon: Icons.list_alt_rounded,
    imagePath: 'assets/manual/inventory/inventory.png',
  ),
  _StepData(
    title: 'Search for a Product',
    description:
        'Use the search bar at the top to find a product by name or barcode number.\nYou can tap the Barcode Icon element layer layout trigger block shortcut button to initialize background camera lenses scanning engines instantly.',
    icon: Icons.search_rounded,
    imagePath: 'assets/manual/inventory/search.png',
  ),
  _StepData(
    title: 'Sort Inventory',
    description:
        'Tap the sort icon beside the search bar and select how you want to sort your inventory.\n\nIf you go to a different page, the inventory will revert back to how it was originally sorted: By Category',
    icon: Icons.sort,
    imagePath: 'assets/manual/inventory/sort.png',
  ),
  _StepData(
    title: 'View Product Information',
    description:
        'Tap any product in the list to open its details. From there you can view the name, price, stock, type, or expiration date.\n\nYou can tap the "Remove Product" button to delete product',
    icon: Icons.edit_rounded,
    imagePath: 'assets/manual/inventory/view.png',
  ),
  _StepData(
    title: 'Edit a Product',
    description:
        'click the "Edit Button". From there you can update the name, price, stock, type, or expiration date. To save the changes, click the "Save, Changes" button',
    icon: Icons.edit_rounded,
    imagePath: 'assets/manual/inventory/edit.png',
  ),
];

final purchaseSteps = [
  _StepData(
    title: 'Open Purchase Screen',
    description:
        'Tap "Purchase" from the navigation menu to open the point-of-sale screen.',
    icon: Icons.storefront_rounded,
    imagePath: 'assets/manual/purchase/purchase.png',
  ),
  _StepData(
    title: 'Add Items',
    description:
        'To add items:\n\n- Search through the product list\n- Search for the item name or barcode\n\nthen tap it to add it to the selected section.',
    icon: Icons.add_shopping_cart_rounded,
    imagePath: 'assets/manual/purchase/selected.png',
  ),
  _StepData(
    title: 'Set Quantity',
    description:
        'Adjust the quantity for each item in the cart using the + and − buttons before confirming.',
    icon: Icons.exposure_rounded,
    imagePath: 'assets/manual/purchase/quantity.png',
  ),
  _StepData(
    title: 'Confirming Product Checkout',
    description: 'Tap the "Confirm" button to record the transaction',
    icon: Icons.check_circle_outline_rounded,
    imagePath: 'assets/manual/purchase/confirm.png',
  ),
  _StepData(
    title: 'Buyer\'s Information',
    description:
        'This part is optional.\n\nTo record the buyer\'s information, type the customer name and address',
    icon: Icons.info_outline,
    imagePath: 'assets/manual/purchase/buyer.png',
  ),
  _StepData(
    title: 'Checkout Items',
    description:
        'On the "Cash" blank space, type the cash amount given by the customer. It will automatically calculate the change. You can then click the "Checkout" button',
    icon: Icons.monetization_on_outlined,
    imagePath: 'assets/manual/purchase/checkout.png',
  ),
];

final historySteps = [
  _StepData(
    title: 'Open History',
    description:
        'Tap "History" from the navigation menu to see a past transactions.',
    icon: Icons.history_rounded,
    imagePath: 'assets/manual/history/history.png',
  ),
  _StepData(
    title: 'Filter by Date',
    description:
        'Use the date filter at the top to narrow down transactions by a specific day, week, or month.',
    icon: Icons.date_range_rounded,
    imagePath: 'assets/manual/history/date.png',
  ),
  _StepData(
    title: 'View Profit',
    description:
        'You can view your profit for the day, on the fourth card summary.\n\nTap it to see your profit for the week, or month.',
    icon: Icons.date_range_rounded,
    imagePaths: [
      'assets/manual/history/profit.png',
      'assets/manual/history/profit-card.png',
    ],
  ),
  _StepData(
    title: 'View Sales',
    description:
        'You can view your sales for the week or month on the bar chart.\n\nToggle to switch between week sales, or month sales.',
    icon: Icons.date_range_rounded,
    imagePath: 'assets/manual/history/sales.png',
  ),
  _StepData(
    title: 'View a Transaction',
    description:
        'At the transaction list, tap any entry to see the its recorded receipt: items sold, quantities, prices, and total amount.',
    icon: Icons.receipt_long_rounded,
    imagePath: 'assets/manual/history/transaction.png',
  ),
];

final notificationSteps = [
  _StepData(
    title: 'View Notifications',
    description:
        'Tap "Notification" from the navigation menu to see all active alerts for your inventory.\n\nYou will receive a notification when a product\'s stock falls below the 5-units. Restock the item to clear the alert.\n\nProducts nearing or past their expiration date will appear here.',
    icon: Icons.notifications_active_rounded,
    imagePath: 'assets/manual/notification/notification.png',
  ),
];

final settingsSteps = [
  _StepData(
    title: 'Navigating Settings',
    description:
        'Tap "Settings" from the navigation menu to access your account, app display, manual, and logout button.',
    icon: Icons.settings_rounded,
    imagePath: 'assets/manual/setting/settings.png',
  ),
  _StepData(
    title: 'My Account',
    description:
        'View and update your profile information such as your display name, user profile, and password',
    icon: Icons.person_rounded,
    imagePath: 'assets/manual/setting/account.png',
  ),
  _StepData(
    title: 'Display Settings',
    description: 'Switch between Light and Dark mode, and adjust font size',
    icon: Icons.brightness_6_rounded,
    imagePath: 'assets/manual/setting/display.png',
  ),
  _StepData(
    title: 'Logout',
    description:
        'Tap the "Logout" button at the bottom of the Settings page to safely sign out of your account.',
    icon: Icons.logout_rounded,
    imagePath: 'assets/manual/setting/logout.png',
  ),
];

//  MAIN PAGE
class Manual extends StatefulWidget {
  const Manual({super.key});

  @override
  State<Manual> createState() => _ManualState();
}

class _ManualState extends State<Manual> {
  // 0 = Getting Around, 1 = Adding, 2 = Inventory, 3 = Purchase,
  // 4 = History, 5 = Notifications, 6 = Settings,
  int _openIndex = 0; // tracks open index, only one can be open at a time

  void _toggle(int index) {
    setState(() {
      _openIndex = (_openIndex == index) ? -1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('USER MANUAL'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _AccordionSection(
            index: 0,
            openIndex: _openIndex,
            onTap: _toggle,
            icon: Icons.menu_rounded,
            title: 'Getting Around the App',
            steps: navigaton,
          ),
          _AccordionSection(
            index: 1,
            openIndex: _openIndex,
            onTap: _toggle,
            icon: Icons.add_box_rounded,
            title: 'Adding a New Product',
            steps: addingSteps,
            tip: 'You can edit a product later from the Inventory section.',
          ),
          _AccordionSection(
            index: 2,
            openIndex: _openIndex,
            onTap: _toggle,
            icon: Icons.inventory_2_outlined,
            title: 'View & Edit Inventory',
            steps: inventorySteps,
          ),
          _AccordionSection(
            index: 3,
            openIndex: _openIndex,
            onTap: _toggle,
            icon: Icons.add_shopping_cart_outlined,
            title: 'Recording a Purchase',
            steps: purchaseSteps,
            tip:
                'If you want to add more items to the Purchase List, you can just go back to the Purchase screen and select more products. Your current list will be saved until you confirm the transaction.',
          ),
          _AccordionSection(
            index: 4,
            openIndex: _openIndex,
            onTap: _toggle,
            icon: Icons.receipt_rounded,
            title: 'Transaction History',
            steps: historySteps,
          ),
          _AccordionSection(
            index: 5,
            openIndex: _openIndex,
            onTap: _toggle,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            steps: notificationSteps,
          ),
          _AccordionSection(
            index: 6,
            openIndex: _openIndex,
            onTap: _toggle,
            icon: Icons.settings_outlined,
            title: 'Settings',
            steps: settingsSteps,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _AccordionSection extends StatelessWidget {
  final int index;
  final int openIndex;
  final ValueChanged<int> onTap;
  final IconData icon;
  final String title;
  final List<_StepData> steps;
  final String? tip;

  const _AccordionSection({
    required this.index,
    required this.openIndex,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.steps,
    this.tip,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = openIndex == index;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        //Header
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: isOpen
                    ? cs.primary.withOpacity(isDark ? 0.18 : 0.08)
                    : cs.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isOpen
                      ? cs.primary.withOpacity(0.4)
                      : cs.outline.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(isOpen ? 0.18 : 0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      icon,
                      color: isOpen
                          ? cs.primary
                          : (isDark
                                ? AppTheme.darkTextMuted
                                : AppTheme.textMuted),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isOpen
                            ? cs.primary
                            : (isDark
                                  ? AppTheme.darkTextPrimary
                                  : AppTheme.textPrimary),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isOpen ? cs.primary : AppTheme.textMuted,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        //Body
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState: isOpen
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Column(
              children: [
                ...steps.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _StepCard(step: s),
                  ),
                ),
                if (tip != null) ...[
                  const SizedBox(height: 4),
                  _TipCard(tip: tip!),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final _StepData step;

  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<String> allImages = [
      if (step.imagePath != null) step.imagePath!,
      ...?step.imagePaths,
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.outline,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(0.4)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  step.icon,
                  size: 17,
                  color: isDark ? AppTheme.nightBlue : cs.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.65,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (allImages.isNotEmpty) ...[
            Divider(height: 1, color: cs.outline.withOpacity(0.3)),
            allImages.length == 1
                ? _ScreenshotSingle(path: allImages.first)
                : _ScreenshotRow(paths: allImages),
          ],
        ],
      ),
    );
  }
}

class _ScreenshotSingle extends StatelessWidget {
  final String path;
  const _ScreenshotSingle({required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black.withOpacity(0.04),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(path, fit: BoxFit.contain),
      ),
    );
  }
}

class _ScreenshotRow extends StatelessWidget {
  final List<String> paths;
  const _ScreenshotRow({required this.paths});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black.withOpacity(0.04),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: paths
            .map(
              (p) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(p, fit: BoxFit.contain),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.blueLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.borderBlue,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_rounded,
            size: 16,
            color: isDark ? AppTheme.nightBlue : AppTheme.brandBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.6,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textBlueBrand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
