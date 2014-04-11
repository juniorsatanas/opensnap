part of opensnap;

@NgComponent(
    selector: 'photo',
    templateUrl: 'packages/opensnap/component/photo_component.html',
    cssUrl: 'packages/opensnap/component/photo_component.css',
    applyAuthorStyles: true,
    publishAs: 'ctrl'
)
class PhotoComponent extends NgShadowRootAware {
  
  VideoElement video;
  CanvasElement canvas;
  ImageElement photo;
  MediaStream stream;
  DivElement photoComponent;
  ButtonElement takePhoto, send;
  SelectElement sendTo, duration;
  
  UserService _userService;
  SnapService _snapService;
  Router _router;
  
  List<User> users;
  bool isUploading = false;
   
  PhotoComponent(this._userService, this._snapService, this._router) {
    if(!_userService.isAuthenticated) {
      _router.go('signin', new Map());
      return;
    }
    _userService.getAllUsers().then((List<User> us) {
      users = us;
    });
    _userService.onEvent.listen((UserEvent e) {
      if(e.type == UserEvent.CREATED) {
          users.add(e.user);
        }
      });
  }
  
  void onShadowRoot(ShadowRoot shadowRoot) {
      photoComponent = shadowRoot.querySelector("#photo-component");
      video = shadowRoot.querySelector("#video");
      canvas = shadowRoot.querySelector("#canvas");
      photo = shadowRoot.querySelector("#photo");
      sendTo = shadowRoot.querySelector("#sendto");
      duration = shadowRoot.querySelector("#duration");
      takePhoto = shadowRoot.querySelector("#take-photo");
      send = shadowRoot.querySelector("#send");
      photo.hidden = true;
      window.navigator.getUserMedia(audio: false, video: true).then((s) {
        stream = s;
        video.src = Url.createObjectUrlFromStream(s);
        video.onCanPlay.listen((e) {
          canvas.width = video.videoWidth;
          canvas.height = video.videoHeight;
        });
    });
      
  }
  
  void takePicture() {
    canvas.context2D.drawImage(video, 0, 0);
    var data = canvas.toDataUrl('image/png');
    photo.setAttribute('src', data);
    video.hidden = true;
    photo.hidden = false;
    send.disabled = false;
  }
  
  void sendSnap() {
    //stream.stop();
    String data = canvas.toDataUrl('image/png');
    Snap snap = new Snap(_userService.authenticatedUser, [new User(sendTo.value)], data, int.parse( duration.value));
    isUploading = true;
    _snapService.createSnap(snap).then((Snap snap) {
      isUploading = false;
      _router.go('snaps', new Map());
    });
  }
  
}