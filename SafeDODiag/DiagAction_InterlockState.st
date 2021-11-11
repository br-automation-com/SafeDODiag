
ACTION DiagAction_InterlockState:
	
	// Check for error state transition and feedback interpretation as long as interlock-based monitoring is enabled
	IF ( Config.InterlockState.EnableMon AND ( Internal.State > SC_INIT ) AND (
		// (Choice 1) if no other monitoring is enabled
		NOT( Config.DiagCode.EnableMon OR Config.Fdbk.EnableMon OR Config.Current.EnableMon ) OR
		// (Choice 2) if DiagCode monitoring is enabled, show Interlock monitoring-based DiagText only when DiagCode indicates "de-energized"
		( Internal.Input.SF_In_DiagCode = 16#8010 )	OR
		// (Choice 3) if any other monitoring is enabled, show Interlock monitoring-based DiagText whenever output is de-energized
		( NOT( Config.DiagCode.EnableMon ) AND ( Config.Fdbk.EnableMon OR Config.Current.EnableMon ) AND NOT( Internal.Input.SO_In_Output1PhysicalState AND Internal.Input.SO_In_Output2PhysicalState ) )
		) ) THEN
		// Go to error state if any error is reported by SO card; the most severe error is prioritized over mixed severities
		IF		Internal.Input.InterlockStateOutput1 = 16#0 // no SafeModuleOK
			OR	Internal.Input.InterlockStateOutput2 = 16#0 // no SafeModuleOK
			THEN
			DiagCode			:= 16#C300;
			Diag.ErrorInterlock	:= TRUE;
			Diag.DiagText		:= 'SafeDOCardOkTimeout';
		ELSIF	Internal.Input.InterlockStateOutput2 = 16#A // hardware/wiring error on output card/channel
			AND	Internal.Input.InterlockStateOutput1 = 16#A // hardware/wiring error on output card/channel
			THEN
			DiagCode			:= 16#C330;
			Diag.ErrorInterlock	:= TRUE;
			Diag.DiagText		:= 'SafeDOCardOutputsHwErr';
		ELSIF	Internal.Input.InterlockStateOutput2 = 16#A // hardware/wiring error on output card/channel
			THEN
			DiagCode			:= 16#C320;
			Diag.ErrorInterlock	:= TRUE;
			Diag.DiagText		:= 'SafeDOCardOutput2HwErr';
		ELSIF	Internal.Input.InterlockStateOutput1 = 16#A // hardware/wiring error on output card/channel
			THEN
			DiagCode			:= 16#C310;
			Diag.ErrorInterlock	:= TRUE;
			Diag.DiagText		:= 'SafeDOCardOutput1HwErr';
			// Except 16#C300, 16#C310, 16#C320, and 16#C330 (above), all else (below) indicate safety CPU programming errors
		ELSIF	Internal.Input.InterlockStateOutput2 = 16#5 // ReleaseOutput and SafeDigitalOutput activate at the same time
			AND	Internal.Input.InterlockStateOutput1 = 16#5 // ReleaseOutput and SafeDigitalOutput activate at the same time
			THEN
			DiagCode			:= 16#C333;
			Diag.ErrorInterlock	:= TRUE;
			Diag.DiagText		:= 'SafeDOCardOutputsSameTimePosEdgePermissionPosEdgeRelease';
		ELSIF	Internal.Input.InterlockStateOutput2 = 16#5 // ReleaseOutput and SafeDigitalOutput activate at the same time
			THEN
			DiagCode			:= 16#C322;
			Diag.ErrorInterlock	:= TRUE;
			Diag.DiagText		:= 'SafeDOCardOutput2SameTimePosEdgePermissionPosEdgeRelease';
		ELSIF	Internal.Input.InterlockStateOutput1 = 16#5 // ReleaseOutput and SafeDigitalOutput activate at the same time
			THEN
			DiagCode			:= 16#C311;
			Diag.ErrorInterlock	:= TRUE;
			Diag.DiagText		:= 'SafeDOCardOutput1SameTimePosEdgePermissionPosEdgeRelease';
		ELSIF	Internal.Input.InterlockStateOutput2 = 16#6 // ReleaseOutput already active when SafeDigitalOutput activates
			AND	Internal.Input.InterlockStateOutput1 = 16#6 // ReleaseOutput already active when SafeDigitalOutput activates
			THEN
			DiagCode			:= 16#C303;
			Diag.ErrorInterlock	:= TRUE;
			Diag.DiagText		:= 'SafeDOCardOutputsPosReleaseBeforePosEdgePermissioin';
		ELSIF	Internal.Input.InterlockStateOutput2 = 16#6 // ReleaseOutput already active when SafeDigitalOutput activates
			THEN
			DiagCode			:= 16#C302;
			Diag.ErrorInterlock	:= TRUE;
			Diag.DiagText		:= 'SafeDOCardOutput2PosReleaseBeforePosEdgePermissioin';
		ELSIF	Internal.Input.InterlockStateOutput1 = 16#6 // ReleaseOutput already active when SafeDigitalOutput activates
			THEN
			DiagCode			:= 16#C301;
			Diag.ErrorInterlock	:= TRUE;
			Diag.DiagText		:= 'SafeDOCardOutput1PosReleaseBeforePosEdgePermissioin';
		ELSIF	( Internal.Input.InterlockStateOutput1 <> 4 AND Internal.Input.InterlockStateOutput1 <> 7 AND Internal.Input.InterlockStateOutput1 <> 8 AND Internal.Input.InterlockStateOutput1 <> 9 )
			OR	( Internal.Input.InterlockStateOutput2 <> 4 AND Internal.Input.InterlockStateOutput2 <> 7 AND Internal.Input.InterlockStateOutput2 <> 8 AND Internal.Input.InterlockStateOutput2 <> 9 )
			THEN
			DiagCode			:= 16#CFFF;
			Diag.ErrorInternal	:= TRUE;
			Diag.DiagText		:= 'UndocumentedError';
		END_IF
		
		IF ( Diag.ErrorInterlock ) THEN
			Internal.StateGoTo	:= SC_ERROR;
		ELSE
			// both contactor outputs are expected to change interlock states together, so only one channel needs to satisfy the prioritized state check
			IF		( Internal.Input.InterlockStateOutput1 = 16#8 )
				OR	( Internal.Input.InterlockStateOutput2 = 16#8 ) THEN
				DiagCode		:= 16#8100;
				Diag.DiagText	:= 'RequireSafePermission';
			ELSIF	( Internal.Input.InterlockStateOutput1 = 16#7 )
				OR	( Internal.Input.InterlockStateOutput2 = 16#7 ) THEN
				DiagCode		:= 16#8010;
				Diag.DiagText	:= 'RequireOutReq';
			ELSIF	( Internal.Input.InterlockStateOutput1 = 16#4 )
				OR	( Internal.Input.InterlockStateOutput2 = 16#4 ) THEN
				// SO channel is waiting for ReleaseOutput, which should be auto-triggered by safety CPU a few ms after it sets SafeDigitalOutput
				DiagCode		:= 16#8101;
				Diag.DiagText	:= 'RequireSafeRelease';
			END_IF
		END_IF
		
	END_IF
	
END_ACTION
