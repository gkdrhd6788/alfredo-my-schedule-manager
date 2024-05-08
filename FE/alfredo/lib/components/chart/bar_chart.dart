import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/user/chart_api.dart';

class BarChartContent extends ConsumerWidget {
  const BarChartContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<BarChartGroupData>>(
      future: ChartApi.fetchChartData(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return BarChart(BarChartData(
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('일');
                        case 1:
                          return const Text('월');
                        case 2:
                          return const Text('화');
                        case 3:
                          return const Text('수');
                        case 4:
                          return const Text('목');
                        case 5:
                          return const Text('금');
                        case 6:
                          return const Text('토');
                        default:
                          return const Text('');
                      }
                    },
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() == 0) return const Text('');
                      return Text(value.toInt().toString());
                    },
                    interval: 5,
                    reservedSize: 20, // 이 값을 조정하여 왼쪽 타이틀과 차트 사이의 거리를 조절합니다.
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.white, width: 0.5)),
              alignment: BarChartAlignment.spaceEvenly,
              maxY: 15,
              barGroups: snapshot.data!,
            ));
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
