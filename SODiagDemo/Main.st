PROGRAM _INIT
	// Essential IO
	SafeContactorFub.pSO_Out_Contactor1	:= ADR(IOSP.Output.Contactor1EnergizeRequest);
	SafeContactorFub.pSO_Out_Contactor2	:= ADR(IOSP.Output.Contactor2EnergizeRequest);
	SafeContactorFub.pSO_In_SafeModuleOK			:= ADR(IOSP.Input.ContactorSOModuleOK);
	SafeContactorFub.pSO_In_Output1PhysicalState	:= ADR(IOSP.Input.Contactor1EnergizeState);
	SafeContactorFub.pSO_In_Output2PhysicalState	:= ADR(IOSP.Input.Contactor2EnergizeState);
	
	MpSafeContactorFub.pSO_Out_Contactor1	:= ADR(IOSP.Output.Contactor1EnergizeRequest);
	MpSafeContactorFub.pSO_Out_Contactor2	:= ADR(IOSP.Output.Contactor2EnergizeRequest);
	MpSafeContactorFub.pSO_In_SafeModuleOK			:= ADR(IOSP.Input.ContactorSOModuleOK);
	MpSafeContactorFub.pSO_In_Output1PhysicalState	:= ADR(IOSP.Input.Contactor1EnergizeState);
	MpSafeContactorFub.pSO_In_Output2PhysicalState	:= ADR(IOSP.Input.Contactor2EnergizeState);
	
	(*##################################################
	This fub has four monitoring options, ordered by priority below:
	1) SF_EDM DiagCode from safety CPU (highest priority)
	2) external contactor state monitoring (using SafeDigitalInput0x from SI card)
	3) internal contactor wiring monitoring (using CurrentOK0x from SO card) (lowest priority)
	4) output interlock state monitoring (using FBK_Status_1 from SO card) (independent from and supplementing other monitor options)
	If more than one monitoring options are enabled, the highest priority option will be used by the fub to evaluate contactor open/close behavior.
	##################################################*)
	
	// These inputs are required by DiagCode monitor and feedback monitor
	SafeContactorFub.pSI_In_SafeModuleOK		:= ADR(IOSP.Input.FdbkSIModuleOK);
	SafeContactorFub.pSI_In_Contactor1Fdbk		:= ADR(IOSP.Input.Contactor1Fdbk);
	SafeContactorFub.pSI_In_Contactor2Fdbk		:= ADR(IOSP.Input.Contactor2Fdbk);
	
	MpSafeContactorFub.pSI_In_SafeModuleOK		:= ADR(IOSP.Input.FdbkSIModuleOK);
	MpSafeContactorFub.pSI_In_Contactor1Fdbk	:= ADR(IOSP.Input.Contactor1Fdbk);
	MpSafeContactorFub.pSI_In_Contactor2Fdbk	:= ADR(IOSP.Input.Contactor2Fdbk);
	
	
	// These inputs are required by DiagCode monitor
//	SafeContactorFub.Config.CfgDiagCode.EnableMon		:= TRUE;
	SafeContactorFub.Config.DiagCode.StartDelayTime		:= T#2s;	// fub default is 3s but it can be adjusted during fub call like this
	SafeContactorFub.Config.DiagCode.ResetDelayTime		:= T#500ms;	// fub default of 1s may be too longer, so this example uses a shorter delay
	SafeContactorFub.pSF_In_DiagCode					:= ADR(IOSP.Input.EDMDiagCode);
	
//	MpSafeContactorFub.Config.CfgDiagCode.EnableMon		:= TRUE;
	MpSafeContactorFub.Config.DiagCode.StartDelayTime	:= T#2s;	// fub default is 3s but it can be adjusted during fub call like this
	MpSafeContactorFub.Config.DiagCode.ResetDelayTime	:= T#500ms;	// fub default of 1s may be too longer, so this example uses a shorter delay
	MpSafeContactorFub.pSF_In_DiagCode					:= ADR(IOSP.Input.EDMDiagCode);
	
	
	// These inputs are required by DiagCode monitor and feedback monitor
//	SafeContactorFub.Config.CfgFdbk.EnableMon		:= TRUE;
	SafeContactorFub.Config.Fdbk.StartDelayTime		:= T#2s;	// fub default is 3s but it can be adjusted during fub call like this
	SafeContactorFub.Config.Fdbk.MonitorTime		:= T#200ms;	// no fub default; a value needs to be specified
	
//	MpSafeContactorFub.Config.CfgFdbk.EnableMon		:= TRUE;
	MpSafeContactorFub.Config.Fdbk.StartDelayTime	:= T#2s;	// fub default is 3s but it can be adjusted during fub call like this
	MpSafeContactorFub.Config.Fdbk.MonitorTime		:= T#200ms;	// no fub default; a value needs to be specified
	
	
	// These inputs are required by current OK monitor
