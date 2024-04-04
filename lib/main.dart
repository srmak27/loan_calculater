import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: SplashScreen(),
    routes: {
      '/input': (context) => InputScreen(),
    },
  ));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      navigateToInputScreen();
    });
  }

  void navigateToInputScreen() {
    Navigator.of(context).pushReplacementNamed('/input');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Loan Calculator',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24,color: Color.fromARGB(255, 3, 73, 213),fontWeight: FontWeight.bold,),
            ),
            Image.asset('asset/images/calculator.jpg'),
          ],
        ),
      ),
    );
  }
}

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final amountController = TextEditingController();
  final termController = TextEditingController();
  final rateController = TextEditingController();

  double monthlyPayment = 0.0;
  int totalPaymentTimes = 0;
  double totalInterest = 0.0;
  double totalPayment = 0.0;

  void clearFields() {
    amountController.clear();
    termController.clear();
    rateController.clear();
    setState(() {
      monthlyPayment = 0.0;
      totalPaymentTimes = 0;
      totalInterest = 0.0;
      totalPayment = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loan Calculator'),
      ),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            buildInputBox('Loan amount:', amountController),
            buildInputBox('Term (years):', termController),
            buildInputBox('Interest rate (%):', rateController),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    clearFields();
                  },
                  child: Text('Clear'),
                ),

                ElevatedButton(
                  onPressed: () {
                    if (amountController.text.isEmpty || termController.text.isEmpty || rateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in all the details')),
                      );
                      clearFields();
                    } else {
                      try {
                        double amount = double.parse(amountController.text);
                        int term = int.parse(termController.text);
                        double rate = double.parse(rateController.text);

                        if (amount <= 0 || term <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Amount and term cannot be zero or negative')),
                          );
                          clearFields();
                        }
                        else if (term <1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Loan term must at least 1 year and above')),
                          );
                          clearFields();
                        }
                        else if (amount >= 100000000) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Loan amount must be less than 100,000,000')),
                          );
                          clearFields();
                        } else if (term >= 100) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Loan term must be less than 100')),
                          );
                          clearFields();
                        }
                        else if (rate > 100) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Interest rate cannot exceed 100')),
                          );
                          clearFields();
                        }
                        else if (rate == 0 && (amount>0 && amount<100000000 && (term>0 && term<100))) {
                          setState(() {
                            monthlyPayment = calculateMonthlyPayment2(amount, term);
                            totalPaymentTimes = term * 12;
                            totalInterest = 0;
                            totalPayment = monthlyPayment * totalPaymentTimes;
                          });
                        }
                        else {
                          setState(() {
                            monthlyPayment = calculateMonthlyPayment(amount, term, rate);
                            totalPaymentTimes = term * 12;
                            totalInterest = (monthlyPayment * totalPaymentTimes) - amount;
                            totalPayment = monthlyPayment * totalPaymentTimes;
                          });
                        }
                      } catch (FormatException) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter a valid digit number')),
                        );
                        clearFields();
                      }
                    }
                  },
                  child: Text('Calculate'),
                ),

              ],
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.0),
              color: Colors.green,
              child: Text(
                'Monthly Payment: RM ${monthlyPayment.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),

            SizedBox(height: 10),

            Text(
              'You will need to pay RM ${monthlyPayment.toStringAsFixed(2)} every month for $totalPaymentTimes months to pay off the debt.',
              style: TextStyle(fontSize: 13),
            ),

            SizedBox(height: 10),

            Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: const Color.fromARGB(255, 201, 193, 193)),
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Total Payment (Times)'),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('${totalPaymentTimes.toStringAsFixed(0)}'),
                      ),
                    ),
                  ],
                ),

                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Total Interest'),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('RM ${totalInterest.toStringAsFixed(2)}'),
                      ),
                    ),
                  ],
                ),

                TableRow(
                  decoration: BoxDecoration(color: const Color.fromARGB(255, 201, 193, 193)),
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Total Payment'),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('RM ${totalPayment.toStringAsFixed(2)}'),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputBox(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(width: 10),

          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  double calculateMonthlyPayment(double amount, int term, double rate) {
    rate = rate / 1200;
    int n = term * 12;
    double monthlyPayment = (amount * rate) / (1 - pow(1 + rate, -n));
    return monthlyPayment;
  }

  double calculateMonthlyPayment2(double amount, int term) {
    int n = term * 12;
    double monthlyPayment = amount / n;
    return monthlyPayment;
  }
}