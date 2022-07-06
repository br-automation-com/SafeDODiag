(*
This fub has four monitoring options, ordered by priority below:
1) SF_EDM DiagCode from safety CPU (highest priority)
2) external contactor state monitoring (using SafeDigitalInput0x from SI card)
3) internal contactor wiring monitoring (using CurrentOK0x from SO card)
4) output interlock state monitoring (using FBK_Status_1 from SO card) (lowest priority)
If more than one monitoring options are enabled, the highest priority option will be used by the fub to evaluate contactor open/close behavior.
##################################################*)

FUNCTION_BLOCK SDigitalOut
	
	//########## Simulation input handling ##########
	IF ( Cmd.Simulation.EnableSim ) THEN
		Simulation.Input.SI_In_SafeModuleOK	:= TRUE;
		Simulation.Input.SO_In_SafeModuleOK	:= TRUE;
		
		Internal.i	:= TIME_TO_UDINT( clock_ms() ) MOD 200;
		
		//########## SDigitalOut single-channel input simulation ##########
		// SimMonitorErrors bits (when set to TRUE):
		//  0: output X blocked by safety (interlock)
		//  1: output X blocked by safety (interlock)
		//  2: output X wire break (current)
		//  3: output X wire break (current)
		//  4: fdbk X stuck on high/"contactor open" (fdbk)
		//  5: fdbk X stuck on high/"contactor open" (fdbk)
		//  6: fdbk X stuck on low/"contactor closed" (fdbk)
		//  7: fdbk X stuck on low/"contactor closed" (fdbk)
		
		// simulate interlock feedback
		IF ( Cmd.Simulation.SimMonitorErrors.0 OR Cmd.Simulation.SimMonitorErrors.1 ) THEN
			Simulation.Input.SO_In_Output1PhysicalState	:= FALSE;
			Simulation.Input.InterlockStateOutput1		:= 8;
		ELSE
			Simulation.Input.SO_In_Output1PhysicalState	:= Simulation.Output.SO_Out_Contactor1 AND ( Simulation.Input.SO_In_Output1PhysicalState OR ( Internal.i >= 0	AND Internal.i < 50 ) );
			IF ( Simulation.Input.SO_In_Output1PhysicalState ) THEN
				Simulation.Input.InterlockStateOutput1	:= 9;
			ELSE
				Simulation.Input.InterlockStateOutput1	:= 7;
			END_IF
		END_IF
		
		// simulate current ok feedback
		IF ( Cmd.Simulation.SimMonitorErrors.2 OR Cmd.Simulation.SimMonitorErrors.3 ) THEN
			Simulation.Input.SO_In_Output1CurrentOK	:= FALSE;
		ELSE
			Simulation.Input.SO_In_Output1CurrentOK	:= Simulation.Input.SO_In_Output1PhysicalState AND ( Simulation.Input.SO_In_Output1CurrentOK OR ( Internal.i >= 30	AND Internal.i < 80 ) );
		END_IF
		
		// simulate external monitoring feedback
		IF ( Cmd.Simulation.SimMonitorErrors.4 OR Cmd.Simulation.SimMonitorErrors.5 ) THEN
			Simulation.Input.SI_In_Contactor1Fdbk	:= TRUE;
		ELSIF ( Cmd.Simulation.SimMonitorErrors.6 OR Cmd.Simulation.SimMonitorErrors.7 ) THEN
			Simulation.Input.SI_In_Contactor1Fdbk	:= FALSE;
		ELSE
			IF ( Internal.i >= 60 AND Internal.i < 110 ) THEN
				IF ( Simulation.Input.SO_In_Output1CurrentOK ) THEN
					Simulation.Input.SI_In_Contactor1Fdbk	:= FALSE;
				ELSE
					Simulation.Input.SI_In_Contactor1Fdbk	:= TRUE;
				END_IF
			END_IF
		END_IF
		Simulation.Input.SI_In_Contactor2Fdbk		:= Simulation.Input.SI_In_Contactor1Fdbk;
		Simulation.Input.SO_In_Output2PhysicalState	:= Simulation.Input.SO_In_Output1PhysicalState;
		Simulation.Input.SO_In_Output2CurrentOK		:= Simulation.Input.SO_In_Output1CurrentOK;
		Simulation.Input.InterlockStateOutput2		:= Simulation.Input.InterlockStateOutput1;
		
		//########## DiagCode simulation ##########
		SimAction_DiagCode;
		
		//########## SDigitalOut single-channel input source assignment ##########
		Internal.Input.SF_In_DiagCode		:= Simulation.Input.SF_In_DiagCode;
		Internal.Input.SI_In_SafeModuleOK		:= Simulation.Input.SI_In_SafeModuleOK;
		Internal.Input.SI_In_Contactor1Fdbk		:= Simulation.Input.SI_In_Contactor1Fdbk;
		Internal.Input.SI_In_Contactor2Fdbk		:= Simulation.Input.SI_In_Contactor2Fdbk;
		Internal.Input.SO_In_SafeModuleOK			:= Simulation.Input.SO_In_SafeModuleOK;
		Internal.Input.SO_In_Output1PhysicalState	:= Simulation.Input.SO_In_Output1PhysicalState;
		Internal.Input.SO_In_Output2PhysicalState	:= Simulation.Input.SO_In_Output2PhysicalState;
		Internal.Input.SO_In_Output1CurrentOK		:= Simulation.Input.SO_In_Output1CurrentOK;
		Internal.Input.SO_In_Output2CurrentOK		:= Simulation.Input.SO_In_Output2CurrentOK;
		CASE Config.InterlockState.ChannelSelector OF
			1:
				Internal.Input.SO_In_OutputInterlockStates	:= Simulation.Input.InterlockStateOutput1;
			2:
				Internal.Input.SO_In_OutputInterlockStates	:= Simulation.Input.InterlockStateOutput1 * 16#10;
			3:
				Internal.Input.SO_In_OutputInterlockStates	:= Simulation.Input.InterlockStateOutput1 * 16#100;
			4:
				Internal.Input.SO_In_OutputInterlockStates	:= Simulation.Input.InterlockStateOutput1 * 16#1000;
			ELSE
				Internal.Input.SO_In_OutputInterlockStates	:= 0;
		END_CASE
		
	ELSE
		//########## SDigitalOut single-channel input source assignment ##########
		IF ( ADR(pSF_In_DiagCode) > 0 ) THEN
			Internal.Input.SF_In_DiagCode		:= pSF_In_DiagCode;
		ELSE
			Internal.Input.SF_In_DiagCode		:= 0;
		END_IF
		IF ( ADR(pSI_In_SafeModuleOK) > 0 ) THEN
			Internal.Input.SI_In_SafeModuleOK	:= pSI_In_SafeModuleOK;
		ELSE
			Internal.Input.SI_In_SafeModuleOK	:= 0;
		END_IF
		IF ( ADR(pSI_In_DigitalOutFdbk) > 0 ) THEN
			Internal.Input.SI_In_Contactor1Fdbk	:= pSI_In_DigitalOutFdbk;
		ELSE
			Internal.Input.SI_In_Contactor1Fdbk	:= 0;
		END_IF
		IF ( ADR(pSO_In_SafeModuleOK) > 0 ) THEN
			Internal.Input.SO_In_SafeModuleOK			:= pSO_In_SafeModuleOK;
		ELSE
			Internal.Input.SO_In_SafeModuleOK			:= 0;
		END_IF
		IF ( ADR(pSO_In_OutputPhysicalState) > 0 ) THEN
			Internal.Input.SO_In_Output1PhysicalState	:= pSO_In_OutputPhysicalState;
		ELSE
			Internal.Input.SO_In_Output1PhysicalState	:= 0;
		END_IF
		IF ( ADR(pSO_In_OutputCurrentOK) > 0 ) THEN
			Internal.Input.SO_In_Output1CurrentOK		:= pSO_In_OutputCurrentOK;
		ELSE
			Internal.Input.SO_In_Output1CurrentOK		:= 0;
		END_IF
		IF ( ADR(pSO_In_OutputInterlockStates) > 0 ) THEN
			Internal.Input.SO_In_OutputInterlockStates	:= pSO_In_OutputInterlockStates;
		ELSE
			Internal.Input.SO_In_OutputInterlockStates	:= 0;
		END_IF
		Internal.Input.SI_In_Contactor2Fdbk			:= Internal.Input.SI_In_Contactor1Fdbk;
		Internal.Input.SO_In_Output2PhysicalState	:= Internal.Input.SO_In_Output1PhysicalState;
		Internal.Input.SO_In_Output2CurrentOK		:= Internal.Input.SO_In_Output1CurrentOK;
		//########## Reset simulation inputs ##########
		brsmemset( ADR(Simulation.Input), 0, SIZEOF(Simulation.Input) );
		
	END_IF
	
	
	//########## SDigitalOut single-channel output interlock state identification ##########
	// Read output channel interlock state
	IF ( Config.InterlockState.EnableMon ) THEN
		CASE Config.InterlockState.ChannelSelector OF
			1:
				Internal.Input.InterlockStateOutput1 := UINT_TO_USINT( Internal.Input.SO_In_OutputInterlockStates AND 16#000F );
			2:
				Internal.Input.InterlockStateOutput1 := UINT_TO_USINT( SHR(( Internal.Input.SO_In_OutputInterlockStates AND 16#00F0 ), 4) );
			3:
				Internal.Input.InterlockStateOutput1 := UINT_TO_USINT( SHR(( Internal.Input.SO_In_OutputInterlockStates AND 16#0F00 ), 8) );
			4:
				Internal.Input.InterlockStateOutput1 := UINT_TO_USINT( SHR(( Internal.Input.SO_In_OutputInterlockStates AND 16#F000 ), 12) );
			ELSE
				Internal.Input.InterlockStateOutput1 := 0;
		END_CASE
	ELSE
		Internal.Input.InterlockStateOutput1 := 0;
	END_IF
	Internal.Input.InterlockStateOutput2 := Internal.Input.InterlockStateOutput1;
	
	
	//########## Feedback interpretation and error state transition ##########
	StateAction_CommonPre;
	
	
	//########## State machine for processing feedback values ##########
	CASE Internal.State OF
		
		SC_CFG:
			//#################### Req. Checkout ####################
			IF ( ADR(pSO_In_SafeModuleOK) = 0 ) THEN // Check if the monitoring of safe communication to SO node exists
				DiagCode			:= 16#F001;
				Diag.ErrorConfig	:= TRUE;
				Diag.DiagText		:= 'NoSafeDOCardOkADR';
			ELSIF ( ADR(pSO_Out_DigitalOut) = 0 ) THEN // Check if output channel exists
				DiagCode			:= 16#F002;
				Diag.ErrorConfig	:= TRUE;
				Diag.DiagText		:= 'NoSafeDigitalOutADR';
			ELSIF ( ADR(pSO_In_OutputPhysicalState) = 0 ) THEN // Check if the output phsical state monitoring exists
				DiagCode			:= 16#F004;
				Diag.ErrorConfig	:= TRUE;
				Diag.DiagText		:= 'NoOutputPhysicalStateADR';
			END_IF
			// No MonitorTime for PhysicalState because we don't know when the safety CPU will approve output enable request
			
			//#################### Check the setup of safety-to-gray comm of SF_EDM fub DiagCode monitor ##################
			IF ( Config.DiagCode.EnableMon AND NOT(Diag.ErrorConfig) ) THEN
				IF ( ADR(pSF_In_DiagCode) = 0 ) THEN // Check if the monitoring of DiagCode from safety CPU exists
					DiagCode			:= 16#F010;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'NoDiagCodeADR';
				ELSIF ( ADR(pSI_In_SafeModuleOK) = 0 ) THEN // Check if the monitoring of safe communication to SI node exists
					DiagCode			:= 16#F011;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'NoSafeDICardOkADR';
				ELSIF ( ADR(pSI_In_DigitalOutFdbk) = 0 ) THEN // Need an SI card input to monitor
					DiagCode			:= 16#F012;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'NoDigitalOutFdbkADR';
				ELSIF ( Config.DiagCode.StartDelayTime = 0 ) THEN // Check time range
					DiagCode			:= 16#F020;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'NoStartDelay';
				ELSIF ( Config.DiagCode.StartDelayTime > T#10s ) THEN // Check time range
					DiagCode			:= 16#F021;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'StartDelayTooLong';
				ELSIF ( Config.DiagCode.ResetDelayTime = 0 ) THEN // Check time range
					DiagCode			:= 16#F022;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'NoResetDelay';
				ELSIF ( Config.DiagCode.ResetDelayTime > T#10s ) THEN // Check time range
					DiagCode			:= 16#F023;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'ResetDelayTooLong';
				END_IF
			
			//#################### Check the setup of Contactor Feedback monitor ####################
			ELSIF ( Config.Fdbk.EnableMon AND NOT(Diag.ErrorConfig) ) THEN
				IF ( ADR(pSI_In_SafeModuleOK) = 0 ) THEN // Check if the monitoring of safe communication to SI node exists
					DiagCode			:= 16#F011;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'NoSafeDICardOkADR';
				ELSIF ( ADR(pSI_In_DigitalOutFdbk) = 0 ) THEN // Need an SI card input to monitor
					DiagCode			:= 16#F012;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'NoDigitalOutFdbkADR';
				ELSIF ( Config.Fdbk.StartDelayTime = 0 ) THEN // Check time range
					DiagCode			:= 16#F020;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'NoStartDelay';
				ELSIF ( Config.Fdbk.StartDelayTime > T#10s ) THEN // Check time range
					DiagCode			:= 16#F021;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'StartDelayTooLong';
				ELSIF ( Config.Fdbk.MonitorTime = 0 ) THEN // Check time range
					DiagCode			:= 16#F024;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'NoMonitorTime';
				ELSIF ( Config.Fdbk.MonitorTime > T#2s ) THEN // Check time range
					DiagCode			:= 16#F025;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'MonitorTimeTooLong';
				END_IF
			
			//#################### Check the setup of Output Current monitor ##################
			ELSIF ( Config.Current.EnableMon AND NOT(Diag.ErrorConfig) ) THEN
				IF ( ADR(pSO_In_OutputCurrentOK) = 0 ) THEN
					DiagCode			:= 16#F014;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'NoOutputCurrentOkADR';
				ELSIF ( Config.Current.MonitorTime = 0 ) THEN // Check time range
					DiagCode			:= 16#F024;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'NoMonitorTime';
				ELSIF ( Config.Current.MonitorTime > T#2s ) THEN // Check time range
					DiagCode			:= 16#F025;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'MonitorTimeTooLong';
				END_IF
			
			//#################### Check the setup of Output Interlock monitor ##################
			ELSIF ( Config.InterlockState.EnableMon AND NOT(Diag.ErrorConfig) ) THEN
				IF ( ADR(pSO_In_OutputInterlockStates) = 0 ) THEN
					DiagCode			:= 16#F016;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'NoOutputInterlockStateADR';
				ELSIF ( Config.InterlockState.MonitorTime = 0 ) THEN // Check time range
					DiagCode			:= 16#F024;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'NoMonitorTime';
				ELSIF ( Config.InterlockState.MonitorTime > T#1s ) THEN // Check time range
					DiagCode			:= 16#F025;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'MonitorTimeTooLong';
				ELSIF ( (Config.InterlockState.ChannelSelector < 1) OR (Config.InterlockState.ChannelSelector > 4)) THEN
					DiagCode			:= 16#F026;
					Diag.ErrorConfig	:= TRUE;
					Diag.DiagText		:= 'InvalidOutputInterlockChannelSelector';
				END_IF
			END_IF
			
			//#################### SUCCESS!!! ##################
			IF NOT( Diag.ErrorConfig ) THEN
				Internal.StateGoTo	:= SC_INIT;
			END_IF
			
			
		SC_INIT:
			StateAction_Init;
			
			
		SC_DISABLED:
			StateAction_Disabled;
			
			
		SC_ENABLED:
			StateAction_Enabled;
			
			
		SC_ERROR:
			StateAction_Error;
			
		ELSE
			//The code should not end uzp here. Report the error as unknown.
			Diag.ErrorInternal	:= TRUE;
			DiagCode			:= 16#CFFF;
			Diag.DiagText		:= 'UndocumentedError';
			
	END_CASE
	
	
	//########## Update fub outputs ##########
	// Update fub error output
	Error := Diag.ErrorSafeFub OR Diag.ErrorInterlock OR Diag.ErrorCurrent OR Diag.ErrorFdbk OR Diag.ErrorConfig OR Diag.ErrorInternal;
	
	// Update fub IO status outputs
	IF ( Internal.State > SC_CFG ) THEN
		// Update IOSP outputs after fub cfg is successful
		Internal.Output.SO_Out_Contactor1	:= Cmd.OutputRequest;
		Internal.Output.SO_Out_Contactor2	:= Cmd.OutputRequest;
		
		// Update fub status outputs based on IOSP dual-channel agreement
		Status.OutputActive		:= Internal.Input.SO_In_Output1PhysicalState AND Internal.Input.SO_In_Output2PhysicalState; // both channels need to activate to energize, so all dual-channel diagreements are treated as inactive
		Status.OutputRequested	:= Internal.Output.SO_Out_Contactor1 AND Internal.Output.SO_Out_Contactor2; // both channels need to activate to energize, so all dual-channel diagreements are treated as no request
	ELSE
		// disable IOSP output during CFG state or ERROR state
		Internal.Output.SO_Out_Contactor1	:= FALSE;
		Internal.Output.SO_Out_Contactor2	:= FALSE;
		
		// Update fub status output based on available SDigitalOut single-channel IOSP data
		Status.OutputActive		:= Internal.Input.SO_In_Output1PhysicalState; // Because there is only one channel, SDigitalOut can always show status based on Internal.Input.SO_In_Output1PhysicalState
		Status.OutputRequested	:= FALSE;
	END_IF
	
	// Disable internal EDM reset request after a jump out of init state that's not made within the state machine (presumably into error state)
	// Note: Error state sets internal EDM reset request on rising edge of error acknowledgement, so error state needs to disable EDM reset on its own
	IF ( Internal.Prev.State = SC_INIT AND Internal.State <> SC_INIT ) THEN
		Internal.EDMReset	:= FALSE;
	END_IF
	// Pass through safety reset request in all fub states
	Status.SafetyResetRequested	:= Cmd.Reset OR Internal.EDMReset;
	
	
	//########## SDigitalOut single-channel simulation output handling ##########
	IF ( Cmd.Simulation.EnableSim ) THEN
		//########## Output destination assignment ##########
		Simulation.Output.SO_Out_Contactor1	:= Internal.Output.SO_Out_Contactor1;
		Simulation.Output.SO_Out_Contactor2	:= Internal.Output.SO_Out_Contactor2;
		//########## Reset real outputs ##########
		IF ( ADR(pSO_Out_DigitalOut) > 0 ) THEN
			pSO_Out_DigitalOut	:= FALSE;
		END_IF
	ELSE
		//########## Output destination assignment ##########
		IF ( ADR(pSO_Out_DigitalOut) > 0 ) THEN
			pSO_Out_DigitalOut	:= Internal.Output.SO_Out_Contactor1;
		END_IF
		//########## Reset simulation outputs ##########
		Simulation.Output.SO_Out_Contactor1	:= FALSE;
		Simulation.Output.SO_Out_Contactor2	:= FALSE;
	END_IF
	
	
	//########## Update internal process ##########
	StateAction_CommmonAft;
	
END_FUNCTION_BLOCK
