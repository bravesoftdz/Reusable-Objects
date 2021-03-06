(******************************************************************************)
(** Suite         : Reusable Objects                                         **)
(** Object        : ISMS                                                     **)
(** Framework     : FMX                                                      **)
(** Developed by  : Nuno Picado                                              **)
(******************************************************************************)
(** Interfaces    :                                                          **)
(******************************************************************************)
(** Enumerators   :                                                          **)
(******************************************************************************)
(** Classes       : TSMS                                                     **)
(******************************************************************************)
(** Decorators    :                                                          **)
(******************************************************************************)
(** Extensions    :                                                          **)
(******************************************************************************)
(** Other types   :                                                          **)
(******************************************************************************)
(** Dependencies  :                                                          **)
(******************************************************************************)
(** Description   : Handles sending SMS                                      **)
(******************************************************************************)
(** Licence       : GNU LGPLv3 (http://www.gnu.org/licenses/lgpl-3.0.html)   **)
(** Contributions : You can create pull request for all your desired         **)
(**                 contributions as long as they comply with the guidelines **)
(**                 you can find in the readme.md file in the main directory **)
(**                 of the Reusable Objects repository                       **)
(** Disclaimer    : The licence agreement applies to the code in this unit   **)
(**                 and not to any of its dependencies, which have their own **)
(**                 licence agreement and to which you must comply in their  **)
(**                 terms                                                    **)
(******************************************************************************)

unit RO.Android.TSMS;

interface

uses
    RO.ISMS
  , RO.Android.ISMSReport
  , Androidapi.JNI.Telephony
  , Androidapi.JNI.JavaTypes
  ;

type
  TSMS = class(TInterfacedObject, ISMS)
  private var
    FMsg: JString;
    FSmsMgr: JSmsManager;
    FReport: ISMSReport;
  public
    constructor Create(const Msg: string; const Report: ISMSReport = nil);
    class function New(const Msg: string; const Report: ISMSReport = nil): ISMS;
    function Send(const Destination: string): ISMS;
  end;

implementation

uses
    Androidapi.Helpers
  , Androidapi.JNI.App
  ;

{ TSMS }

constructor TSMS.Create(const Msg: string; const Report: ISMSReport = nil);
begin
  FMsg    := StringToJString(Msg);
  FReport := Report;
  FSmsMgr := TJSmsManager.JavaClass.getDefault;
end;

class function TSMS.New(const Msg: string; const Report: ISMSReport = nil): ISMS;
begin
  Result := Create(Msg, Report);
end;

function TSMS.Send(const Destination: string): ISMS;
var
  smsTo: JString;
  PendingSentIntent: JPendingIntent;
  PendingDeliveredIntent: JPendingIntent;
begin
  Result := Self;

  if Assigned(FReport)
    then begin
      FReport.Destination(Destination);
      PendingSentIntent      := FReport.PendingSentIntent;
      PendingDeliveredIntent := FReport.PendingDeliveredIntent;
    end
    else begin
      PendingSentIntent      := nil;
      PendingDeliveredIntent := nil;
    end;

  smsTo := StringToJString(Destination);
  FSmsMgr.sendTextMessage(
    smsTo,
    nil,
    FMsg,
    PendingSentIntent,
    PendingDeliveredIntent
  );
end;

end.
