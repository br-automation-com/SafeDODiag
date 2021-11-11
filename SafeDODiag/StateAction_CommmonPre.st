
ACTION StateAction_CommonPre:
	
	//########## Feedback interpretation and error state transition ##########
	// Check for error state transition that apply no matter what state the fub was in
	IF ( Error ) THEN
		// Go to error state if a process error was detected (e.g. fub cfg error, 2-channel switching discrepancy, undocumented error code)
		Internal.StateGoTo	:= SC_ERROR;
		
	ELSIF	( Config.DiagCode.EnableMon AND NOT( Internal.Prev.EnDiagCode ) )
		OR	( Config.Fdbk.EnableMon AND NOT( Internal.Prev.EnFdbk ) )
		OR	( Config.Current.EnableMon AND NOT( Internal.Prev.EnCurrent ) )
		OR	( Config.InterlockState.EnableMon AND NOT( Internal.Prev.EnInterlock ) ) THEN
		Internal.StateGoTo	:= SC_CFG;
		Diag.DiagText		:= '';
		DiagCode			:= 0;
		
		// Exclusively for DiagCode-based monitoring:
	ELSIF ( Config.DiagCode.EnableMon AND ( Internal.State > SC_INIT OR Internal.State = SC_ERROR ) ) THEN
		DiagAction_DiagCode;
	END_IF
	
	// Check for error state transition and feedback interpretation as long as interlock-based monitoring is enabled
	DiagAction_InterlockState;
	
	
	// Keep track of state changes
	Internal.Prev.State	:= Internal.State;
	Internal.State		:= Internal.StateGoTo;
	
END_ACTION
