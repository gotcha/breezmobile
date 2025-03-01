import 'package:breez/bloc/account/account_actions.dart';
import 'package:breez/bloc/account/account_bloc.dart';
import 'package:breez/bloc/account/account_model.dart';
import 'package:breez/widgets/loading_animated_text.dart';
import 'package:breez/widgets/transparent_page_route.dart';
import 'package:flutter/material.dart';
import 'package:breez/theme_data.dart' as theme;

class SyncUIHandler {  
  final AccountBloc _accountBloc;
  final BuildContext _context;
  ModalRoute _syncUIRoute;      

  SyncUIHandler (this._accountBloc, this._context){
     _accountBloc.accountStream.listen((acc){
       showSyncUI(acc);
     });
  }

  void showSyncUI(AccountModel acc){
    if (acc.syncUIState == SyncUIState.BLOCKING) {
      if (_syncUIRoute == null) { 
        
        _syncUIRoute = _createSyncRoute(_accountBloc);
        Navigator.of(_context).push(_syncUIRoute);
      }
    } else {            
      if (_syncUIRoute != null) {
        // If we are not on top of the stack let's pop to get the animation
        if (_syncUIRoute.isCurrent) {
          Navigator.of(this._context).pop();
        } else {
          // If we are hidden, just remove the route.
          Navigator.of(this._context).removeRoute(_syncUIRoute);
        }
        _syncUIRoute = null;
      }
    }
  }
}

ModalRoute _createSyncRoute(AccountBloc accBloc){
  return SyncUIRoute((context){
    return StreamBuilder<AccountModel>(
        stream: accBloc.accountStream,
        builder: (ctx, snapshot){
          var account = snapshot.data;
          double progress = account?.syncProgress ?? 0;
          return TransparentRouteLoader(
            message: "Please wait while Breez is synchronizing", 
            value: progress, 
            opacity: 0.9,
            onClose: () => accBloc.userActionsSink.add(ChangeSyncUIState(SyncUIState.COLLAPSED)),
          );
        },
      );
  });
}

class SyncUIRoute extends TransparentPageRoute {

  SyncUIRoute(Widget Function(BuildContext context) builder) : super(builder);
  
  @override Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {    
    
    var curv = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    return ScaleTransition(scale: curv, child: child, alignment: Alignment.topRight);    
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);
}

class TransparentRouteLoader extends StatefulWidget {
  final String message;
  final double opacity;
  final double value;
  final Function onClose;

  const TransparentRouteLoader({Key key, this.message, this.opacity = 0.5, this.value, this.onClose})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {    
    return TransparentRouteLoaderState();
  }
}

class TransparentRouteLoaderState extends State<TransparentRouteLoader> {

  @override void didUpdateWidget(TransparentRouteLoader oldWidget) {    
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != this.widget.message || oldWidget.opacity != this.widget.opacity || oldWidget.value != this.widget.value) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {    
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[                  
          Positioned(
            top: 0.0,
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container( 
              color: theme.BreezColors.blue[500].withOpacity(widget.opacity),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Stack(alignment: Alignment.center, children: <Widget>[
                    Container(
                    height: 160.0,
                    width: 160.0,   
                    child: new CircularProgressIndicator(        
                      value: widget.value,
                      semanticsLabel: widget.message,
                      backgroundColor: Colors.grey.withOpacity(0.5),
                      valueColor: new AlwaysStoppedAnimation<Color>(
                        theme.whiteColor,
                      ),        
                    ),
                  ),
                    Center(child: Text("${(widget.value * 100).round().toString()}%", textAlign: TextAlign.center, style: TextStyle(fontSize: 36.0, color: Colors.white))),
                  ],),                                   
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: LoadingAnimatedText(widget.message, textAlign: TextAlign.center),
                  )
                ],
              )),
          ),          
          Positioned(
            top: 25.0,
            right: 25.0,
            height: 30.0,
            width: 30.0,
            child: IconButton(color: Colors.white, onPressed: this.widget.onClose, icon: Icon(Icons.unfold_less)),
          ),               
        ],
      ),
    );   
  }
}