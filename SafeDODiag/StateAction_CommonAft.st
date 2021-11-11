
ACTION StateAction_CommmonAft:
	
	// Run timers
	Internal.Fub.TON_EDMMonitorSim.PT	:= T#200ms;
	Internal.Fub.TON_EDMMonitorSim();	
	Internal.Fub.TON_EDMStartDelay.PT	:= Config.DiagCode.StartDelayTime;
	Internal.Fub.TON_EDMStartDelay();
	Internal.Fub.TON_EDMResetDelay.PT	:= Config.DiagCode.ResetDelayTime;
	Internal.Fub.TON_EDMResetDelay();
	Internal.Fub.TON_FdbkStartDelay.PT	:= Config.Fdbk.StartDelayTime;
	Internal.Fub.TON_FdbkStartDelay();
	Internal.Fub.TON_Fdbk.PT			:= Config.Fdbk.MonitorTime;
	Internal.Fub.TON_Fdbk();
	Internal.Fub.TON_Current.PT			:= Config.Current.MonitorTime;
	Internal.Fub.TON_Current();
	Internal.Fub.TON_InterlockStartDelay.PT	:= Config.InterlockState.StartDelayTime;
	Internal.Fub.TON_InterlockStartDelay();
	Internal.Fub.TON_Interlock.PT			:= Config.InterlockState.MonitorTime;
	Internal.Fub.TON_Interlock();
	// Reset timers by default and wait for the state machine to override the default, so any state transition that's
	// not made within the state machine (e.g. global jump into error state) will automatically disable abandoned timers
	Internal.Fub.TON_EDMStartDelay.IN		:= FALSE;
	Internal.Fub.TON_FdbkStartDelay.IN		:= FALSE;
	Internal.Fub.TON_Fdbk.IN				:= FALSE;
	Internal.Fub.TON_Current.IN				:= FALSE;
	Internal.Fub.TON_InterlockStartDelay.IN	:= FALSE;
	Internal.Fub.TON_Interlock.IN			:= FALSE;
	IF ( Internal.State <> SC_ERROR ) THEN
		Internal.Fub.TON_EDMResetDelay.IN	:= FALSE;
	END_IF
	
	// Help to check for changes in input values
	Internal.Prev.Reset			:= Cmd.Reset;
	Internal.Prev.EnDiagCode	:= Config.DiagCode.EnableMon;
	Internal.Prev.EnFdbk		:= Config.Fdbk.EnableMon;
	Internal.Prev.EnCurrent		:= Config.Current.EnableMon;
	Internal.Prev.EnInterlock	:= Config.InterlockState.EnableMon;
	Internal.Prev.SimOutput1	:= Simulation.Input.SO_In_Output1PhysicalState;
	Internal.Prev.SimOutput2	:= Simulation.Input.SO_In_Output2PhysicalState;
	
END_ACTION
