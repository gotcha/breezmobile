import 'dart:async';
import 'dart:convert' as JSON;
import 'package:breez/routes/user/marketplace/webln_handlers.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:breez/bloc/account/account_bloc.dart';
import 'package:breez/bloc/blocs_provider.dart';
import 'package:breez/bloc/invoice/invoice_bloc.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:breez/theme_data.dart' as theme;
import 'package:breez/widgets/back_button.dart' as backBtn;
import 'package:flutter/services.dart' show rootBundle;

class VendorWebViewPage extends StatefulWidget {
  final AccountBloc accountBloc;
  final String _url;
  final String _title;

  VendorWebViewPage(this.accountBloc, this._url, this._title);

  @override
  State<StatefulWidget> createState() {
    return new VendorWebViewPageState();
  }
}

class VendorWebViewPageState extends State<VendorWebViewPage> {
  final _widgetWebview = new FlutterWebviewPlugin();    
  StreamSubscription _postMessageListener;  
  WeblnHandlers _weblnHandlers;
  bool _isInit = false;
  Uint8List _screenshotData;

  @override
  void initState() {
    super.initState();    
    _widgetWebview.onDestroy.listen((_) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });    
  }

  Future<String> loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }

  Future onBeforeCallHandler(String handlerName){
    if (_screenshotData != null || !["makeInvoice", "sendPayment"].contains(handlerName)){
      return Future.value(null);
    }

    Completer beforeCompleter = Completer(); 
    FocusScope.of(context).requestFocus(FocusNode());
      // Wait for keyboard and screen animations to settle
    Timer(Duration(milliseconds: 750), () {
      // Take screenshot and show payment request dialog
      _takeScreenshot().then((imageData) {
        setState(() {
          _screenshotData = imageData;
        });
        // Wait for memory image to load
        Timer(Duration(milliseconds: 200), () {
          // Hide Webview to interact with payment request dialog
          _widgetWebview.hide(); 
          beforeCompleter.complete();
        });
      });
    }); 

    return beforeCompleter.future; 
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      var invoiceBloc = AppBlocsProvider.of<InvoiceBloc>(context);
      var accountBloc = AppBlocsProvider.of<AccountBloc>(context);
      _weblnHandlers = WeblnHandlers(context, accountBloc, invoiceBloc, onBeforeCallHandler);

      String loadedURL;
      _widgetWebview.onStateChanged.listen((state) async {
        if (state.type == WebViewState.finishLoad && loadedURL != state.url) {          
          loadedURL = state.url;
          _widgetWebview.evalJavascript(await _weblnHandlers.initWeblnScript);
        }
      });
      
      _postMessageListener = _widgetWebview.onPostMessage.listen((msg) {        
        if (msg != null ) {         
          var postMessage = (widget._title == "ln.pizza") ? {"action": "sendPayment", "payReq": msg} : JSON.jsonDecode(msg);                    
          _weblnHandlers.handleMessage(postMessage)
            .then((resScript){
              if (resScript != null) {
                _widgetWebview.evalJavascript(resScript);
                _widgetWebview.show();
                setState(() {
                  _screenshotData = null;
                });
              }
            });            
        }
      });
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {    
    _postMessageListener.cancel();
    _widgetWebview.dispose();
    _weblnHandlers?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new WebviewScaffold(
      appBar: new AppBar(
        leading: backBtn.BackButton(),
        automaticallyImplyLeading: false,
        iconTheme: theme.appBarIconTheme,
        textTheme: theme.appBarTextTheme,
        backgroundColor: theme.BreezColors.blue[500],
        title: new Text(
          widget._title,
          style: theme.appBarTextStyle,
        ),
        elevation: 0.0,
      ),
      url: widget._url,
      withJavascript: true,
      withZoom: false,
      clearCache: true,
      initialChild: _screenshotData != null ? Image.memory(_screenshotData) : null,
    );
  }

  Future _takeScreenshot() async {
    Uint8List _imageData = await _widgetWebview.takeScreenshot();
    return _imageData;
  }
}
