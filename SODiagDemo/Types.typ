(*Structures of IO_TYPE*)

TYPE
	IoInput_TYPE : 	STRUCT 
		ContactorSOModuleOK : BOOL; (*Check if SO card for contactor control is in operational mode*)
		Contactor1EnergizeState : BOOL; (*Check if SO card has physically energized output for contactor coil 1*)
		Contactor2EnergizeState : BOOL; (*Check if SO card has physically energized output for contactor coil 2*)
		EDMDiagCode : UINT; (*Read SF_EDM diagnostic code from safety CPU*)
		FdbkSIModuleOK : BOOL; (*Check if SI card for contactor feedback is in operational mode*)
		Contactor1Fdbk : BOOL; (*Check if contactor 1 is open or closed (TRUE--open; FALSE--closed)*)
		Contactor2Fdbk : BOOL; (*Check if contactor 2 is open or closed (TRUE--open; FALSE--closed)*)
		Contactor1EnergizeCurrentOK : BOOL; (*Check if SO card is sending an expected level of current (50 mA - 500 mA) to energize contactor coil 1*)
		Contactor2EnergizeCurrentOK : BOOL; (*Check if SO card is sending an expected level of current (50 mA - 500 mA) to energize contactor coil 2*)
		ContactorOutputInterlockStatesSR : UINT; (*Safety Release-compatible: Read output interlock states from SO card*)
		ContactorOutputInterlockStatesMP : USINT; (*mapp Safety-compatible: Read output interlock states from SO card*)
	END_STRUCT;
	IoOutput_TYPE : 	STRUCT 
		Contactor1EnergizeRequest : BOOL; (*Request SO card output for contactor coil 1*)
		Contactor2EnergizeRequest : BOOL; (*Request SO card output for contactor coil 2*)
		EDMReset : BOOL; (*Request safety CPU to reset SF_EDM error*)
	END_STRUCT;
	IO_TYPE : 	STRUCT  (*Structure with the input and outputs of the plc used by this task*)
		Input : IoInput_TYPE; (*Structure with the inputs of this task*)
		Output : IoOutput_TYPE; (*Structure with the outputs of this task*)
	END_STRUCT;
END_TYPE

(*Structures of IOSP_TYPE - Signal Processing*)

TYPE
	IOSP_TYPE : 	STRUCT  (*Structure with the input and outputs of the plc used by this task*)
		Input : IoInput_TYPE; (*Structure with the inputs of this task*)
		Output : IoOutput_TYPE; (*Structure with the outputs of this task*)
	END_STRUCT;
END_TYPE
