import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase/billing_client_wrappers.dart';

import 'colors.dart';
import 'utilities.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage(this.products);

  final List<ProductDetails> products;

  @override
  State<StatefulWidget> createState() {
    return SubscriptionPageState();
  }
}

class SubscriptionPageState extends State<SubscriptionPage> {
  bool isLoading = false;
  StreamSubscription <List<PurchaseDetails>>subscription;
  void purchaseItem(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    if ((Platform.isIOS && product.skProduct.subscriptionPeriod != null) ||
        (Platform.isAndroid && product.skuDetail.type == SkuType.subs)) {
      InAppPurchaseConnection.instance
          .buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  @override
  void initState() {
    final Stream purchaseUpdates = InAppPurchaseConnection.instance.purchaseUpdatedStream;
    subscription = purchaseUpdates.listen((dynamic data){
      PurchaseDetails details = (data as List<PurchaseDetails>).first;
      if(details.status == PurchaseStatus.purchased){
        if (Platform.isIOS) {
          InAppPurchaseConnection.instance.completePurchase(details);
          showCupertinoDialog<CupertinoAlertDialog>(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text('Done'),
                  content: const Text('Your purchase was successful.'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      isDefaultAction: true,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              });
        }
        else {
          showDialog<AlertDialog>(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: const Text('Some error occurred'),
              content: const Text('Your order could not be completed.'),
              actions: <Widget>[
                FlatButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
        }
      } else if (details.status == PurchaseStatus.error){

        if (Platform.isIOS) {
          InAppPurchaseConnection.instance.completePurchase(details);
          showCupertinoDialog<CupertinoAlertDialog>(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text('Some error occurred'),
                  content: const Text('Verification email could not be sent.'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      isDefaultAction: true,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              });
        }
        else {
          showDialog<AlertDialog>(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: const Text('Some error occurred'),
              content: const Text('Verification email could not be sent.'),
              actions: <Widget>[
                FlatButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
        }
      }

    });
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.theme1['CardColor'],
      body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Container(
              margin: const EdgeInsets.only(top: 20),
              height: MediaQuery.of(context).size.height,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  Container(
                    color: Themes.theme1['CardColor'],
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Card(
                                color: Colors.orange,
                                child: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: widget.products.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListView(
                                        physics: const NeverScrollableScrollPhysics(),

                                        shrinkWrap: true,
                                        children: <Widget>[
                                          Text(
                                            'Basic Plan',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Poppins',
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'This is our standard plan.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Poppins',
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          Container(
                                            height: 100,
                                            width: 100,
                                            child: Center(
                                                child: Container(
                                                    width: 100,
                                                    child: Text(
                                                      widget.products[index]
                                                          .price,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.orange,
                                                        fontFamily: 'Poppins',
                                                        fontSize: 26,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ))),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white),
                                          ),
                                          DataTable(columns: <DataColumn>[
                                            const DataColumn(
                                                label: const Text('')),
                                            const DataColumn(
                                                label: const Text(''))
                                          ], rows: <DataRow>[
                                            DataRow(cells: <DataCell>[
                                              DataCell(Text(
                                                'League Creation',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Poppins',
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                              DataCell(Container(
                                                child: Icon(
                                                  Icons.done,
                                                  color: Colors.white,
                                                ),
                                                color: Colors.green,
                                              )),
                                            ])
                                          ])
                                        ],
                                      );
                                    }))),
                        Container(child:
                        RaisedButton(color: Colors.green,
                          child: Text(
                            'Continue',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),

                          onPressed: () {
                            purchaseItem(widget.products.first);
                          },
                        ),margin: const EdgeInsets.only(left: 40,right: 40),),
                        const SizedBox(height: 20,),
                        Container(child:
                        RaisedButton(color: Colors.red,
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),

                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),margin: const EdgeInsets.only(left: 40,right: 40),)
                      ],
                    ),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                ],
              ))),
    );
  }
}
