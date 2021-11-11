(*********************************************************************************
 * Copyright: General Electric 
 * Author:    503211140 
 * Created:   March 3, 2021/10:14 AM 
 *********************************************************************************)

TYPE
	SContactor_State_ENUM : 
		(
		SC_CFG := 0,
		SC_INIT,
		SC_DISABLED,
		SC_ENABLED,
		SC_ERROR := -1
		);
	SContactor_CmdSim_TYP : 	STRUCT 
		EnableSim : BOOL; (*Enable contactor input and output simulation. Use fub output Simulation to see the expected output values and feedback values.*)
		SimMonitorErrors : USINT; (*Simulate error conditions by toggling individual bits to TRUE:
0: output 1 blocked by safety (interlock)
1: output 2 blocked by safety (interlock)
2: output 1 wire break (current)
3: output 2 wire break (current)
4: fdbk 1 stuck on high/"contactor open" (fdbk)
5: fdbk 2 stuck on high/"contactor open" (fdbk)
6: fdbk 1 stuck on low/"contactor closed" (fdbk)
7: fdbk 2 stuck on low/"contactor closed" (fdbk)*)
	END_STRUCT;
	SContactor_Cmd_TYP : 	STRUCT 
		OutputRequest : BOOL; (*Process control request: TRUE - close the contactor; FALSE - open the contactor*)
		Reset : BOOL; (*Remove the gray CPU fub from its error state and send reset request to safety CPU*)
		Simulation : SContactor_CmdSim_TYP; (*Simulation request. Element "SimMonitorErrors" only gets checked if element "EnableSim" is set to TRUE.*)
	END_STRUCT;
	SContactor_CfgDiagCode_TYP : 	STRUCT  (*Configure safety CPU-reported SF_EDM fub DiagCode monitoring*)
		EnableMon : BOOL; (*When TRUE the contactor function block will monitor safety CPU's SF_EDM fub DiagCodes (require safety CPU to use UINT channels to pass DiagCodes to gray CPU)*)
		StartDelayTime : TIME := T#3s; (*The amount of time the gray CPU fub will delay checking SF_EDM fub DiagCode after SI card shows SafeModuleOK (must be > SF_EDM MonitorTime to allow SF_EDM to produce a stabilized DiagCode)*)
		ResetDelayTime : TIME := T#1s; (*The amount of time the gray CPU fub will delay requesting to reset SF_EDM fub after DiagCode shows 16#C060 (to allow channel diagnosis to complete and contactor feedbacks to show TRUE after SI card reports SafeModuleOK); also used as the amount of time the gray CPU fub will wait to reset itself after requesting to reset SF_EDM fub.*)
	END_STRUCT;
	SContactor_CfgFdbk_TYP : 	STRUCT  (*Configure SI hardware-based contactor status feedback monitoring*)
		EnableMon : BOOL; (*When TRUE the contactor function block will monitor SI hardware for contactor status feedback*)
		StartDelayTime : TIME := T#3s; (*The amount of time the gray CPU fub will delay checking contactor feedbacks after SI card shows SafeModuleOK (to allow channel diagnosis to complete and contactor feedbacks to show TRUE after SI card reports SafeModuleOK)*)
		MonitorTime : TIME; (*The amount of time the gray CPU fub will delay comparing contactor feedbacks to allow for switching time and debounce*)
	END_STRUCT;
	SContactor_CfgCurrent_TYP : 	STRUCT  (*Configure SO hardware-based current ok monitoring*)
		EnableMon : BOOL; (*When true the contactor function block will monitor the current input for the contactor*)
		MonitorTime : TIME; (*The amount of time the gray CPU fub will delay checking the current output to allow transient current to settle*)
	END_STRUCT;
	SContactor_CfgInterlockState_TYP : 	STRUCT  (*Dual-channel safe digital output: Configure SO hardware-based output interlock state ("restart inhibit state") monitoring*)
		EnableMon : BOOL; (*When TRUE the contactor function block will monitor SO hardware for output interlock state (require SO card's "Restart inhibit state information" turned on)*)
		ChannelPairSelector : USINT; (*Selector for which byte of the output interlock channel represents the contactor pair (1 - contactor pair is on SO card channels 1 & 2; 3 - contactor pair is on SO card channels 3 & 4; 0/2/4/etc. - selection invalid)*)
		StartDelayTime : TIME := T#3s; (*The amount of time the gray CPU fub will delay checking output interlock states after SO card shows SafeModuleOK (to allow channel diagnosis to complete after SO card reports SafeModuleOK)*)
		MonitorTime : TIME; (*The amount of time the gray CPU fub will delay comparing interlock states' discrepancy*)
	END_STRUCT;
	SContactor_Cfg_TYP : 	STRUCT 
		Name : STRING[35] := 'NamedContactors'; (*Unique contactor name for easy identification in alarm text*)
		DiagCode : SContactor_CfgDiagCode_TYP; (*Option for monitoring safety CPU's SF_EDM fub state*)
		Fdbk : SContactor_CfgFdbk_TYP; (*Option for monitoring status input of each contactors*)
		Current : SContactor_CfgCurrent_TYP; (*Option for monitoring current associated with the pair of contactors*)
		InterlockState : SContactor_CfgInterlockState_TYP; (*Option for monitoring output interlock state of each contactor*)
		BootUpDelay : TIME := T#10m; (*Wait time for the SafeModuleOK feedback on PLC startup*)
	END_STRUCT;
	SContactor_Simulation_TYP : 	STRUCT 
		Input : SContactor_IntInput_TYP; (*Simulation inputs mirror the internal inputs, so the data type uses SContactor_IntInput_TYP (not a typo)*)
		Output : SContactor_IntOutput_TYP; (*Simulation inputs mirror the internal outputs, so the data type uses SContactor_IntOutput_TYP (not a typo)*)
	END_STRUCT;
	SContactor_Status_TYP : 	STRUCT 
		OutputRequested : BOOL; (*Echo the OutputRequest input to show that the fub is running*)
		OutputActive : BOOL; (*Show that both safety contactor outputs are energized (safety contactors are not necessarily closed)*)
		SafetyResetRequested : BOOL; (*Show that a SF_EDM reset needs to be sent to safety CPU*)
	END_STRUCT;
	SContactor_Diag_TYP : 	STRUCT 
		DiagText : STRING[79];
		ErrorConfig : BOOL; (*The error is due to an invalid config*)
		ErrorSafeFub : BOOL; (*The error is due to safety CPU fub SF_EDM*)
		ErrorFdbk : BOOL; (*The error is due to contactor status feedback*)
		ErrorCurrent : BOOL; (*The error is due to current feedback*)
		ErrorInterlock : BOOL; (*The error is due to output interlock*)
		ErrorInternal : BOOL; (*The error is due to fub design that did not account for certain situations*)
	END_STRUCT;
	SContactor_IntPrev_TYP : 	STRUCT 
		State : SContactor_State_ENUM;
		Reset : BOOL;
		EnDiagCode : BOOL;
		EnFdbk : BOOL;
		EnInterlock : BOOL;
		EnCurrent : BOOL;
		SimOutput1 : BOOL;
		SimOutput2 : BOOL;
	END_STRUCT;
	SContactor_IntFub_TYP : 	STRUCT 
		TON_EDMStartDelay : TON;
		TON_EDMResetDelay : TON;
		TON_FdbkStartDelay : TON;
		TON_Fdbk : TON;
		TON_Current : TON;
		TON_InterlockStartDelay : TON;
		TON_Interlock : TON;
		TON_EDMMonitorSim : TON;
	END_STRUCT;
	SContactor_IntInput_TYP : 	STRUCT 
		SF_In_DiagCode : UINT;
		SI_In_SafeModuleOK : BOOL;
		SI_In_Contactor1Fdbk : BOOL;
		SI_In_Contactor2Fdbk : BOOL;
		SO_In_SafeModuleOK : BOOL;
		SO_In_Output1PhysicalState : BOOL;
		SO_In_Output2PhysicalState : BOOL;
		SO_In_Output1CurrentOK : BOOL;
		SO_In_Output2CurrentOK : BOOL;
		SO_In_OutputInterlockStates : UINT;
		InterlockStateOutput1 : USINT;
		InterlockStateOutput2 : USINT;
	END_STRUCT;
	SContactor_IntOutput_TYP : 	STRUCT 
		SO_Out_Contactor1 : BOOL;
		SO_Out_Contactor2 : BOOL;
	END_STRUCT;
	SContactor_Internal_TYP : 	STRUCT 
		State : SContactor_State_ENUM; (*State of the contactor fub*)
		StateGoTo : SContactor_State_ENUM;
		Input : SContactor_IntInput_TYP;
		Output : SContactor_IntOutput_TYP;
		Fub : SContactor_IntFub_TYP;
		Prev : SContactor_IntPrev_TYP;
		EDMReset : BOOL;
		i : UDINT;
	END_STRUCT;
END_TYPE

(*Single-channel safe digital output control and diagnosis (a simplification of SContactor)*)

TYPE
	SDigiOut_CfgInterlockState_TYP : 	STRUCT  (*Single-channel safe digital output: Configure SO hardware-based output interlock state ("restart inhibit state") monitoring*)
		EnableMon : BOOL; (*When TRUE the contactor function block will monitor SO hardware for output interlock state (require SO card's "Restart inhibit state information" turned on)*)
		ChannelSelector : USINT; (*Selector for which byte of the output interlock channel represents the contactor pair (1/2/3/4 - SO card channel that's being controlled; 0/5+ - selection invalid)*)
		StartDelayTime : TIME := T#3s; (*The amount of time the gray CPU fub will delay checking output interlock states after SO card shows SafeModuleOK (to allow channel diagnosis to complete after SO card reports SafeModuleOK)*)
		MonitorTime : TIME; (*The amount of time the gray CPU fub will delay comparing interlock states' discrepancy*)
	END_STRUCT;
	SDigiOut_Cfg_TYP : 	STRUCT 
		Name : STRING[35]; (*Unique contactor name for easy identification in alarm text*)
		DiagCode : SContactor_CfgDiagCode_TYP; (*Option for monitoring safety CPU's SF_EDM fub state*)
		Fdbk : SContactor_CfgFdbk_TYP; (*Option for monitoring status input of each contactors*)
		Current : SContactor_CfgCurrent_TYP; (*Option for monitoring current associated with the pair of contactors*)
		InterlockState : SDigiOut_CfgInterlockState_TYP; (*Option for monitoring output interlock state of each contactor*)
	END_STRUCT;
END_TYPE
