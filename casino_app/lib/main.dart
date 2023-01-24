import 'package:casino_app/distribution_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scidart/numdart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casino Simulation',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Array _casinoCapital, _casinoEarnings, _playerEarnings;

  double _alpha = 0.8;
  double _y0 = 1000;
  int _duration = 1000;
  DistributionType _distributionType = DistributionType.exp1;

  late final TextEditingController _alphaController =
      TextEditingController(text: _alpha.toString());
  late final TextEditingController _y0Controller = TextEditingController(text: _y0.toString());
  late final TextEditingController _durationController =
      TextEditingController(text: _duration.toString());

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _alpha = 1.8;
      _y0 = 100;
      _duration = 100;
    }

    _simulate();
  }

  @override
  void dispose() {
    super.dispose();
    _alphaController.dispose();
    _y0Controller.dispose();
    _durationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Casino Simulation'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _simulate();
              });
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Alpha',
                    ),
                    controller: _alphaController,
                    onChanged: (value) {
                      if (double.tryParse(value) != null) {
                        setState(() {
                          _alpha = double.parse(value);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Y0',
                    ),
                    controller: _y0Controller,
                    onChanged: (value) {
                      if (double.tryParse(value) != null) {
                        setState(() {
                          _y0 = double.parse(value);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Durée de simulation',
                    ),
                    controller: _durationController,
                    onChanged: (value) {
                      if (int.tryParse(value) != null) {
                        setState(() {
                          _duration = int.parse(value);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Distribution des gains des joueurs'),
                  DropdownButton<DistributionType>(
                    items: DistributionType.values
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.name),
                            ))
                        .toList(),
                    value: _distributionType,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        _distributionType = value!;
                      });
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _simulate();
                        });
                      },
                      child: const Text('Simuler'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: SfCartesianChart(
              primaryXAxis: NumericAxis(),
              primaryYAxis: NumericAxis(),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
              ),
              series: <ChartSeries<double, double>>[
                LineSeries<double, double>(
                  // Bind data source
                  dataSource: _casinoCapital.toList(),
                  xValueMapper: (double value, index) => index.toDouble(),
                  yValueMapper: (double value, _) => value,
                  legendItemText: 'Capital du casino',
                ),
                LineSeries<double, double>(
                  // Bind data source
                  dataSource: _casinoEarnings.toList(),
                  xValueMapper: (double value, index) => index.toDouble(),
                  yValueMapper: (double value, _) => value,
                  legendItemText: 'Rentrées du casino',
                ),
                LineSeries<double, double>(
                  // Bind data source
                  dataSource: _playerEarnings.toList(),
                  xValueMapper: (double value, index) => index.toDouble(),
                  yValueMapper: (double value, _) => value,
                  legendItemText: 'Gains des joueurs',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _simulate() {
    var jumpDelays = randomArray(_duration);
    jumpDelays = arrayMultiplyToScalar(arrayLog(jumpDelays), -1);

    //Calcule les instants de saut (Ti)
    var jumpTimes = arrayCumSum(jumpDelays);
    jumpTimes.insert(0, 0);

    // Génére la série de gains des joueurs (Xi) selon une loi exponentielle de paramètre 1
    var gains = _distributionType.simulate(_duration);

    // Calcules le nombre de joueurs ayant eu un gain avant chaque instant de temps t
    var nSerie = zeros(_duration + 1);
    for (var t = 0; t < _duration + 1; t++) {
      nSerie[t] = arrayArgMax(Array(jumpTimes.where((e) => e <= t).toList())).toDouble();
    }

    // Calculer les rentrées d'argent du casino
    _casinoEarnings = arrayMultiplyToScalar(createArrayRange(stop: _duration + 1), _alpha);

    // Compute player earnings
    _playerEarnings = zeros(_duration + 1);
    for (var t = 0; t < _duration + 1; t++) {
      _playerEarnings[t] = arraySum(gains.getRangeArray(0, nSerie[t].toInt()));
    }

    // Calculer le capital du casino à chaque instant de temps t
    _casinoCapital = arrayAddToScalar(_casinoEarnings, _y0) - _playerEarnings;
  }
}
