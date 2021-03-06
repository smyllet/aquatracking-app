import 'package:aquatracking/blocs/measurements_bloc.dart';
import 'package:aquatracking/model/aquarium_model.dart';
import 'package:aquatracking/model/measurement_model.dart';
import 'package:aquatracking/model/measurement_type_model.dart';
import 'package:aquatracking/utils/date_tools.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineMetricChart extends StatelessWidget {
  final AquariumModel aquarium;
  final MeasurementTypeModel measurementType;
  final int defaultFetchMode;
  const LineMetricChart({Key? key, required this.aquarium, required this.measurementType, this.defaultFetchMode = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int fetchMode = defaultFetchMode;
    final measurementsBloc = MeasurementsBloc(aquarium: aquarium, measurementType: measurementType);
    measurementsBloc.fetchMeasurements(fetchMode);

    return StreamBuilder<List<MeasurementModel>>(
      stream: measurementsBloc.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          List<MeasurementModel> measurements = [];

          int measurementNeeded = 70;
          if(snapshot.data!.length > measurementNeeded) {
            int indexSelector = snapshot.data!.length~/measurementNeeded;
            for(int i = 0; i < snapshot.data!.length; i++) {
              if(i%indexSelector == 0 || i == snapshot.data!.length - 1) {
                measurements.add(snapshot.data![i]);
              }
            }
          } else {
            measurements = snapshot.data!;
          }

          DateTime endDate = DateTime.now();
          DateTime startDate = endDate.subtract((fetchMode == 0) ? const Duration(hours: 6) : (fetchMode == 1) ? const Duration(days: 1) : (fetchMode == 2) ? const Duration(days: 7) : (fetchMode == 3) ? const Duration(days: 30) : const Duration(days: 365));
          double nbMinutes = double.parse(endDate.difference(startDate).inMinutes.toString());

          if(measurements.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      measurementType.name,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).highlightColor
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        measurementsBloc.fetchMeasurements(fetchMode);
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      splashRadius: 16,
                      iconSize: 16,
                    )
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 180,
                  padding: const EdgeInsets.only(right: 20, top: 10),
                  child: LineChart(
                    LineChartData(
                        maxX: nbMinutes,
                        minX: 0,
                        minY: 0,
                        maxY: 1,
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              interval: 0.2,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(1),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: (nbMinutes~/4).toDouble(),
                              getTitlesWidget: (value, meta) {
                                DateTime date = endDate.subtract(Duration(minutes: (nbMinutes - value).toInt()));

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: (fetchMode == 0 || fetchMode == 1) ? Text(
                                    DateTools.convertDateToShortTimeString(date),
                                  ) : Text(
                                    DateTools.convertDateToShortDateString(date),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          verticalInterval: (nbMinutes~/4).toDouble(),
                          horizontalInterval: 0.2,
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.blueGrey,
                            width: 0.2,
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                              isCurved: true,
                              dotData: FlDotData(
                                show: measurements.length < 25,
                              ),
                              spots: [
                                for(MeasurementModel measurement in measurements)
                                  FlSpot(
                                    nbMinutes - endDate.difference(measurement.measuredAt).inMinutes.toDouble(),
                                    measurement.value,
                                  ),
                              ]
                          )
                        ]
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Derni??re',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '--${measurementType.unit.isNotEmpty ? ' ${measurementType.unit}' : ''}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).highlightColor
                                  ),
                                ),
                              ]
                          ),
                          const Padding(padding: EdgeInsets.only(top: 5)),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Minimum',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '--${measurementType.unit.isNotEmpty ? ' ${measurementType.unit}' : ''}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).highlightColor
                                  ),
                                ),
                              ]
                          ),
                        ],
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(right: 10)),
                    Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Moyenne',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '--${measurementType.unit.isNotEmpty ? ' ${measurementType.unit}' : ''}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).highlightColor
                                  ),
                                ),
                              ]
                          ),
                          const Padding(padding: EdgeInsets.only(top: 5)),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Maximum',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '--${measurementType.unit.isNotEmpty ? ' ${measurementType.unit}' : ''}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).highlightColor
                                  ),
                                ),
                              ]
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            );
          }


          measurements.sort((a, b) => a.value.compareTo(b.value));
          double minValue = measurements.first.value;
          double maxValue = measurements.last.value;
          measurements.sort((a, b) => a.measuredAt.compareTo(b.measuredAt));


          double valueDifference = maxValue - minValue;
          double valueInterval;
          double valueMaxInterval;
          double valueMinInterval;

          if(valueDifference <= 0.5) {
            valueInterval = 0.1;
          } else if(valueDifference <= 1) {
            valueInterval = 0.2;
          } else if(valueDifference <= 5) {
            valueInterval = 0.5;
          } else if(valueDifference <= 100) {
            valueInterval = double.parse((valueDifference / 10).toStringAsFixed(0));
          } else {
            valueInterval =  50;
          }

          valueMinInterval = (minValue / valueInterval).floor() * valueInterval;
          valueMaxInterval = (maxValue / valueInterval).ceil() * valueInterval;

          if(valueDifference == 0.0) valueMaxInterval = valueMaxInterval + valueInterval;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    measurementType.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).highlightColor
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      fetchMode = 4;
                      measurementsBloc.fetchMeasurements(fetchMode);
                    },
                    style: TextButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(30, 30),
                    ),
                    child: Text(
                      '1a',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: (fetchMode == 4) ? Theme.of(context).highlightColor : Theme.of(context).primaryColor
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      fetchMode = 3;
                      measurementsBloc.fetchMeasurements(fetchMode);
                    },
                    style: TextButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(30, 30),
                    ),
                    child: Text(
                      '30j',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: (fetchMode == 3) ? Theme.of(context).highlightColor : Theme.of(context).primaryColor
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      fetchMode = 2;
                      measurementsBloc.fetchMeasurements(fetchMode);
                    },
                    style: TextButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(30, 30),
                    ),
                    child: Text(
                      '7j',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: (fetchMode == 2) ? Theme.of(context).highlightColor : Theme.of(context).primaryColor
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      fetchMode = 1;
                      measurementsBloc.fetchMeasurements(fetchMode);
                    },
                    style: TextButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(30, 30),
                    ),
                    child: Text(
                      '24h',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                          color: (fetchMode == 1) ? Theme.of(context).highlightColor : Theme.of(context).primaryColor
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      fetchMode = 0;
                      measurementsBloc.fetchMeasurements(fetchMode);
                    },
                    style: TextButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(30, 30),
                    ),
                    child: Text(
                      '6h',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: (fetchMode == 0) ? Theme.of(context).highlightColor : Theme.of(context).primaryColor
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      measurementsBloc.fetchMeasurements(fetchMode);
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    splashRadius: 16,
                    iconSize: 16,
                  )
                ],
              ),
              Container(
                width: double.infinity,
                height: 180,
                padding: const EdgeInsets.only(right: 20, top: 10),
                child: LineChart(
                  LineChartData(
                      maxX: nbMinutes,
                      minX: 0,
                      minY: valueMinInterval,
                      maxY: valueMaxInterval,
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.transparent,
                          tooltipRoundedRadius: 0,
                          getTooltipItems: (List<LineBarSpot> spots) {
                              return spots.map((barSpot) {
                                DateTime date = endDate.subtract(Duration(minutes: (nbMinutes - barSpot.x).toInt()));

                                return LineTooltipItem(
                                  '${barSpot.y.toStringAsFixed(2)}${measurementType.unit.isNotEmpty ? ' ${measurementType.unit}' : ''} - ${DateTools.convertDateToLongDateAndTimeString(date)}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                );
                              }).toList();
                          }
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                            interval: valueInterval,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(1),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: (nbMinutes~/4).toDouble(),
                            getTitlesWidget: (value, meta) {
                              DateTime date = endDate.subtract(Duration(minutes: (nbMinutes - value).toInt()));

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: (fetchMode == 0 || fetchMode == 1) ? Text(
                                  DateTools.convertDateToShortTimeString(date),
                                ) : Text(
                                  DateTools.convertDateToShortDateString(date),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        verticalInterval: (nbMinutes~/4).toDouble(),
                        horizontalInterval: valueInterval,
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Colors.blueGrey,
                          width: 0.2,
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                            isCurved: true,
                            dotData: FlDotData(
                              show: measurements.length < 25,
                            ),
                            spots: [
                              for(MeasurementModel measurement in measurements)
                                FlSpot(
                                  nbMinutes - endDate.difference(measurement.measuredAt).inMinutes.toDouble(),
                                  measurement.value,
                                ),
                            ]
                        )
                      ]
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 15)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Derni??re',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${measurements.last.value.toStringAsFixed(2)}${measurementType.unit.isNotEmpty ? ' ${measurementType.unit}' : ''}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).highlightColor
                                ),
                              ),
                            ]
                        ),
                        const Padding(padding: EdgeInsets.only(top: 5)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Minimum',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${(minValue).toStringAsFixed(2)}${measurementType.unit.isNotEmpty ? ' ${measurementType.unit}' : ''}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).highlightColor
                                ),
                              ),
                            ]
                        ),
                      ],
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(right: 10)),
                  Flexible(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Moyenne',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${(measurements.map((m) => m.value).reduce((a, b) => a + b) / measurements.length).toStringAsFixed(2)}${measurementType.unit.isNotEmpty ? ' ${measurementType.unit}' : ''}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).highlightColor
                                ),
                              ),
                            ]
                        ),
                        const Padding(padding: EdgeInsets.only(top: 5)),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Maximum',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${(maxValue).toStringAsFixed(2)}${measurementType.unit.isNotEmpty ? ' ${measurementType.unit}' : ''}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).highlightColor
                                ),
                              ),
                            ]
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }
    );
  }
}
