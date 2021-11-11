SafeDODiag is a library that monitors for errors when energizing single- or dual-channel safe digital output.


[Background]
There are several options for monitoring if a pair of safety contactors (wired in series) or a single safe digital output is operating as intended:
- use a SF_EDM function block in the SafeDESIGNER code and pass the DiagCode back to the gray PLC
- wire contactor/actuator feedbacks to (safe) digital input channels (feedback state and output state need to be opposite of each other) and check the feedbacks in the gray PLC
- check X20SOx1x0 safe digital output channels' CurrentOK status in the gray PLC
- (for Safety Release) enable X20SOx1x0's "Restart inhibit state information" and check each channel's FBK_Status_1 value in the gray PLC;
  (for mapp Safety) enable X20SOx1x0's "State number for start interlock on error" and check each channel's FBOutputStateXXYY value in the gray PLC
This library simplifies the use of these monitoring options by combining them into a single function block with configurable monitoring options.


[Implementation]
SContactor fub is designed for operating two safety contactors in series, but the fub can be used for dual-channel safe digital output control such as dual-channel axis STO.
SDigitalOut fub is designed for operating one safe digital output channel, such as a gas dump valve.
Both fubs have four prioritized monitoring options:
1. Config.DiagCode: SF_EDM DiagCode from safety CPU – if this monitoring config is enabled, external feedback monitoring and SO card's internal CurrentOK monitoring will be ignored (highest priority).
2. Config.Fdbk: external contactor state monitoring (using SafeDigitalInput0X from SI card) – this config should only be used if SF_EDM DiagCode cannot be used, e.g. if PLKbandwidth is at a premium and we cannot afford to transmit SF_EDM DiagCode.
3. Config.Current: SO channel's built-in wiring monitoring (using CurrentOK0X from SO card) – this config should only be used if feedback cannot be used, e.g. controlling dual-channel STO of a VFD (lowest priority).
4. Config.InterlockState: SO channel's output interlock state monitoring (using FBK_Status_1 or FBOutputStateXXYY from SO card) – this config only informs why outputs do not energize, i.e. whether grayCPU doesn't request output or safety CPU doesn't permit output (in parallel to other options).
Interface mapping recommendations:
1. Assign the Status.SafetyResetRequested fub output directly to an IO output variable that uses a BOOL10x channel on the safety CPU to reset SF_EDM error. This request should only be used to reset SF_EDM errors and nothing else.
2. Pass into the pSO_Out_... fub inputs the ADR of the IO output variables described in the Function Block Interface section, and do not manipulate the IOSP output variables in the task that calls this fub.
3. Pass into the pSO_In_... / pSI_In_... fub inputs the ADR of the IO input variables described in the Function Block Interface section. The only reason we ask for the ADR of the input variables (instead of the values of the input variables) is to allow the fub to verify these inputs are connected for monitoring.


[Function Block Interface (semi-color separated tables)]
Required Inputs; Data Types; Descriptions
Cmd.OutputRequest;	BOOL;	Process control enable request. TRUE - close the contactors / FALSE - open the contactors.
Cmd.Reset;	BOOL;	User reset request. Remove this fub from its error state and request a reset of safety CPU's SF_EDM.
pSO_Out_Contactor1;	Reference to BOOL;	(SContactor only) ADR of the IO output variable that maps to the SO card's DigitalOutput0X for contactor coil 1. When processing an OutputRequest, this fub expects to toggle contactor coil 1's IO variable directly.
pSO_Out_Contactor2;	Reference to BOOL;	(SContactor only) ADR of the IO output variable that maps to the SO card's DigitalOutput0Y for contactor coil 2. When processing an OutputRequest, this fub expects to toggle contactor coil 2's IO variable directly.
pSO_Out_DigitalOut;	Reference to BOOL;	(SDigitalOut only) ADR of the IO output variable that maps to the SO card's DigitalOutput0X. When processing an OutputRequest, this fub expects to toggle the safe digital output's IO variable directly.
pSO_In_SafeModuleOK;	Reference to BOOL;	ADR of the IO input variable that maps to the SO card's input SafeModuleOK. If monitoring outputs' interlock states or CurrentOK states, this is used to check if the SO card has entered operational mode (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)
pSO_In_Output1PhysicalState;	Reference to BOOL;	(SContactor only) ADR of the IO input variable that maps to the SO card's input PhysicalState0X. This checks if the output for contactor coil 1 has actually energized (gray CPU requests output + safety CPU permits output) (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)
pSO_In_Output2PhysicalState;	Reference to BOOL;	(SContactor only) ADR of the IO input variable that maps to the SO card's input PhysicalState0Y. This checks if the output for contactor coil 2 has actually energized (gray CPU requests output + safety CPU permits output) (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)
pSO_In_OutputPhysicalState;	Reference to BOOL;	(SDigitalOut only) ADR of the IO input variable that maps to the SO card's input PhysicalState0X. This checks if the safe digital output channel has actually energized (gray CPU requests output + safety CPU permits output) (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)