//	SafeContactorFub.Config.CfgCurrent.EnableMon	:= TRUE;
	SafeContactorFub.pSO_In_Output1CurrentOK		:= ADR(IOSP.Input.Contactor2EnergizeCurrentOK);
	SafeContactorFub.pSO_In_Output2CurrentOK		:= ADR(IOSP.Input.Contactor2EnergizeCurrentOK);
	SafeContactorFub.Config.Current.MonitorTime		:= T#200ms;	// no fub default; a value needs to be specified
	
//	MpSafeContactorFub.Config.CfgCurrent.EnableMon	:= TRUE;
	MpSafeContactorFub.pSO_In_Output1CurrentOK		:= ADR(IOSP.Input.Contactor2EnergizeCurrentOK);
	MpSafeContactorFub.pSO_In_Output2CurrentOK		:= ADR(IOSP.Input.Contactor2EnergizeCurrentOK);
	MpSafeContactorFub.Config.Current.MonitorTime	:= T#200ms;	// no fub default; a value needs to be specified
	
	
	// These inputs are required by output interlock monitor
//	SafeContactorFub.Config.CfgInterlockState.EnableMon			:= TRUE;
	SafeContactorFub.pSO_In_OutputInterlockStates				:= ADR(IOSP.Input.ContactorOutputInterlockStatesSR);
	SafeContactorFub.Config.InterlockState.ChannelPairSelector	:= 1;
	SafeContactorFub.Config.InterlockState.StartDelayTime		:= T#2s;	// fub default is 3s but it can be adjusted during fub call like this
	SafeContactorFub.Config.InterlockState.MonitorTime			:= T#200ms;	// no fub default; a value needs to be specified
	
//	MpSafeContactorFub.Config.CfgInterlockState.EnableMon		:= TRUE;
	MpSafeContactorFub.pSO_In_OutputInterlockStates				:= ADR(IOSP.Input.ContactorOutputInterlockStatesMP);
	MpSafeContactorFub.Config.InterlockState.StartDelayTime		:= T#2s;	// fub default is 3s but it can be adjusted during fub call like this
	MpSafeContactorFub.Config.InterlockState.MonitorTime		:= T#200ms;	// no fub default; a value needs to be specified
	
	
	SafeContactorFub.Cmd.Simulation.EnableSim	:= DiagCpuIsARsim();
	MpSafeContactorFub.Cmd.Simulation.EnableSim	:= DiagCpuIsARsim();
END_PROGRAM

PROGRAM _CYCLIC
	// Read inputs
	brsmemcpy( ADR( IOSP.Input ), ADR( IO.Input ), SIZEOF( IOSP.Input ) );
	
	IF bToggleMappSafetyVsSafetyRelease THEN // use mapp Safety-compatible fubs
		IF( bToggleSingleVsDualOutputs )THEN
			// Check for user output request
			MpSafeDigitalOutFub.Cmd.OutputRequest	:= bRequestOutput;
			// Check for user reset request of SF_EDM error
			MpSafeDigitalOutFub.Cmd.Reset			:= bReset;
			
			// Run fub
			MpSafeDigitalOutFub();
			
			// Pass through SF_EDM reset request
			IOSP.Output.EDMReset					:= MpSafeDigitalOutFub.Status.SafetyResetRequested;
		ELSE
			// Check for user output request
			MpSafeContactorFub.Cmd.OutputRequest	:= bRequestOutput;
			// Check for user reset request of SF_EDM error
			MpSafeContactorFub.Cmd.Reset			:= bReset;
			
			// Run fub
			MpSafeContactorFub();
			
			// Pass through SF_EDM reset request
			IOSP.Output.EDMReset					:= MpSafeContactorFub.Status.SafetyResetRequested;
		END_IF
		
	ELSE // use Safety Release-compatible fubs
		IF( bToggleSingleVsDualOutputs )THEN
			// Check for user output request
			SafeDigitalOutFub.Cmd.OutputRequest	:= bRequestOutput;
			// Check for user reset request of SF_EDM error
			SafeDigitalOutFub.Cmd.Reset			:= bReset;
			
			// Run fub
			SafeDigitalOutFub();
			
			// Pass through SF_EDM reset request
			IOSP.Output.EDMReset				:= SafeDigitalOutFub.Status.SafetyResetRequested;
		ELSE
			// Check for user output request
			SafeContactorFub.Cmd.OutputRequest	:= bRequestOutput;
			// Check for user reset request of SF_EDM error
			SafeContactorFub.Cmd.Reset			:= bReset;
			
			// Run fub
			SafeContactorFub();
			
			// Pass through SF_EDM reset request
			IOSP.Output.EDMReset				:= SafeContactorFub.Status.SafetyResetRequested;
		END_IF
		
	END_IF
	
	// Write outputs
	brsmemcpy( ADR( IO.Output ), ADR( IOSP.Output ), SIZEOF( IOSP.Output ) );
END_PROGRAM

PROGRAM _EXIT
END_PROGRAM
