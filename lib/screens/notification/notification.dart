import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';
import '../../designs/appbar.dart';
import '../../providers/display_provider.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(displaySettingsProvider);
    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBarDesign(page: 'Notification'),
        endDrawer: const AppDrawer(page: '/notification'),
        body: Column(
          children: [
            Material(
              color: cs.secondaryContainer,
              child: TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      'Today',
                      style: TextStyle(color: cs.surfaceVariant),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'All',
                      style: TextStyle(color: cs.surfaceVariant),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Exprired Products',
                      style: TextStyle(color: cs.surfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView.builder(
                    itemBuilder: (context, index) {
                      return TodayNotif();
                    },
                  ),
                  ListView.builder(
                    itemBuilder: (context, index) {
                      return ThisWeek();
                    },
                  ),
                  ListView.builder(
                    itemBuilder: (context, index) {
                      return Expired();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodayNotif extends StatelessWidget {
  const TodayNotif({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            ListTile(
              title: Row(
                children: [
                  Text(
                    'Name',
                    style: TextStyle(
                      color: cs.secondaryContainer,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '17 quantities are about to expire in',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w100,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '07/22/2026',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight(700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThisWeek extends StatelessWidget {
  const ThisWeek({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(child: Text('This week'));
  }
}

class Expired extends StatelessWidget {
  const Expired({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(child: Text('Expired'));
  }
}
