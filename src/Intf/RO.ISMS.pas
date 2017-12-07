(******************************************************************************)
(** Suite         : Reusable Objects                                         **)
(** Object        : ISMS                                                     **)
(** Framework     : FMX                                                      **)
(** Developed by  : Nuno Picado                                              **)
(******************************************************************************)
(** Interfaces    : ISMS                                                     **)
(******************************************************************************)
(** Enumerators   :                                                          **)
(******************************************************************************)
(** Classes       :                                                          **)
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

unit RO.ISMS;

interface

type
  TSMSSentResultCode      = (srcSent, srcRadioOff, srcGenericFailure, srcNoService, srcNullPDU, srcUnknown);
  TSMSDeliveredResultCode = (drcDelivered, drcCanceled);

  ISMSReport = interface(IInvokable)
  ['{BF6D6705-5DCD-4B6E-839B-D9FA24B06406}']
    function Sent(const Destination: string; const ResultCode: TSMSSentResultCode): ISMSReport;
    function Delivered(const Destination: string; const ResultCode: TSMSDeliveredResultCode): ISMSReport;
    function Log(const Text: string): ISMSReport;
  end;

  ISMS = interface(IInvokable)
  ['{FF4999F0-7DA3-4793-9A3A-506B6A795772}']
    function Send(const Destination: string): ISMS;
  end;

implementation

end.
