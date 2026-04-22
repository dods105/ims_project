import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/themes.dart';
import '../../providers/auth_provider.dart';

class Display extends ConsumerStatefulWidget {
  const Display({super.key});

  @override
  ConsumerState<Display> createState() => _Display();
}

class _Display extends ConsumerState<Display> {
  @override
  Widget build(BuildContext context) {
    ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Display")),
      body: Container(
        //dark mode / light mode toggle

        //font size (slider: small, medium(default), large)

        //font style
      ),
    );
  }
}
