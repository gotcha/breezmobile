import 'package:breez/bloc/account/account_bloc.dart';
import 'package:breez/bloc/account/account_model.dart';
import 'package:breez/bloc/blocs_provider.dart';
import 'package:breez/routes/user/get_refund/refund_form.dart';
import 'package:breez/routes/user/get_refund/wait_broadcast_dialog.dart';
import 'package:breez/services/breezlib/data/rpc.pbserver.dart';
import 'package:breez/widgets/loader.dart';
import 'package:breez/widgets/single_button_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:breez/theme_data.dart' as theme;
import 'package:breez/widgets/back_button.dart' as backBtn;

class GetRefundPage extends StatelessWidget {
  static const String TITLE = "Get Refund";

  @override
  Widget build(BuildContext context) {
    AccountBloc accountBloc = AppBlocsProvider.of<AccountBloc>(context);
    return new Scaffold(
      appBar: new AppBar(
          iconTheme: theme.appBarIconTheme,
          textTheme: theme.appBarTextTheme,
          backgroundColor: theme.BreezColors.blue[500],
          leading: backBtn.BackButton(),
          title: new Text(TITLE, style: theme.appBarTextStyle),
          elevation: 0.0),
      body: StreamBuilder<AccountModel>(
        stream: accountBloc.accountStream,
        builder: (context, accSnapshot) {
              if (!accSnapshot.hasData || !accSnapshot.hasData) {
                return Loader();
              }
              if (accSnapshot.hasError) {
                return Text(accSnapshot.error.toString());
              }
              var account = accSnapshot.data;             
              return ListView(
                  children: account.swapFundsStatus.maturedRefundableAddresses.map((item) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(flex: 5, child: Text(item.address)),
                        Expanded(
                            flex: 3,
                            child: Text(
                                account.currency.format(item.confirmedAmount),
                                textAlign: TextAlign.right))
                      ],
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                                height: 36.0,
                                width: 145.0,
                                child: SubmitButton(
                                    item.lastRefundTxID.isNotEmpty ? "BROADCASTED" : "REFUND",
                                    item.lastRefundTxID.isNotEmpty
                                        ? null
                                        : () => onRefund(context, item))),
                          )
                        ]),
                    new Divider(
                        height: 0.0,
                        color: Color.fromRGBO(255, 255, 255, 0.52))
                  ]),
                );
              }).toList());
            })
    );
  }

  onRefund(BuildContext context, RefundableAddress item) {    
    showDialog(
        context: context,
        builder: (ctx) => RefundForm((address) {
          Navigator.of(context).pop();        
          broadcastAndWait(context, item.address, address);
        }));
  }

  broadcastAndWait(BuildContext context, String fromAddress, toAddress){
    AccountBloc accountBloc = AppBlocsProvider.of<AccountBloc>(context);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WaitBroadcastDialog(accountBloc, fromAddress, toAddress));
  }
}
