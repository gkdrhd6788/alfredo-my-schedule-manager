import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/routine/routine_create_screen.dart';
import '../../screens/schedule/schedule_create_screen.dart';
import '../../screens/routine/routine_list_screen.dart';
import '../../screens/todo/todo_tab_view.dart';

class PlusButton {
  static void showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.white.withOpacity(0.95),
      builder: (BuildContext context) {
        return ProviderScope(
          child: Consumer(builder: (context, ref, child) {
            return Container(
              height: 180,
              margin: const EdgeInsets.only(bottom: 58),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  customListTile(
                      Icons.event_note,
                      '루틴',
                      const Color(0xfff0d2338),
                      context,
                      () => showRoutineCreateModal(context, ref)),
                  customListTile(Icons.schedule, '일정', const Color(0xfff0d2338),
                      context, () => showScheduleCreateModal(context)),
                  customListTile(Icons.check_circle_outline, '할 일',
                      const Color(0xfff0d2338), context, const TodoTabView()),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  static void showScheduleCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return const FractionallySizedBox(
          heightFactor: 0.90,
          child: ScheduleCreateScreen(),
        );
      },
    );
  }

  static Widget customListTile(IconData icon, String text, Color color,
      BuildContext context, dynamic destination) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (destination is Function) {
          destination(); // destination이 함수일 경우 바로 호출
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destination));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Text(text,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          ],
        ),
      ),
    );
  }
}
