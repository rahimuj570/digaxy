import 'package:get/get.dart';

class HelperPriorityCriterion {
  final String title;
  final String subtitle;
  final RxBool completed;
  final RxDouble progress; // 0..1

  HelperPriorityCriterion({
    required this.title,
    this.subtitle = '',
    bool completed = false,
    double progress = 0.0,
  }) : completed = completed.obs,
       progress = progress.obs;
}

class HelperPriorityController extends GetxController {
  final currentLevel = 2.obs;

  final criteria = <HelperPriorityCriterion>[
    HelperPriorityCriterion(
      title: '80+ completed time slots',
      completed: true,
      progress: 1.0,
    ),
    HelperPriorityCriterion(
      title: 'Work 4+ weekend days',
      subtitle: '3 completed',
      completed: false,
      progress: 0.6,
    ),
    HelperPriorityCriterion(
      title: 'Rating 4.89',
      subtitle: '5.00',
      completed: true,
      progress: 1.0,
    ),
    HelperPriorityCriterion(
      title: 'Account age 120 days',
      subtitle: '2408 days',
      completed: true,
      progress: 1.0,
    ),
  ].obs;

  String get currentPriorityLabel => currentLevel.value.toString();
  String get nextUpgrade => 'Priority ${currentLevel.value}';
  String get benefits => '+1% extra commission on every delivery';

}
