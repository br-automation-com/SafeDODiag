(*Safety Release-compatible X20SO21xx/X20SO41xx output error diagnosis*)
FUNCTION_BLOCK SContactor (*Dual-channel safe digital output control and monitoring, example use includes redundant safety contactor control*)
	VAR_INPUT
		Cmd : SContactorCmdType; (*Request to energize output*)
		pSO_Out_Contactor1 : REFERENCE TO BOOL; (*Reference to the SO card output for contactor coil 1*)
		pSO_Out_Contactor2 : REFERENCE TO BOOL; (*Reference to the SO card output for contactor coil 2*)
		pSO_In_SafeModuleOK : REFERENCE TO BOOL; (*Reference to the SO card input SafeModuleOK*)
		pSO_In_Output1PhysicalState : REFERENCE TO BOOL; (*Reference to the SO card input PhysicalStateChannelX for contactor coil 1*)
		pSO_In_Output2PhysicalState : REFERENCE TO BOOL; (*Reference to the SO card input PhysicalStateChannelY for contactor coil 2*)
		Config : SContactorCfgType; (*Pointer to the configuration structure*)
		pSF_In_DiagCode : REFERENCE TO UINT; (*Reference to the safety-to-gray UINT channel that reports SF_EDM fub DiagCode*)
		pSI_In_SafeModuleOK : REFERENCE TO BOOL; (*Reference to the SO card input SafeModuleOK*)
		pSI_In_Contactor1Fdbk : REFERENCE TO BOOL; (*Reference to the SI card input for the feedback status of contactor coil 1*)
		pSI_In_Contactor2Fdbk : REFERENCE TO BOOL; (*Reference to the SI card input for the feedback status of contactor coil 2*)
		pSO_In_Output1CurrentOK : REFERENCE TO BOOL; (*Reference to the SO card's monitoring of channel current for contactor coil 1*)
		pSO_In_Output2CurrentOK : REFERENCE TO BOOL; (*Reference to the SO card's monitoring of channel current for contactor coil 2*)
		pSO_In_OutputInterlockStates : REFERENCE TO UINT; (*Reference to the SO card output interlocking states (each channel is 1 nibble in the range of 16#0 - 16#F)*)
	END_VAR
	VAR_OUTPUT
		Error : BOOL; (*Show that an error has occured to prevent output*)
		DiagCode : UINT; (*Show diagnostic code based on available monitoring capability*)
		Diag : SContactorDiagType; (*Show diagnostic info based on available monitoring capability*)
		Status : SContactorStatusType; (*Show that both safety contactor outputs are energized (safety contactors are not necessarily closed)*)
		Simulation : SContactorSimulationType; (*Show simulated I/O values based on fub input Cmd.Simulation.SimMonitorErrors*)
	END_VAR
	VAR
		Internal : SContactorInternalType; (*Internal variables*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SDigitalOut (*Single-channel safe digital output control and monitoring, example use includes gas dump valve control*)
	VAR_INPUT
		Cmd : SContactorCmdType; (*Request to energize output*)
		pSO_Out_DigitalOut : REFERENCE TO BOOL; (*Reference to the SO card digital output channel*)
		pSO_In_SafeModuleOK : REFERENCE TO BOOL; (*Reference to the SO card input SafeModuleOK*)
		pSO_In_OutputPhysicalState : REFERENCE TO BOOL; (*Reference to the SO card input PhysicalStateChannelX for the controlled digital output channel*)
		Config : SDigitalOutCfgType; (*Pointer to the configuration structure*)
		pSF_In_DiagCode : REFERENCE TO UINT; (*Reference to the safety-to-gray UINT channel that reports SF_EDM fub DiagCode*)
		pSI_In_SafeModuleOK : REFERENCE TO BOOL; (*Reference to the SO card input SafeModuleOK*)
		pSI_In_DigitalOutFdbk : REFERENCE TO BOOL; (*Reference to the SI card input for the feedback status of the controlled digital output channel*)
		pSO_In_OutputCurrentOK : REFERENCE TO BOOL; (*Reference to the SO card's monitoring of channel current for the controlled digital output channel*)
		pSO_In_OutputInterlockStates : REFERENCE TO UINT; (*Reference to the SO card output interlocking states (each channel is 1 nibble in the range of 16#0 - 16#F)*)
	END_VAR
	VAR_OUTPUT
		Error : BOOL; (*Show that an error has occured to prevent output*)
		DiagCode : UINT; (*Show diagnostic code based on available monitoring capability*)
		Diag : SContactorDiagType; (*Show diagnostic info based on available monitoring capability*)
		Status : SContactorStatusType; (*Show that safety digiral output is energized*)
		Simulation : SContactorSimulationType; (*Show simulated I/O values based on fub input Cmd.Simulation.SimMonitorErrors*)
	END_VAR
	VAR
		Internal : SContactorInternalType; (*Internal variables*)
	END_VAR
END_FUNCTION_BLOCK
(*mapp Safety-compatible X20SO21xx/X20SO41xx output error diagnosis*)

FUNCTION_BLOCK SfContactor (*Dual-channel safe digital output control and monitoring, example use includes redundant safety contactor control*)
	VAR_INPUT
		Cmd : SContactorCmdType; (*Request to energize output*)
		pSO_Out_Contactor1 : REFERENCE TO BOOL; (*Reference to the SO card output for contactor coil 1*)
		pSO_Out_Contactor2 : REFERENCE TO BOOL; (*Reference to the SO card output for contactor coil 2*)
		pSO_In_SafeModuleOK : REFERENCE TO BOOL; (*Reference to the SO card input SafeModuleOK*)
		pSO_In_Output1PhysicalState : REFERENCE TO BOOL; (*Reference to the SO card input PhysicalStateChannelX for contactor coil 1*)
		pSO_In_Output2PhysicalState : REFERENCE TO BOOL; (*Reference to the SO card input PhysicalStateChannelY for contactor coil 2*)
		Config : SfContactorCfgType; (*Pointer to the configuration structure*)
		pSF_In_DiagCode : REFERENCE TO UINT; (*Reference to the safety-to-gray UINT channel that reports SF_EDM fub DiagCode*)
		pSI_In_SafeModuleOK : REFERENCE TO BOOL; (*Reference to the SO card input SafeModuleOK*)
		pSI_In_Contactor1Fdbk : REFERENCE TO BOOL; (*Reference to the SI card input for the feedback status of contactor coil 1*)
		pSI_In_Contactor2Fdbk : REFERENCE TO BOOL; (*Reference to the SI card input for the feedback status of contactor coil 2*)
		pSO_In_Output1CurrentOK : REFERENCE TO BOOL; (*Reference to the SO card's monitoring of channel current for contactor coil 1*)
		pSO_In_Output2CurrentOK : REFERENCE TO BOOL; (*Reference to the SO card's monitoring of channel current for contactor coil 2*)
		pSO_In_OutputInterlockStates : REFERENCE TO USINT; (*Reference to the SO card output interlocking states (each channel is 1 nibble in the range of 16#0 - 16#F)*)
	END_VAR
	VAR_OUTPUT
		Error : BOOL; (*Show that an error has occured to prevent output*)
		DiagCode : UINT; (*Show diagnostic code based on available monitoring capability*)
		Diag : SContactorDiagType; (*Show diagnostic info based on available monitoring capability*)
		Status : SContactorStatusType; (*Show that both safety contactor outputs are energized (safety contactors are not necessarily closed)*)
		Simulation : SContactorSimulationType; (*Show simulated I/O values based on fub input Cmd.Simulation.SimMonitorErrors*)
	END_VAR
	VAR
		Internal : SfContactorInternalType; (*Internal variables*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK SfDigitalOut (*Single-channel safe digital output control and monitoring, example use includes gas dump valve control*)
	VAR_INPUT
		Cmd : SContactorCmdType; (*Request to energize output*)
		pSO_Out_DigitalOut : REFERENCE TO BOOL; (*Reference to the SO card digital output channel*)
		pSO_In_SafeModuleOK : REFERENCE TO BOOL; (*Reference to the SO card input SafeModuleOK*)
		pSO_In_OutputPhysicalState : REFERENCE TO BOOL; (*Reference to the SO card input PhysicalStateChannelX for the controlled digital output channel*)
		Config : SDigitalOutCfgType; (*Pointer to the configuration structure*)
		pSF_In_DiagCode : REFERENCE TO UINT; (*Reference to the safety-to-gray UINT channel that reports SF_EDM fub DiagCode*)
		pSI_In_SafeModuleOK : REFERENCE TO BOOL; (*Reference to the SO card input SafeModuleOK*)
		pSI_In_DigitalOutFdbk : REFERENCE TO BOOL; (*Reference to the SI card input for the feedback status of the controlled digital output channel*)
		pSO_In_OutputCurrentOK : REFERENCE TO BOOL; (*Reference to the SO card's monitoring of channel current for the controlled digital output channel*)
		pSO_In_OutputInterlockStates : REFERENCE TO USINT; (*Reference to the SO card output interlocking states (each channel is 1 nibble in the range of 16#0 - 16#F)*)
	END_VAR
	VAR_OUTPUT
		Error : BOOL; (*Show that an error has occured to prevent output*)
		DiagCode : UINT; (*Show diagnostic code based on available monitoring capability*)
		Diag : SContactorDiagType; (*Show diagnostic info based on available monitoring capability*)
		Status : SContactorStatusType; (*Show that safety digiral output is energized*)
		Simulation : SContactorSimulationType; (*Show simulated I/O values based on fub input Cmd.Simulation.SimMonitorErrors*)
	END_VAR
	VAR
		Internal : SfContactorInternalType; (*Internal variables*)
	END_VAR
END_FUNCTION_BLOCK
