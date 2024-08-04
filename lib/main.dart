import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var pA = ref.watch(pAProvider);
    var pB = ref.watch(pBProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < 10; i++) {
        print(
            "pA[$i]:  ${pA[i].id}   ${pA[i].h}  **********  pB[$i]:  ${pB[i].id}   ${pB[i].h}");
      }
    });

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: TextButton(
            child: const Text('Hello World!'),
            onPressed: () {
              ref.read(pAProvider.notifier).updateH(0, 1500);
              print("p1:    ${ref.read(pAProvider)[0].h}");
              ref.read(pBProvider.notifier).updateH(0, -800);
              print("p2:    ${ref.read(pBProvider)[0].h}");
              for (int i = 0; i < 10; i++) {
                print(
                    "pA[$i]:  ${pA[i].id}   ${pA[i].h}  **********  pB[$i]:  ${pB[i].id}   ${pB[i].h}");
              }
            },
          ),
        ),
      ),
    );
  }
}

class BugModel {
  const BugModel({
    this.id = 0,
    this.h,
  });

  final int id;
  final double? h;

  BugModel copyWith({
    int? id,
    double? h,
  }) {
    return BugModel(
      id: id ?? this.id,
      h: h ?? this.h,
    );
  }
}

class BugModelNotifier extends Notifier<List<BugModel>> {
  BugModelNotifier(this.collection);

  Collection collection = Collection.a;
  @override
  build() {
    List<BugModel> bugModels;
    switch (collection) {
      case Collection.a:
        bugModels = bugModelsA;
        break;

      case Collection.b:
        bugModels = bugModelsB;
        break;
    }
    return bugModels;
  }

  void updateH(int id, double? newValue) {
    state = [
      for (final bugModel in state)
        if (bugModel.id == id)
          bugModel.copyWith(id: id, h: newValue)
        else
          bugModel,
    ];
    print("expected $newValue  ===>>  ${state[id].h}");
  }
}

List<BugModel> bugModelsA = List.generate(10, (i) => BugModel(id: i, h: 0.0));
List<BugModel> bugModelsB = List.generate(10, (i) => BugModel(id: i, h: 100.0));

final pAProvider = NotifierProvider<BugModelNotifier, List<BugModel>>(
    () => BugModelNotifier(Collection.a));
final pBProvider = NotifierProvider<BugModelNotifier, List<BugModel>>(
    () => BugModelNotifier(Collection.b));

enum Collection { a, b }