Essential Outputs;	DataTypes;	Descriptions
Status.OutputRequested;	BOOL;	TRUE - both pSO_Out_Contactor1 and pSO_Out_Contactor2 are commanded to TRUE (or pSO_Out_DigitalOut is commanded to TRUE) / FALSE - either pSO_Out_Contactor1 or pSO_Out_Contactor2 is FALSE (orpSO_Out_DigitalOut is FALSE).
Status.OutputActive;	BOOL;	TRUE - both pSO_In_Output1PhysicalState andpSO_In_Output2PhysicalState are reporting TRUE (orpSO_In_OutputPhysicalState is reporting TRUE) / FALSE - either pSO_In_Output1PhysicalState orpSO_In_Output2PhysicalState is FALSE (or pSO_In_OutputPhysicalState isFALSE) / special case - if only one of these two SContactor fub inputs is mapped (thus the SContactor fub in error state), this output shows the reported value of the mapped input.
Status.SafetyResetRequested;	BOOL;	This signals an automatic SF_EDM reset request after gray CPU reboot. This also passes through the user reset request on the input interface.
Error;	BOOL;	This signals a fub error that requires a user reset request.

Inputs to Enable Monitoring of SF_EDM DiagCode;	Data Types;	Descriptions
Config.DiagCode.EnableMon;	BOOL;	Enable the use of SF_EDM DiagCode from safetyCPU to monitor contactor operation (if this monitoring config is enabled, all other monitoring configs will be ignored).
Config.DiagCode.StartDelayTime;	TIME (defaultT#3s);	After SI card shows SafeModuleOK , this sets the amount of time this fub will delay checkingSF_EDM fub DiagCode (must be > SF_EDM MonitorTime to allow SF_EDM to produce a stabilized DiagCode).
Config.DiagCode.ResetDelayTime;	TIME (defaultT#1s);	After DiagCode shows 16#C060 , this sets the amount of time this fub will delay requesting to reset SF_EDM fub (to allow channel diagnosis to complete and contactor feedbacks to show TRUEafter SI card reports SafeModuleOK).
pSF_In_DiagCode;	Reference toUINT;	ADR of the IO input variable that maps to the safety CPU's UINT00x channel that transmits the SF_EDM fub's DiagCode. This is used to check if safety CPU's SF_EDMerroneously believes the contactors were closed(feedbacks = FALSE) following a gray CPU reboot,so this fub can automatically request a reset ofSF_EDM. (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)
pSI_In_SafeModuleOK;	Reference toBOOL;	ADR of the IO input variable that maps to the SI card's input SafeModuleOK. For safety CPU's SF_EDM to work, there must bean SI card that reads contactor feedbacks. This is used to check if the SI card has entered operational mode. (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)
pSI_In_Contactor1Fdbk;	Reference toBOOL;	(SContactor only) ADR of the IO input variable that maps to the SI card's input SafeDigitalInput0X. This checks if contactor coil 1 is open (feedback =TRUE) or closed (feedback = FALSE). (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)
pSI_In_Contactor2Fdbk;	Reference toBOOL;	(SContactor only) ADR of the IO input variable that maps to the SI card's input SafeDigitalInput0Y. This checks if contactor coil 2 is open (feedback =TRUE) or closed (feedback = FALSE). (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)
pSI_In_DigitalOutFdbk;	Reference toBOOL;	(SDigitalOut only) ADR of the IO input variable that maps to the SI card's input SafeDigitalInput0X. This checks if the safety device connected to the safe digital output is de-activated (feedback =TRUE) or activated (feedback = FALSE). (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)

Inputs to EnableMonitoring of ContactorFeedbacks;	Data Types;	Descriptions
Config.Fdbk.EnableMon;	BOOL;	Enable the use of contactor feedbacks from SI card to monitor contactor operation. (This config should only be used if SF_EDM DiagCodecannot be used, e.g. if PLK bandwidth is at a premium.)
Config.Fdbk.StartDelayTime;	TIME (defaultT#3s);	After SI card shows SafeModuleOK , this sets the amount of time this fub will delay checking contactor feedbacks (to allow channel diagnosis to complete and contactor feedbacks to show TRUE after SI card reports SafeModuleOK).
Config.Fdbk.MonitorTime;	TIME (required,must be <=T#1s);	This sets the amount of time the gray CPU fub will delay comparing contactor feedbacks to allow for switching time and debounce.
pSI_In_SafeModuleOK;	Reference toBOOL;	ADR of the IO input variable that maps to the SIcard's input SafeModuleOK. For contactor feedback to work, there must be an SIcard that reads contactor feedbacks. This is used to check if the SI card has entered operational mode. (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)
pSI_In_Contactor1Fdbk;	Reference toBOOL;	(SContactor only) ADR of the IO input variable that maps to the SIcard's input SafeDigitalInput0X. This checks if contactor coil 1 is open (feedback =TRUE) or closed (feedback = FALSE). (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)
pSI_In_Contactor2Fdbk;	Reference toBOOL;	(SContactor only) ADR of the IO input variable that maps to the SIcard's input SafeDigitalInput0Y. This checks if contactor coil 2 is open (feedback =TRUE) or closed (feedback = FALSE). (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)
pSI_In_DigitalOutFdbk;	Reference toBOOL;	(SDigitalOut only) ADR of the IO input variable that maps to the SIcard's input SafeDigitalInput0X. This checks if the load connected to the safe digital output is de-activated (feedback = TRUE) or activated(feedback = FALSE). (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)

Inputs to EnableMonitoring of OutputCurrentOK;	Data Types;	Descriptions
Config.Current.EnableMon;	BOOL;	Enable the use of CurrentOK from SO card to monitor if outputs are wired up – only available on X20SOx110 andX20SOx120 (This config should only be used if feedbacks cannot be used, e.g. controlling dual-channel STO of a VFD.)
Config.Current.MonitorTime;	TIME (required, must be <=T#1s);	This sets the amount of time the gray CPU fub will delay checking SO card current output levels (to allow transient currents to settle).
pSO_In_Output1CurrentOK;	Reference toBOOL;	(SContactor only) ADR of the IO input variable that maps to the SOcard's input CurrentOK0X. This checks if there is a reasonable amount of current flow(50 mA to 500 mA) from the SO card to contactor coil 1 – if output is not enabled or if the channel is not wired up,CurrentOK shows FALSE. (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)
pSO_In_Output2CurrentOK;	Reference toBOOL;	(SContactor only) ADR of the IO input variable that maps to the SOcard's input CurrentOK0Y. This checks if there is a reasonable amount of current flow(50 mA to 500 mA) from the SO card to contactor coil 2 – if output is not enabled or if the channel is not wired up,CurrentOK shows FALSE. (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)
pSO_In_OutputCurrentOK;	Reference toBOOL;	(SDigitalOut only) ADR of the IO input variable that maps to the SOcard's input CurrentOK0X. This checks if there is a reasonable amount of current flow(50 mA to 500 mA) from the SO card to the load connected to the safe digital output – if output is not enabled or if the channel is not wired up, CurrentOK shows FALSE. (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)

Inputs to Enable Monitoring ofOutput Interlock States;	Data Types;	Descriptions
Config.Interlock.EnableMon;	BOOL;	Enable the use of FBK_Status_1 / FBOutputStateXXYY from SO card to monitor if outputs are energized – only implemented to support X20SOx110 andX20SOx120. (This config only informs why outputs do not energize, i.e. whether gray CPU doesn't request output or safety CPU doesn't permit output.)
Config.Interlock.ChannelPairSelector;	USINT;	(SContactor only) Selector for which byte of the output interlock channel represents the contactor pair (1 -contactor pair is on SO card channels 1 & 2; 3 -contactor pair is on SO card channels 3 & 4;0/2/4/etc. - selection invalid).
Config.Interlock.ChannelSelector;	USINT;	(SDigitalOut only) Selector for which byte of the output interlock channel represents the contactor pair (1-4 - load is on SO card channels 1-4; 0/5+ - selection invalid).
Config.Interlock.StartDelayTime;	TIME (defaultT#3s);	After SO card shows SafeModuleOK , this sets the amount of time this fub will delay checking output interlock states (to allow channel diagnosis to complete after SO card reportsSafeModuleOK).
Config.Interlock.DiscrepancyTime;	TIME (required,must be <=T#1s);	This sets the amount of time the gray CPU fub will delay comparing interlock states' discrepancy.
pSO_In_OutputInterlockStates;	Reference toUINT;	ADR of the IO input variable that maps to the SO card's "Restart inhibit state information" input FBK_Status_1 / "State number for start interlock on error" input FBOutputStateXXYY. This is used to check the output interlock state of every SO card channel (each channel is represented by 1 nibble in the range of 16#0 -16#F) – only implemented to supportX20SOx110 and X20SOx120. (Requiring ADR of the IO variable allows the fub to check if this input has been connected.)

DiagnosticOutputs;	DataTypes;	Descriptions
DiagCode;	UINT;	This passes through the SF_EDM fub's DiagCode when CfgDiagCode monitoring is enabled. This shows supplemental diagnostic codes when other modes of contactor monitoring are used.
Diag.DiagText;	STRING[79];	This provides guidance on what the output is doing/waiting on or why an error occurs.
Diag.ErrorConfig;	BOOL;	This signals an invalid fub input config.
Diag.ErrorSafeFub;	BOOL;	This signals either a contactor operation error detected by safety CPU's SF_EDM or an SF_EDM code administration error–seeDiag.DiagText for guidance.
Diag.ErrorFdbk;	BOOL;	This signals a timeout error during the switching of contactor feedback signals.
Diag.ErrorCurrent;	BOOL;	This signals a timeout error during the switching of SO card output current levels.
Diag.ErrorInterlock;	BOOL;	This signals either an output interlock error detected by the SO card or a two-channel discrepancy during the switching of output interlock states.

Simulation;	Data Types;	Descriptions
Cmd.Simulation.EnableSim;	BOOL;	Stop the fub from monitoring real inputs and setting real outputs (all outputs get disabled). Start populating the Simulation output with simulated input and output values.
Cmd.Simulation.SimMonitorErrors;	USINT;	Each bit (when set to TRUE) simulates the following hardware condition:
	0: output 1 blocked by safety (interlock)
	1: output 2 blocked by safety (interlock) – for SDigitalOut fub, this bit acts the same as bit 0
	2: output 1 wire break (current)
	3: output 2 wire break (current) – for SDigitalOut fub, this bit acts the same as bit 2
	4: fdbk 1 stuck on high/"contactor open" (fdbk)
	5: fdbk 2 stuck on high/"contactor open" (fdbk) – for SDigitalOut fub, this bit acts the same as bit 4
	6: fdbk 1 stuck on low/"contactor closed" (fdbk)
	7: fdbk 2 stuck on low/"contactor closed" (fdbk) – for SDigitalOut fub, this bit acts the same as bit 6
Simulation.Input;	SContactor_SimInputs_TYP;	Display the simulated behavior of all input channels that may be connected to the fub.
Simulation.Output;	SContactor_SimOutput_TYP;	Display the simulated behavior of all output channels that may be connected to the fub.


[DiagCodes and DiagTexts]
Severity;	DiagCode;	Inherited from safety CPU's SF_EDM;	DiagText;	Explanation
Error;	49152 or 16#C000;	No;	SafeFubCommTimeout;	After safety becomes operational (in gray CPUit should be indicated by the contactor feedbacks' SI card reporting SafeModuleOK),SF_EDM DiagCode readback stays at 0 after startup comm timeout.
Error;	49153 or 16#C001;	Yes;	PosReset;	
Error;	49168 or 16#C010;	Yes;	SameTimePosEdgeOutReqNegEdgeFdbk1;	
Error;	49169 or 16#C011;	Yes;	SameTimePosEdgeOutReqNegEdgeFdbk1PosReset;	
Error;	49184 or 16#C020;	Yes;	SameTimePosEdgeOutReqNegEdgeFdbk2;	
Error;	49185 or 16#C021;	Yes;	SameTimePosEdgeOutReqNegEdgeFdbk2PosReset;	
Error;	49200 or 16#C030;	Yes;	SameTimePosEdgeOutReqNegEdgeFdbk1Fdbk2;	
Error;	49201 or 16#C031;	Yes;	SameTimePosEdgeOutReqNegEdgeFdbk1Fdbk2PosReset;	
Error;	49216 or 16#C040;	Yes;	NegFdbk1AfterNegOutReq;	After output request turns off, contactor 1 stays closed (fdbk inactive) by timeout.
Error;	49217 or 16#C041;	Yes;	NegFdbk1PosResetAfterNegOutReq;	
Error;	49232 or 16#C050;	Yes;	NegFdbk2AfterNegOutReq;	After output request turns off, contactor 2 stays closed (fdbk inactive) by timeout.
Error;	49233 or 16#C051;	Yes;	NegFdbk2PosResetAfterNegOutReq;	
Error;	49248 or 16#C060;	Yes;	NegFdbk1Fdbk2AfterNegOutReq;	After output request turns off, both contactors stay closed (fdbk inactive) by timeout.
Error;	49249 or 16#C061;	Yes;	NegFdbk1Fdbk2PosResetAfterNegOutReq;	
Error;	49264 or 16#C070;	Yes;	PosFdbk1AfterPosOutReq;	After output request turns on, contactor 1 stays open (fdbk active) by timeout.
Error;	49265 or 16#C071;	Yes;	PosFdbk1PosResetAfterPosOutReq;	
Error;	49280 or 16#C080;	Yes;	PosFdbk2AfterPosOutReq;	After output request turns on, contactor 2 stays open (fdbk active) by timeout.
Error;	49281 or 16#C081;	Yes;	PosFdbk2PosResetAfterPosOutReq;	
Error;	49296 or 16#C090;	Yes;	PosFdbk1Fdbk2AfterPosOutReq;	After output request turns on, both contactors stay open (fdbk active) by timeout.
Error;	49297 or 16#C091;	Yes;	PosFdbk1Fdbk2PosResetAfterPosOutReq;	
Error;	49409 or 16#C101;	No;	StartResetTimeout;	After gray CPU bootup, contactor feedbacks stay FALSE (inferring contactors closed) orSF_EDM has not reset after startup reset timeout.
Error;	49425 or 16#C111;	Yes;	SameTimePosEdgeOutReqPosEdgeReset;	
Error;	49728 or 16#C240;	No;	PosCurrentOk1fterNegOutReq;	
Error;	49744 or 16#C250;	No;	PosCurrentOk2AfterNegOutReq;	
Error;	49760 or 16#C260;	No;	PosCurrentOk1CurrentOK2AfterNegOutReq;	
Error;	49776 or 16#C270;	No;	NegCurrentOk1AfterPosOutReq;	SafeDO card output channel 1 (or other odd number channels) not wired to contactor 1control input.
Error;	49792 or 16#C280;	No;	NegCurrentOk2AfterPosOutReq;	SafeDO card output channel 2 (or other odd number + 1 channels) not wired to contactor 2control input.
Error;	49808 or 16#C290;	No;	NegCurrentOk1CurrentOK2AfterPosOutReq;	SafeDO card output channels not wired to contactor pair control inputs.
Error;	49920 or 16#C300;	No;	SafeDOCardOkTimeout;	Equivalent to SafeDO card FBK_Status_1 / FBOutputStateXXYY showing 16#0 for the channel.
Error;	49921 or 16#C301;	No;	SafeDOCardOutput1PosReleaseBeforePosEdgePermissioin;	ReleaseOutput already active whenSafeDigitalOutput for channel 1 activates (equivalent to SafeDO card FBK_Status_1 / FBOutputStateXXYY showing 16#6 for output channel 1's interlock state).
Error;	49922 or 16#C302;	No;	SafeDOCardOutput2PosReleaseBeforePosEdgePermissioin;	ReleaseOutput already active whenSafeDigitalOutput for channel 2 activates (equivalent to SafeDO card FBK_Status_1 / FBOutputStateXXYY showing 16#6 for output channel 2's interlock state).
Error;	49923 or 16#C303;	No;	SafeDOCardOutputsPosReleaseBeforePosEdgePermissioin;	ReleaseOutput already active whenSafeDigitalOutput for both channels activate (equivalent to SafeDO card FBK_Status_1 / FBOutputStateXXYY showing 16#6 for both output channels' interlock states).
Error;	49936 or 16#C310;	No;	SafeDOCardOutput1HwErr;	Hardware error or wiring error on output channel 1 (equivalent to SafeDO card FBK_Status_1 / FBOutputStateXXYY showing 16#A for output channel 1's interlock state).
Error;	49937 or 16#C311;	No;	SafeDOCardOutput1SameTimePosEdgePermissionPosEdgeRelease;	ReleaseOutput and SafeDigitalOutput for channel 1 activate at the same time (equivalent to SafeDO card FBK_Status_1 / FBOutputStateXXYY showing 16#5 for output channel 1's interlock state).
Error;	49952 or 16#C320;	No;	SafeDOCardOutput2HwErr;	Hardware error or wiring error on output channel 2 (equivalent to SafeDO card FBK_Status_1 / FBOutputStateXXYY showing 16#A for output channel 2's interlock state).
Error;	49954 or 16#C322;	No;	SafeDOCardOutput2SameTimePosEdgePermissionPosEdgeRelease;	ReleaseOutput and SafeDigitalOutput for channel 2 activate at the same time (equivalent to SafeDO card FBK_Status_1 / FBOutputStateXXYY showing 16#5 for output channel 2's interlock state).
Error;	49968 or 16#C330;	No;	SafeDOCardOutputsHwErr;	Hardware error or wiring error on both output channels (equivalent to SafeDO card FBK_Status_1 / FBOutputStateXXYY showing 16#A for both output channels' interlock states).
Error;	49971 or 16#C333;	No;	SafeDOCardOutputsSameTimePosEdgePermissionPosEdgeRelease;	ReleaseOutput and SafeDigitalOutput for both channels activate at the same time (equivalent to SafeDO card FBK_Status_1 / FBOutputStateXXYY showing 16#5 for both output channels' interlock states).
Error;	49984 or 16#C340;	No;	SafeDOCardPosOutputsNotSameTime;	The switching of a pair of safety contactors is expected to happen at the same time programmatically, but one output stays de-energized by timeout. (No diagnostic effort is made to identify which output stays de-energized.)
Error;	53247 or 16#CFFF;	No;	IndeterminateState or UndocumentedError;	Equivalent to SafeDO card FBK_Status_1 / FBOutputStateXXYY showing an undocumented value for an output channel's interlock state.
Cfg Error;	16#F001;	No;	NoSafeDOCardOkADR;	
Cfg Error;	16#F002;	No;	NoContactor1OutADR;	
Cfg Error;	16#F003;	No;	NoContactor2OutADR;	
Cfg Error;	16#F004;	No;	NoOutput1PhysicalStateADR;	
Cfg Error;	16#F005;	No;	NoOutput2PhysicalStateADR;	
Cfg Error;	16#F010;	No;	NoDiagCodeADR;	
Cfg Error;	16#F011;	No;	NoSafeDICardOkADR;	
Cfg Error;	16#F012;	No;	NoContactor1FdbkADR;	
Cfg Error;	16#F013;	No;	NoContactor2FdbkADR;	
Cfg Error;	16#F014;	No;	NoOutput1CurrentOkADR;	
Cfg Error;	16#F015;	No;	NoOutput2CurrentOkADR;	
Cfg Error;	16#F016;	No;	NoOutputInterlockStateADR;	
Cfg Error;	16#F020;	No;	NoStartDelay;	
Cfg Error;	16#F021;	No;	StartDelayTooLong;	
Cfg Error;	16#F022;	No;	NoResetDelay;	
Cfg Error;	16#F023;	No;	ResetDelayTooLong;	
Cfg Error;	16#F024;	No;	NoMonitorTime;	
Cfg Error;	16#F025;	No;	MonitorTimeTooLong;	
Cfg Error;	16#F026;	No;	InvalidOutputInterlockChannelPairSelector;	Safe contactors are expected to be wired in channel pairs, so valid selector values are: 1 for channels 1 & 2, 3 for channels 3 & 4. This fub is currently designed to supportX20SO21x0 and X20SO41x0.
Information;	16#0000;	No;	Indeterminate;	Function block status is indeterminate.
Information;	16#0001;	No;	WaitingForSafeDOComm;	
Information;	16#0002;	No;	WaitingForSafeDIComm;	Safety has not become operational (in grayCPU it should be indicated by the contactor feedbacks' SI card reporting SafeModuleOK).
Information;	16#0003;	No;	WaitingForSafeFubComm;	(During init state) After safety becomes operational (in gray CPU it should be indicated by the contactor feedbacks' SI card reportingSafeModuleOK), this code/text is displayed to give SF_EDM fub enough time to completeMonitorTime transition. At the moment of startup comm timeout, SF_EDM fub DiagCode is checked. (After init state) SF_EDM fub is deactivated or comm to safety CPU is lost.
Information;	16#0004;	No;	Energizing;	Both outputs are activated but feedbacks have not confirmed the outputs as enabled. (In existing implementation, outputs are assumedEnergized -- 6#8000 -- as soon as outputs are activated until an error is detected.)
Information;	16#0005;	No;	De-energizing;	Both outputs are deactivated but feedbacks have not confirmed the outputs as disabled. (In existing implementation, outputs are assumedDe-energized -- 6#8110 -- as soon as outputs are deactivated until an error is detected.)
Information;	32768 or 16#8000;	Yes;	Energized;	
Information;	32769 or 16#8001;	Yes;	RequireStartReset;	
Information;	32770 or 16#8002;	No;	MayRequireStartReset;	If feedback monitoring is used, then thisDiagText is displayed during init state.
Information;	32784 or 16#8010;	Yes;	RequireOutReq;	Equivalent to SafeDO card FBK_Status_1 / FBOutputStateXXYY showing 16#7 for an output channel's interlock state.
Information;	33024 or 16#8100;	No;	RequireSafePermission;	Equivalent to SafeDO card FBK_Status_1 / FBOutputStateXXYY showing 16#8 for an output channel's interlock state.
Information;	33025 or 16#8101;	No;	RequireSafeRelease;	Equivalent to SafeDO card FBK_Status_1 / FBOutputStateXXYY showing 16#4 for an output channel's interlock state.
Information;	33040 or 16#8110;	No;	De-energized;	If requirements to energize outputs are not known (because of limitations of feedback monitoring, current monitoring, or no monitoring), then this DiagText is displayed during disabled state.
