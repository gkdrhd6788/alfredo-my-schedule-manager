// ignore_for_file: unused_import

import 'package:alfredo/provider/calendar/icaldata_provider.dart';
import 'package:alfredo/provider/store/store_provider.dart';
import 'package:alfredo/provider/user/user_state_provider.dart';
import 'package:alfredo/screens/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/todo/todo_list.dart'; // TodoList 위젯 import
import '../../provider/attendance/attendance_provider.dart';
import '../../provider/user/future_provider.dart';
import '../../provider/achieve/achieve_provider.dart'; // achieveProvider import
import '../../provider/coin/coin_provider.dart';
import '../achieve/achieve_detail_screen.dart'; // AchieveDetailScreen import
import '../coin/coin_detail_screen.dart'; // CoinDetailScreen import
import '../tts/tts_page.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  void initState() {
    super.initState();
    _checkAttendance();
  }

  Future<void> _checkAttendance() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? lastCheckDate = prefs.getString('lastCheckDate');
    final String todayDate = DateTime.now().toString().substring(0, 10);
    //TODO !=로 변경
    if (lastCheckDate == todayDate) {
      final idToken = await ref.read(authManagerProvider.future);
      try {
        await ref.read(attendanceProvider).checkAttendance(idToken);
        print("여기 실행 중");
        await prefs.setString('lastCheckDate', todayDate);
        List<DateTime> attendanceHistory = await ref
            .read(attendanceProvider)
            .getAttendanceForCurrentWeek(idToken);
        _showAttendanceModal(attendanceHistory);
      } catch (error) {
        print('Failed to check attendance: $error');
      }
    }
  }

  void _showAttendanceModal(List<DateTime> attendanceHistory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D2338), // 배경색 설정
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '이번 주 출석 현황',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.white),
                padding: const EdgeInsets.all(8.0),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(
              maxHeight: 200, // 모달의 최대 높이를 설정
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  child: Row(
                    children: _buildAttendanceList(attendanceHistory),
                  ),
                ),
                // const SizedBox(height: 10),
                // const Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [Text("hi"), Text("hello")],
                // )
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAttendanceList(List<DateTime> attendanceHistory) {
    List<Widget> attendanceWidgets = [];
    Map<int, String> daysOfWeek = {
      DateTime.sunday: "일",
      DateTime.monday: "월",
      DateTime.tuesday: "화",
      DateTime.wednesday: "수",
      DateTime.thursday: "목",
      DateTime.friday: "금",
      DateTime.saturday: "토"
    };

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    for (int i = 0; i < 7; i++) {
      DateTime day = startOfWeek.add(Duration(days: i));
      bool attended = attendanceHistory.any((date) =>
          date.year == day.year &&
          date.month == day.month &&
          date.day == day.day);
      attendanceWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: attended
                    ? const Color(0x00e7d8bc).withOpacity(0.8)
                    : Colors.grey[300],
                child: Text(
                  daysOfWeek[day.weekday]!,
                  style: TextStyle(
                    color: attended
                        ? const Color.fromARGB(0, 211, 193, 159)
                        : const Color.fromARGB(123, 0, 0, 0),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              if (attended)
                Icon(
                  Icons.check,
                  color: Colors.white.withOpacity(1.0),
                  size: 16,
                ),
            ],
          ),
        ),
      );
    }

    return attendanceWidgets;
  }

  @override
  Widget build(BuildContext context) {
    var background = ref.watch(backgroundProvider);
    var character = ref.watch(characterProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 배경 이미지
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(background),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.1,
            left: MediaQuery.of(context).size.height * 0,
            right: MediaQuery.of(context).size.height * 0,
            bottom: MediaQuery.of(context).size.height * 0.1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(character),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image 13.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.05,
            left: MediaQuery.of(context).size.height * 0,
            right: MediaQuery.of(context).size.height * 0,
            bottom: MediaQuery.of(context).size.height * 0.07,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                child: TtsPage(),
              ),
            ),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.48,
            left: MediaQuery.of(context).size.height * 0.01,
            right: MediaQuery.of(context).size.height * 0.01,
            bottom: MediaQuery.of(context).size.height * 0.01,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              // ignore: prefer_const_constructors
              child: SizedBox(
                // width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height,
                child: const TodoList(),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.11,
            left: MediaQuery.of(context).size.height * 0.02,
            right: MediaQuery.of(context).size.height * 0.42,
            child: Column(
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFF0D2338)),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 0))),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return const ShopScreen();
                      },
                    );
                  },
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                ),
                // const SizedBox(height: 10), // 간격을 주기 위해 추가
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const AchieveDetailScreen(),
                //       ),
                //     );
                //   },
                //   child: const Text('Achievements'),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
