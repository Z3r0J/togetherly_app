import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/counter_view_model.dart';

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CounterViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Togetherly — MVVM Sample'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: vm.isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Bienvenido a Togetherly App (MVVM)'),
                  const SizedBox(height: 12),
                  Text(
                    '${vm.value}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: vm.reset,
                    child: const Text('Reset'),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: vm.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
