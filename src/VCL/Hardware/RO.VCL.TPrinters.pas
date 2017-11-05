(******************************************************************************)
(** Suite         : Reusable Objects                                         **)
(** Object        : IPrinters                                                **)
(** Framework     :                                                          **)
(** Developed by  : Nuno Picado                                              **)
(******************************************************************************)
(** Classes       : TPrinters, Implements IPrinters                          **)
(******************************************************************************)
(** Dependencies  : RTL, WinSpool                                            **)
(******************************************************************************)
(** Description   : Represents the list of printers registered in the        **)
(**                 Windows Spooler. Can send direct escape sequences to a   **)
(**                 printer                                                  **)
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

unit RO.VCL.TPrinters;

interface

uses
    WinSpool
  , Spring.Collections
  , RO.IValue
  , RO.VCL.IPrinters
  ;

type
  TPrinters = class(TInterfacedObject, IPrinters)
  private
    type
      TByteArray = array of Byte;
    var
      FSelected : IString;
      FDocInfo1 : TDocInfo1;
  private
    procedure PrepareBuffer(const Sequence: IList<Byte>; Buffer: TByteArray);
  public
    constructor Create;
    class function New: IPrinters;
    function SendSequence(const Sequence: IList<Byte>): IPrinters;
    function AsList(const List: IList<string>): IPrinters;
    function Select(const Name: IString): IPrinters;
    function Default: IString;
  end;

implementation

uses
    SysUtils
  , Printers
  , RO.TValue
  , RO.TIf
  ;

constructor TPrinters.Create;
begin
  with FDocInfo1 do begin
    pDocName    := nil;
    pOutputFile := nil;
    pDataType   := 'RAW';
  end;
  FSelected := Default;
end;

class function TPrinters.New: IPrinters;
begin
  Result := Create;
end;

function TPrinters.Select(const Name: IString): IPrinters;
begin
  Result := Self;
  if Printer.Printers.IndexOfName(Name.Value) = -1
    then Raise Exception.Create(Format('Failed to find %s printer.', [QuotedStr(Name.Value)]));
  FSelected := Name;
end;

procedure TPrinters.PrepareBuffer(const Sequence: IList<Byte>; Buffer: TByteArray);
var
  i: Byte;
begin
  SetLength(Buffer, Sequence.Count);
  for i := 0 to Pred(Sequence.Count) do
    Buffer[i] := Sequence.Items[i]
end;

function TPrinters.SendSequence(const Sequence: IList<Byte>): IPrinters;
var
  Buffer : TByteArray;
  Handle : THandle;
  N      : Cardinal;
begin
  Result := Self;
  PrepareBuffer(Sequence, Buffer);
  if not OpenPrinter(PChar(FSelected), Handle, nil) then begin
    raise exception.Create(Format('Failed opening printer: %d', [GetLastError]))
  end
  else begin
    StartDocPrinter(Handle, 1, @FDocInfo1);
    WritePrinter(Handle, Pointer(Buffer), Length(Buffer), N);
    EndDocPrinter(Handle);
    ClosePrinter(Handle);
  end;
end;

function TPrinters.AsList(const List: IList<string>): IPrinters;
var
  i: Byte;
begin
  Result := Self;
  for i := 0 to Pred(Printer.Printers.Count) do
    List.Add(Printer.Printers[i]);
end;

function TPrinters.Default: IString;
begin
  Result := TString.New(
    TIf<string>.New(
      Printer.PrinterIndex > 0,
      PChar(Printer.Printers[Printer.PrinterIndex]),
      ''
    ).Eval
  );
end;

end.