
ACTION StateAction_Enabled:
	
	//#################### Check the SF_EDM fub DiagCode ##################
	// if DiagCode is checked, error flagged at the beginning of the fub will put the state machine into error state and skip this state
	// while non-zero DiagCode would update the DiagText at the beginning of the fub
	IF ( Config.DiagCode.EnableMon ) THEN
				
		IF ( Internal.Input.SF_In_DiagCode <> 16#8000 ) THEN
			Internal.StateGoTo	:= SC_DISABLED;
		END_IF
			
	//#################### Check the contactor feedback ##################
	ELSIF ( Config.Fdbk.EnableMon ) THEN
				
		// both fdbks need to be inactive (to mean that both contactors are closed); if either fdbk is active, start the fdbk timer to check if they deactivate before timeout
		Internal.Fub.TON_Fdbk.IN := ( Internal.Input.SI_In_Contactor1Fdbk OR Internal.Input.SI_In_Contactor2Fdbk );
				
		// Go to disabled state if SO card outputs are not both physically active during operation
		IF ( NOT( Internal.Input.SO_In_Output1PhysicalState AND Internal.Input.SO_In_Output2PhysicalState ) ) THEN
			Internal.Fub.TON_Current.IN := FALSE;
					
			Internal.StateGoTo	:= SC_DISABLED;
			IF NOT( Config.InterlockState.EnableMon ) THEN
				DiagCode		:= 16#8110;
				Diag.DiagText	:= 'De-energized';
			END_IF
					
		ELSIF ( Internal.Fub.TON_Fdbk.Q ) THEN
			Internal.Fub.TON_Fdbk.IN := FALSE;
			Diag.ErrorFdbk := TRUE; // set the error flag and it will put the state machine into error state
					
			IF NOT( Internal.Input.SI_In_Contactor1Fdbk ) THEN
				DiagCode		:= 16#C080;
				Diag.DiagText	:= 'PosFdbk2AfterPosOutReq';
			ELSIF NOT( Internal.Input.SI_In_Contactor2Fdbk ) THEN
				DiagCode		:= 16#C070;
				Diag.DiagText	:= 'PosFdbk1AfterPosOutReq';
			ELSE
				DiagCode		:= 16#C090;
				Diag.DiagText	:= 'PosFdbkAfterPosOutReq';
			END_IF
					
		ELSE
			DiagCode			:= 16#8000;
			Diag.DiagText		:= 'Energized';
		END_IF
				
	//#################### Check the output current ##################
	ELSIF ( Config.Current.EnableMon ) THEN
				
		// if both SO card output currents are not okay or if contactor current isn't above threshold, start the current timer to check if they normalize before timeout
		Internal.Fub.TON_Current.IN := NOT( Internal.Input.SO_In_Output1CurrentOK AND Internal.Input.SO_In_Output2CurrentOK );
				
		// Go to disabled state if SO card outputs are not both physically active during operation
		IF ( NOT( Internal.Input.SO_In_Output1PhysicalState AND Internal.Input.SO_In_Output2PhysicalState ) ) THEN
			Internal.Fub.TON_Current.IN := FALSE;
					
			Internal.StateGoTo	:= SC_DISABLED;
			IF NOT( Config.InterlockState.EnableMon ) THEN
				DiagCode		:= 16#8110;
				Diag.DiagText	:= 'De-energized';
			END_IF
					
		ELSIF ( Internal.Fub.TON_Current.Q) THEN
			Internal.Fub.TON_Current.IN := FALSE;
			Diag.ErrorCurrent := TRUE; // set the error flag and it will put the state machine into error state
					
			IF ( Internal.Input.SO_In_Output1CurrentOK ) THEN
				DiagCode		:= 16#C280;
				Diag.DiagText	:= 'NegCurrentOk2AfterPosOutReq';
			ELSIF ( Internal.Input.SO_In_Output2CurrentOK ) THEN
				DiagCode		:= 16#C270;
				Diag.DiagText	:= 'NegCurrentOk1AfterPosOutReq';
			ELSE
				DiagCode		:= 16#C290;
				Diag.DiagText	:= 'NegCurrentOkAfterPosOutReq';
			END_IF
					
		ELSE
			DiagCode			:= 16#8000;
			Diag.DiagText		:= 'Energized';
		END_IF
							
	//#################### Check the output interlock ##################
	ELSIF ( Config.InterlockState.EnableMon ) THEN
		// if interlock state is checked, error flagged at the beginning of the fub will put the state machine into error state and skip this state
		IF NOT( Internal.Input.InterlockStateOutput2 = 16#9
			AND	Internal.Input.InterlockStateOutput1 = 16#9 )
			THEN // one or both outputs not energized
			Internal.StateGoTo	:= SC_DISABLED;
		END_IF
				
	ELSE
		//#################### Show state text and check transitions when there is no monitoring ####################
		// Stay in enabled state if SO card outputs are physically active during operation
		IF ( ( Internal.Input.SO_In_Output1PhysicalState AND Internal.Input.SO_In_Output2PhysicalState ) ) THEN
			DiagCode			:= 16#8000;
			Diag.DiagText		:= 'Energized';
		ELSE
			Internal.StateGoTo	:= SC_DISABLED;
			DiagCode			:= 16#8110;
			Diag.DiagText		:= 'De-energized';
		END_IF
	END_IF
	
END_ACTION
