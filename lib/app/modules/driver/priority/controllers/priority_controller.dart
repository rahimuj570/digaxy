import 'package:get/get.dart';

class PriorityCriterion {
  final String title;
  final String subtitle;
  final RxBool completed;
  final RxDouble progress; // 0..1

  PriorityCriterion({
    required this.title,
    this.subtitle = '',
    bool completed = false,
    double progress = 0.0,
  }) : completed = completed.obs,
       progress = progress.obs;
}

class PriorityController extends GetxController {
  // Current priority level (1..3)
  final currentLevel = 2.obs;

  // Example criteria - these will be wired later to real data
  final criteria = <PriorityCriterion>[
    PriorityCriterion(
      title: '80+ completed time slots',
      subtitle: '',
      completed: true,
      progress: 1.0,
    ),
    PriorityCriterion(
      title: 'Work 4+ weekend days',
      subtitle: '3 completed',
      completed: false,
      progress: 0.6,
    ),
    PriorityCriterion(
      title: 'Rating 4.89',
      subtitle: '5.00',
      completed: true,
      progress: 1.0,
    ),
    PriorityCriterion(
      title: 'Account age 120 days',
      subtitle: '2408 days',
      completed: true,
      progress: 1.0,
    ),
  ].obs;

  String get currentPriorityLabel => currentLevel.value.toString();

  // Dummy upgrade text
  String get nextUpgrade => 'Priority ${currentLevel.value}';

  // Benefits text
  String get benefits => '+1% extra commission on every delivery';

}
