part of opensnap;

class SnapService {
  
  StompClientService _client;
  UserService _userService;
  StreamController _eventController = new StreamController.broadcast();
  
  Stream get onEvent => _eventController.stream;
   
  SnapService(this._client, this._userService) {
    _userService.onEvent.listen((UserEvent event) {
      if(event.type == UserEvent.LOGIN) return _client._connectIfNeeded().then((_) {
        _client.subscribeJson("/user/queue/snap-received", (var headers, var message) {
            _eventController.add(new SnapEvent(SnapEvent.RECEIVED, new Snap.fromJsonMap(message)));
          });
        });  
    });
  }
  
  Future<Snap> createSnap(Snap snap) {
    return _client.sendJsonMessage("/app/snap/create",snap, "/user/queue/snap-created", (_) => new Snap.fromJsonMap(_));
  }
  
  Future<Snap> getSnapById(int id) {
      return _client.sendJsonSubscribe("/app/snap/id/$id", (_) => new Snap.fromJsonMap(_));
    }
    
  Future<List<Snap>> getSnaps() {
    return _client.sendJsonSubscribe("/app/snap/user", (_) {
      List<Snap> snaps = new List<Snap>();
      for(Map map in _) {
        snaps.add(new Snap.fromJsonMap(map));  
      }
      _eventController.add(new SnapEvent.fromSnaps(SnapEvent.RETREIVED, snaps));
      return snaps;
    });
  }
      
  void deleteSnap(Snap snap) {
    _client.sendJsonSubscribe('/app/snap/delete-for-authenticated-user/${snap.id}');
    _eventController.add(new SnapEvent(SnapEvent.DELETED, snap));
  }
}