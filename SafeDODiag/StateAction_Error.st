
ACTION StateAction_Error:
	
	// Only clear fub error on the rising edge of reset request
			// Reset Error and DiagCode outputs if alarms were acknowledged by command or via reset in the alarm system
	IF( Cmd.Reset AND NOT( Internal.Prev.Reset ) )THEN
		IF ( Diag.ErrorConfig ) THEN
			Diag.ErrorConfig	:= FALSE;
			Diag.DiagText		:= '';
			DiagCode			:= 0;
			// Go back to the config state
			Internal.StateGoTo	:= SC_CFG;
		ELSIF ( Diag.ErrorSafeFub ) THEN
			// Give SF_EDM fub enough time to react to error reset
			Internal.Fub.TON_EDMResetDelay.IN := TRUE;
			Internal.EDMReset	:= TRUE;
		ELSE
			Diag.ErrorFdbk		:= FALSE;
			Diag.ErrorCurrent	:= FALSE;
			Diag.ErrorInterlock	:= FALSE;
			Diag.DiagText		:= '';
			DiagCode			:= 0;
			// Go into the disabled state
			Internal.StateGoTo	:= SC_DISABLED;
		END_IF
	END_IF
			
	// After EDM reset delay timeout, go into the disabled state
	IF ( Internal.Fub.TON_EDMResetDelay.Q ) THEN
		Internal.Fub.TON_EDMResetDelay.IN := FALSE;
		Diag.ErrorSafeFub	:= FALSE;
		Diag.DiagText		:= '';
		DiagCode			:= 0;
		Internal.EDMReset	:= FALSE;
		Internal.StateGoTo	:= SC_DISABLED;
	END_IF
	
END_ACTION
