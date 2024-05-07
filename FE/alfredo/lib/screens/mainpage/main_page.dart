import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/todo/todo_list.dart'; // TodoList 위젯 import
import '../calendar/calendar.dart';
import '../routine/routine_list_screen.dart';
import '../schedule/schedule_list_screen.dart';
import '../todo/todo_tab_view.dart'; // TodoCreateScreen import
import '../user/mypage.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                print("Logged out"); // 정상적으로 로그아웃
                Navigator.pushReplacementNamed(context, '/'); // 로그인 페이지로 리디렉션
              } catch (e) {
                print("Logout failed: $e");
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const RoutineListScreen()), // RoutineListScreen으로 이동
                  // const RoutineCreateScreen()),
                );
              },
              child: const Text('Routines'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyPage()),
                );
              },
              child: const Text('Go to My Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ScheduleListScreen()),
                );
              },
              child: const Text('Schedules'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalendarScreen()),
                );
              },
              child: const Text('Calendar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const TodoTabView()), // TodoTabView로 이동
                );
              },
              child: const Text('Create Todo'),
            ),
            const Expanded(
              child: TodoList(), // TodoList를 화면 하단에 표시
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) =>
            //               const TodoCreateScreen()), // TodoCreateScreen으로 이동
            //     );
            //   },
            //   child: const Text('Create Todo'),
            // ),
          ],
        ),
      ),
    );
  }
}
