import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';

class UserData {
  late BigInt score;
  late List<BigInt> levelsUpgrades;

  UserData(this.score, this.levelsUpgrades);

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'levelUpgrades': levelsUpgrades,
    };
  }

  factory  UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      json['score'],
      json['levelsUpgrades'],
    );
  }
}

int clickPower = 1;
BigInt income = BigInt.from(0);
var score = BigInt.from(0.9999);

const int durationTimer = 1;

List<ImprovementWidget> improvements = [
  ImprovementWidget(
    iconPath: "assets/svg/click_upgrade_icon.svg",
    name: 'Доход за клик',
    price: BigInt.from(10),
    function: _upgradePower,
  ),
  ImprovementWidget(
    iconPath: "assets/svg/timer_upgrade_icon.svg",
    name: 'Пассивный доход',
    price: BigInt.from(20),
    function: _upgradeTimer,
  ),
];

void main() {
  runApp(const MainApp());
  Timer.periodic(Duration(seconds: durationTimer), (timer) {
    score += income;
  });
}

void _upgradeTimer() {
   if (improvements[1].level == BigInt.from(0)) {
     income += BigInt.from(1);
   }

   else {
     income *= BigInt.from(2);
   }
}

void _upgradePower() {
  clickPower *= 2;
}

String _formatMoney(BigInt amount) {
  if (amount >= BigInt.from(1.0e21)) {
    return '${(amount / BigInt.from(1.0e21)).toStringAsFixed(1)}Sx';
  } else if (amount >= BigInt.from(1.0e18)) {
    return '${(amount / BigInt.from(1.0e18)).toStringAsFixed(1)}Qi';
  } else if (amount >= BigInt.from(1.0e15)) {
    return '${(amount / BigInt.from(1.0e15)).toStringAsFixed(1)}Qa';
  } else if (amount >= BigInt.from(1.0e12)) {
    return '${(amount / BigInt.from(1.0e12)).toStringAsFixed(1)}T';
  } else if (amount >= BigInt.from(1.0e9)) {
    return '${(amount / BigInt.from(1.0e9)).toStringAsFixed(1)}B';
  } else if (amount >= BigInt.from(1.0e6)) {
    return '${(amount / BigInt.from(1.0e6)).toStringAsFixed(1)}M';
  } else if (amount >= BigInt.from(1.0e3)) {
    return '${(amount / BigInt.from(1.0e3)).toStringAsFixed(1)}K';
  } else {
    return amount.toString();
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutte',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: MyHomePage(title: 'Siphoin Clicker App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  final score = 0;
  final String title;



  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   late Timer _timer;
  void _incrementCounter() {
    setState(() {
    score += BigInt.from(clickPower);
    });
  }

   void _openUpgrades() {
    setState(() {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  UpgradesWidget()));
    });
   }
   @override
   void initState() {
     super.initState();

     _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
       setState(() {
       });
     });
   }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            SvgPicture.asset(
              'assets/svg/money_icon.svg',
              width: 64,
              height: 64,
            ),
            const SizedBox(width: 16),
            Text(
              _formatMoney(score),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 70),
            ),


          ],

        ),


      ),
      floatingActionButton: Stack(

        children: <Widget>[
          Positioned(
            bottom: 16.0,
            right: 4.0,
            child: FloatingActionButton(
              heroTag: 'first_button',
              onPressed: _openUpgrades,
              tooltip: 'Increment',
              child: const Icon(Icons.arrow_circle_up),
            ),
          ),
          Positioned(

            bottom: 16.0,
            left: 30.0,
            child: FloatingActionButton(
              heroTag: 'second_button',
              onPressed: _incrementCounter,
              tooltip: 'Second Button',
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),



    );
  }
}

class ImprovementWidget extends StatefulWidget {
  BigInt level = BigInt.from(0);
  String iconPath;
  String name;
  BigInt price;
  void Function() function;

  ImprovementWidget({super.key,
    required this.iconPath,
    required this.name,
    required this.price,
    required this.function,
  });

  @override
  State<ImprovementWidget> createState() => _ImprovementWidgetState();
}

class _ImprovementWidgetState extends State<ImprovementWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(
        widget.iconPath,
        width: 40,
        height: 40,
      ),
      title: Text('${widget.name} Уровень ${widget.level}'),
      subtitle: Text('Цена: ${_formatMoney(widget.price)}'),

      trailing: ElevatedButton(
        onPressed: _upgrade,
        child: Text('Улучшить'),
      ),
    );
  }

  void _upgrade() {
    setState(() {
      if (score >= widget.price) {
        score -= widget.price;
        widget.function();
        widget.price *= BigInt.from(2);
        widget.level += BigInt.from(1);
      }
    });
  }
}


class UpgradesWidget extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Улучшения"),

      ),
      body: Center(
        child: ListView.separated(
          itemCount: improvements.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            return improvements[index];
          },
        ),
      ),
    );
  }

}
