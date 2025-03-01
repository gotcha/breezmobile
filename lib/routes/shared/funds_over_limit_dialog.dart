import 'package:breez/bloc/account/account_actions.dart';
import 'package:breez/bloc/account/account_bloc.dart';
import 'package:breez/bloc/account/account_model.dart';
import 'package:breez/widgets/loader.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:breez/theme_data.dart' as theme;

class SwapRefundDialog extends StatefulWidget {
  final AccountBloc accountBloc;

  const SwapRefundDialog({Key key, this.accountBloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SwapRefundDialogState();
  }
}

class SwapRefundDialogState extends State<SwapRefundDialog> {
  Future _fetchFuture;

  @override
  void initState() {
    super.initState();
    var fetchAction = FetchSwapFundStatus();
    _fetchFuture = fetchAction.future;
    widget.accountBloc.userActionsSink.add(fetchAction);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        titlePadding: EdgeInsets.fromLTRB(24.0, 22.0, 0.0, 16.0),
        title: new Text(
          "On-chain Transaction",
          style: theme.alertTitleStyle,
        ),
        contentPadding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
        content: FutureBuilder(
            future: this._fetchFuture,
            initialData: "loading",
            builder: (ctx, loadingSnapshot) {
              if (loadingSnapshot.data == "loading") {
                return Loader();
              }

              return StreamBuilder<AccountModel>(
                  stream: widget.accountBloc.accountStream,
                  builder: (ctx, snapshot) {
                    var swapStatus = snapshot?.data?.swapFundsStatus;
                    if (swapStatus == null) {
                      return Loader();
                    }
                    
                    String reason = "";                    
                    RefundableAddress swapAddress = swapStatus.refundableAddresses[0];
                    int lockHeight = swapAddress.lockHeight;
                    double hoursToUnlock = swapAddress.hoursToUnlock;
                    if (swapAddress.refundableError != null) {                      
                      reason = "since " + swapAddress.refundableError;
                    }

                    int roundedHoursToUnlock = hoursToUnlock.round();
                    String hoursToUnlockStr = roundedHoursToUnlock > 1
                        ? "~${roundedHoursToUnlock.toString()} hours"
                        : "in about an hour";
                    List<TextSpan> redeemText = List<TextSpan>();
                    if (hoursToUnlock > 0) {
                      redeemText.add(TextSpan(
                          text:
                              "You will be able to redeem your funds after block $lockHeight ($hoursToUnlockStr).",
                          style: theme.dialogGrayStyle));
                    } else {
                      redeemText.addAll([
                        TextSpan(
                            text: "You can ", style: theme.dialogGrayStyle),
                        TextSpan(
                            text: "get a refund ",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, "/get_refund");
                              },
                            style: theme.blueLinkStyle),
                        TextSpan(text: "now.", style: theme.dialogGrayStyle),
                      ]);
                    }

                    return RichText(
                        text: TextSpan(
                            style: theme.dialogGrayStyle,
                            text:
                                "Breez was not able to transfer the funds to your balance $reason\n",
                            children: redeemText));
                  });              
            }),
        actions: [
          new SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: new Text("OK", style: theme.buttonStyle),
          )
        ],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),);
  }
}
