import 'package:flutter/material.dart';
import 'package:breez/bloc/blocs_provider.dart';
import 'package:breez/bloc/marketplace/marketplace_bloc.dart';
import 'package:breez/bloc/marketplace/vendor_model.dart';
import 'package:breez/routes/user/marketplace/vendor_row.dart';
import 'package:breez/widgets/back_button.dart' as backBtn;
import 'package:breez/theme_data.dart' as theme;
import 'package:breez/bloc/account/account_bloc.dart';

class MarketplacePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MarketplacePageState();
  }
}

class MarketplacePageState extends State<MarketplacePage> {
  final String _title = "Marketplace";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  AccountBloc _accountBloc;
  MarketplaceBloc _marketplaceBloc;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _accountBloc = AppBlocsProvider.of<AccountBloc>(context);
      _marketplaceBloc = AppBlocsProvider.of<MarketplaceBloc>(context);
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _marketplaceBloc.vendorsStream,
        builder: (context, snapshot) {
          List<VendorModel> vendorsModel = snapshot.data;

          if (vendorsModel == null) {
            return _buildScaffold(Center(
                child: Text("There are no available vendors at the moment.")));
          }

          return _buildScaffold(_buildVendors(vendorsModel));
        });
  }

  Widget _buildScaffold(Widget body) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        iconTheme: theme.appBarIconTheme,
        textTheme: theme.appBarTextTheme,
        backgroundColor: theme.BreezColors.blue[500],
        leading: backBtn.BackButton(),
        title: new Text(
          _title,
          style: theme.appBarTextStyle,
        ),
        elevation: 0.0,
      ),
      body: body,
    );
  }

  Widget _buildVendors(List<VendorModel> vendorModel) {
    return ListView.builder(
      itemBuilder: (context, index) => new VendorRow(_accountBloc, vendorModel[index]),
      itemCount: vendorModel.length,
      itemExtent: 200.0,
    );
  }
}
