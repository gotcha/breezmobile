import 'package:auto_size_text/auto_size_text.dart';
import 'package:breez/bloc/account/account_model.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:breez/theme_data.dart' as theme;

class MakeInvoiceRequest extends StatelessWidget {
  final AccountModel account;
  final int amount;
  final String description;

  const MakeInvoiceRequest({Key key, this.amount, this.description, this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Text("This site wants to pay you:", style: theme.paymentRequestSubtitleStyle, textAlign: TextAlign.center),
      Text(account.currency.format(Int64(amount)), style: theme.paymentRequestAmountStyle,textAlign: TextAlign.center)
    ];

    if (description != null && description.isEmpty) {
      children.add(Padding(
        padding: EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
        child: AutoSizeText(
          description,
          style: theme.paymentRequestSubtitleStyle,
          textAlign: description.length > 40 ? TextAlign.justify : TextAlign.center,
          maxLines: 3,
        ),
      ));
    }

    children.add(Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, false),
            child: new Text("CANCEL", style: theme.buttonStyle),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, true),
            child: new Text("APPROVE", style: theme.buttonStyle),
          )
        ],
      ),
    ));

    return Dialog(
        child: Container(            
            width: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(minHeight: 220.0, maxHeight: 320.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: children)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)));
  }
}