import 'package:breez/bloc/user_profile/currency.dart';
import 'package:breez/bloc/user_profile/security_model.dart';

import 'default_profile_generator.dart';

class BreezUserModel {
  final String userID;
  final Currency currency;
  final String fiatCurrency;
  final String token;
  final String name;
  final String color;
  final String animal;
  final String image;
  final SecurityModel securityModel;
  final bool waitingForPin;

  BreezUserModel._(this.userID, this.name, this.color, this.animal, {
    this.currency = Currency.SAT, this.fiatCurrency = "USD", this.image, this.securityModel, this.waitingForPin, this.token = ''});

  BreezUserModel copyWith({
    String name, String color, String animal, Currency currency, String fiatCurrency, 
    String image, SecurityModel securityModel, bool waitingForPin, String token, String userID}) {
      return new BreezUserModel._(userID ?? this.userID, name ?? this.name, color ?? this.color, animal ?? this.animal, currency: currency ?? this.currency, fiatCurrency: fiatCurrency ?? this.fiatCurrency, image: image ?? this.image, securityModel: securityModel ?? this.securityModel, waitingForPin: waitingForPin ?? this.waitingForPin, token: token ?? this.token);
  }

  bool get registered {
    return userID != null;
  }

  String get avatarURL => image == null || image.isEmpty ? 'breez://profile_image?animal=$animal&color=$color' : image;

  BreezUserModel.fromJson(Map<String, dynamic> json)
      : userID = json['userID'],
        token = json['token'],
        currency = json['currency'] == null ? Currency.SAT : Currency.fromSymbol(json['currency']),
        fiatCurrency = json['fiatCurrency'] == null ? "USD" : json['fiatCurrency'],
        name = json['name'],
        color = json['color'],
        animal = json['animal'],
        image = json['image'],
        waitingForPin = true,      
        securityModel = json['securityModel'] == null ? SecurityModel.initial() : SecurityModel.fromJson(json['securityModel'],);        

  Map<String, dynamic> toJson() => {
        'userID': userID,
        'token': token,
        'currency': currency.symbol,
        'fiatCurrency': fiatCurrency,
        'name': name,
        'color': color,
        'animal': animal,
        'image': image,
        'securityModel': securityModel?.toJson(),
      };
}