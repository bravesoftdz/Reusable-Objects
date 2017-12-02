(******************************************************************************)
(** Suite         : Reusable Objects                                         **)
(** Object        : IScale                                                   **)
(** Framework     :                                                          **)
(** Developed by  : Nuno Picado                                              **)
(******************************************************************************)
(** Interfaces    : TScale                                                   **)
(******************************************************************************)
(** Dependencies  : VCL, TComPort                                            **)
(******************************************************************************)
(** Description   : Handles communication with a serial scale                **)
(******************************************************************************)
(** Licence       : GNU LGPLv3 (http://www.gnu.org/licenses/lgpl-3.0.html)   **)
(** Contributions : You can create pull request for all your desired         **)
(**                 contributions as long as they comply with the guidelines **)
(**                 you can find in the readme.md file in the main directory **)
(**                 of the Reusable Objects repository                       **)
(** Disclaimer    : The licence agreement applies to the code in this unit   **)
(**                 and not to any of its dependencies, which have their own **)
(**                 licence agreement and to which you must comply in their  **)
(**	                terms                                                    **)
(******************************************************************************)

unit RO.VCL.TScale;

interface

uses
    RO.VCL.IScale
  , RO.VCL.ITimer
  , RO.ICOMPort
  ;

type
  TScale = class(TInterfacedObject, IScale)
  private var
    FOutput: IScaleOutput;
    FPort: IComPort;
    FTXSequence: string;
    FRXMask: string;
  private
    procedure DataReception(Str: string);
    function ParseScaleData(RxData: string): Real;
  public
    constructor Create(const ScaleOutput: IScaleOutput; const COMPort: ICOMPort; const TXSequence, RXMask: string);
    class function New(const ScaleOutput: IScaleOutput; const COMPort: ICOMPort; const TXSequence, RXMask: string): IScale;
    function Connect: IScale;
    function Disconnect: IScale;
    function Request: IScale;
  end;

  TAutoRequest = class(TInterfacedObject, IScale)
  private var
    FOrigin: IScale;
    FTimer: ITimer;
  private
    procedure RequestTimer;
  public
    constructor Create(const Origin: IScale; const Timer: ITimer);
    class function New(const Origin: IScale; const Timer: ITimer): IScale;
    function Connect: IScale;
    function Disconnect: IScale;
    function Request: IScale;
  end;

implementation

uses
    SysUtils
  , Math
  ;

{ TScale }
{$REGION TScale}
constructor TScale.Create(const ScaleOutput: IScaleOutput; const COMPort: ICOMPort; const TXSequence, RXMask: string);
resourcestring
  ScaleInitError = 'An output implementation is required';
begin
  if not Assigned(ScaleOutput)
    then raise Exception.Create(ScaleInitError);

  FOutput     := ScaleOutput;
  FTXSequence := TXSequence;
  FRXMask     := RXMask;
  FPort       := COMPort.ReadStr(DataReception);
end;

class function TScale.New(const ScaleOutput: IScaleOutput; const COMPort: ICOMPort; const TXSequence, RXMask: string): IScale;
begin
  Result := Create(
    ScaleOutput,
    COMPort,
    TXSequence,
    RXMask
  );
end;

function TScale.Connect: IScale;
begin
  Result := Self;
  FPort.Open;
end;

function TScale.Request: IScale;
begin
  Result := Self;
  FPort.WriteStr(FTXSequence);
end;

procedure TScale.DataReception(Str: string);
begin
  if (not Str.IsEmpty)
      and (Str <> #13#10)
    then begin
      FOutput.ReportWeight(
        ParseScaleData(
          Str
        )
      );
    end;
end;

function TScale.ParseScaleData(RxData: string): Real;
var
  Valor: string;
  i: Byte;
begin
  Valor := '';
  for i := 1 to Min(RxData.Length, FRXMask.Length) do
    if CharInSet(FRXMask[i], ['#', FormatSettings.DecimalSeparator])
      then Valor := Valor + RxData[i];
  Valor  := StringReplace(Valor, '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  Result := StrToFloatDef(Trim(Valor), 0);
end;

function TScale.Disconnect: IScale;
begin
  Result := Self;
  FPort.Close;
end;
{$ENDREGION}

{ TAutoRequest }
{$REGION TAutoRequest}
function TAutoRequest.Connect: IScale;
begin
  Result := Self;
  FOrigin.Connect;
  FTimer.Start(RequestTimer);
end;

procedure TAutoRequest.RequestTimer;
begin
  try
    Request;
  except
    FTimer.Stop;
    raise;
  end;
end;

constructor TAutoRequest.Create(const Origin: IScale; const Timer: ITimer);
begin
  FOrigin := Origin;
  FTimer  := Timer;
end;

function TAutoRequest.Disconnect: IScale;
begin
  Result := Self;
  FOrigin.Disconnect;
end;

class function TAutoRequest.New(const Origin: IScale; const Timer: ITimer): IScale;
begin
  Result := Create(Origin, Timer);
end;

function TAutoRequest.Request: IScale;
begin
  Result := Self;
  FOrigin.Request;
end;
{$ENDREGION}

end.
