import Int "mo:base/Int";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

actor {
  public type Message = {
    msg : Text;
    time : Time.Time;
  };
  public type Microblog = actor {
    follow : shared(Principal) -> async();
    follows : shared query () -> async [Principal];
    post : shared (Text) -> async();
    posts : shared query (Time.Time) -> async [Message];
    timeline : shared (Time.Time) -> async [Message];
  };
  stable var followed : List.List<Principal> = List.nil();


  public shared func follow(id: Principal) : async (){
      followed:= List.push(id,followed);
  };
  public shared query func follows() : async [Principal]{
      List.toArray(followed);
  };

  stable  var messages : List.List<Message> = List.nil();

  public shared (msg) func post(text :Text) : async (){
      //assert(Principal.toText(msg.caller) == "wys55-qkswd-tlliu-imdk3-qbsl5-2yha7-i2uca-oqmmf-ema5a-bibu5-dae");
      let message: Message = {
        msg = text;
        time = Time.now();
      };
      messages := List.push(message,messages);
  };
  public shared query func posts(since: Time.Time) : async [Message]{
    var timeMessages : List.List<Message> = List.nil();
    List.iterate(messages,func(message:Message){
      if(message.time>=since){
        timeMessages:=List.push(message,timeMessages);
      };
    });
    List.toArray(timeMessages);
  };

   
  public shared func timeline(since: Time.Time) : async [Message]{
  var all : List.List<Message> = List.nil();
   for(id in Iter.fromList(followed)){
      let canister : Microblog = actor(Principal.toText(id));
      let msgs = await canister.posts(since);
      for (msg in Iter.fromArray(msgs)){
        all:=List.push(msg,all);
      };
   };
   List.toArray(all);
  };
  
};