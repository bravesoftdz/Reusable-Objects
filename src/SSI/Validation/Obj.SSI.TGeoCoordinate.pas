(******************************************************************************)
(** Suite         : Reusable Objects                                         **)
(** Object        : IGeoCoordinates                                          **)
(** Framework     :                                                          **)
(** Developed by  : Nuno Picado                                              **)
(******************************************************************************)
(** Interfaces    : IGeoCoordinates                                          **)
(** Classes       : TGeoCoordinates, implements IGeoCoordinates              **)
(******************************************************************************)
(** Dependencies  : RTL                                                      **)
(******************************************************************************)
(** Description   : Handles Geo Coordinates                                  **)
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

unit Obj.SSI.TGeoCoordinate;

interface

uses
    Obj.SSI.IGeoCoordinate
  , Obj.SSI.IPrimitive
  ;

type
  TGeoCoordinate = class(TInterfacedObject, IGeoCoordinate)
  private
    FCoordinate: IDouble;
    FCoordinateType: TGeoCoordinateType;
    constructor Create(const CoordinateType: TGeoCoordinateType; const Coordinate: IDouble); Overload;
    procedure Validate;
  public
    class function New(const CoordinateType: TGeoCoordinateType; const Coordinate: IDouble): IGeoCoordinate;
    function ToIString: IString;
    function ToIDouble: IDouble;
  end;

implementation

uses
    SysUtils
  , Obj.SSI.TPrimitive
  ;

{ TMailAddress }

constructor TGeoCoordinate.Create(const CoordinateType: TGeoCoordinateType; const Coordinate: IDouble);
begin
  inherited Create;
  FCoordinateType := CoordinateType;
  FCoordinate     := Coordinate;
  Validate;
end;

function TGeoCoordinate.ToIDouble: IDouble;
begin
  Result := FCoordinate;
end;

function TGeoCoordinate.ToIString: IString;
begin
  Result := TString.New(
   FCoordinate.Value.ToString
  );
end;

procedure TGeoCoordinate.Validate;
var
  Valid: Boolean;
begin
  Valid := ((FCoordinateType = gcLatitude) and (FCoordinate.Value >= -90) and (FCoordinate.Value <= 90)) or
           ((FCoordinateType = gcLongitude) and (FCoordinate.Value >= -180) and (FCoordinate.Value <= 180));

  if not Valid
    then raise exception.Create(Format('"%d" is not a valid geo coordinate.', [FCoordinate]));
end;

class function TGeoCoordinate.New(const CoordinateType: TGeoCoordinateType; const Coordinate: IDouble): IGeoCoordinate;
begin
  Result := Create(CoordinateType, Coordinate);
end;

end.