class WiFi_InfoOBJ
{
  String _Ssid ;
  String _Password;
  String _user_id;

  WiFi_InfoOBJ(this._Ssid, this._Password, this._user_id);

  String get user_id => _user_id;

  String get Password => _Password;

  String get Ssid => _Ssid;
}