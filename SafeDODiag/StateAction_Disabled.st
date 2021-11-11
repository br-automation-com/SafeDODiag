
ACTION StateAction_Disabled:
	
	//#################### Check the SF_EDM fub DiagCode ##################
	// if DiagCode is checked, error flagged at the beginning of the fub will put the state machine into error state and skip this state
	// while non-zero DiagCode would update the DiagText at the beginning of the fub
	IF ( Config.DiagCode.EnableMon ) THEN
				
		CASE Internal.Input.SF_In_DiagCode OF
			16#0000:
			DiagCode		:= 16#0003;
			Diag.DiagText	:= 'WaitingForSafeFubComm';
			16#8000:
			Internal.StateGoTo	:= SC_ENABLED;
		END_CASE
				
	//#################### Check the contactor feedback ##################
	ELSIF ( Config.Fdbk.EnableMon ) THEN
				
		// both fdbks need to be active (to show that both contactors are open); if either fdbk is inactive, start the fdbk timer to check if they activate before timeout
		Internal.Fub.TON_Fdbk.IN := NOT( Internal.Input.SI_In_Contactor1Fdbk AND Internal.Input.SI_In_Contactor2Fdbk );
				
		// Go to enabled state if SO card outputs are physically active during operation
		IF ( Internal.Input.SO_In_Output1PhysicalState AND Internal.Input.SO_In_Output2PhysicalState ) THEN
			Internal.Fub.TON_Fdbk.IN := FALSE;
					
			Internal.StateGoTo	:= SC_ENABLED;
			DiagCode			:= 16#8000;
			Diag.DiagText		:= 'Energized';
					
		ELSIF ( Internal.Fub.TON_Fdbk.Q ) THEN
			Internal.Fub.TON_Fdbk.IN := FALSE;
			Diag.ErrorFdbk := TRUE; // set the error flag and it will put the state machine into error state
					
			IF ( Internal.Input.SI_In_Contactor1Fdbk ) THEN
				DiagCode		:= 16#C050;
				Diag.DiagText	:= 'NegFdbk2AfterNegOutReq';
			ELSIF ( Internal.Input.SI_In_Contactor2Fdbk ) THEN
				DiagCode		:= 16#C040;
				Diag.DiagText	:= 'NegFdbk1AfterNegOutReq';
			ELSE
				DiagCode		:= 16#C060;
				Diag.DiagText	:= 'NegFdbkAfterNegOutReq';
			END_IF
					
		ELSIF NOT( Config.InterlockState.EnableMon ) THEN
			DiagCode			:= 16#8110;
			Diag.DiagText		:= 'De-energized';
		END_IF
				
	//#################### Check the output current ##################
	ELSIF ( Config.Current.EnableMon ) THEN
				
		// if either SO card output current is maintained or if contactor current is above threshold, start the current timer to check if they deactivate before timeout
		Internal.Fub.TON_Current.IN := Internal.Input.SO_In_Output1CurrentOK OR Internal.Input.SO_In_Output2CurrentOK;
				
		// Go to enabled state if SO card outputs are physically active during operation
		IF ( Internal.Input.SO_In_Output1PhysicalState AND Internal.Input.SO_In_Output2PhysicalState ) THEN
			Internal.Fub.TON_Current.IN := FALSE;
					
			Internal.StateGoTo	:= SC_ENABLED;
			DiagCode			:= 16#8000;
			Diag.DiagText		:= 'Energized';
					
		ELSIF ( Internal.Fub.TON_Current.Q) THEN
			Internal.Fub.TON_Current.IN	:= FALSE;
			Diag.ErrorCurrent := TRUE; // set the error flag and it will put the state machine into error state
					
			IF NOT( Internal.Input.SO_In_Output1CurrentOK ) THEN
				DiagCode		:= 16#C250;
				Diag.DiagText	:= 'PosCurrentOk2AfterNegOutReq';
			ELSIF NOT( Internal.Input.SO_In_Output2CurrentOK ) THEN
				DiagCode		:= 16#C240;
				Diag.DiagText	:= 'PosCurrentOk1fterNegOutReq';
			ELSE
				DiagCode		:= 16#C260;
				Diag.DiagText	:= 'PosCurrentOkAfterNegOutReq';
			END_IF
					
		ELSIF NOT( Config.InterlockState.EnableMon ) THEN
			DiagCode			:= 16#8110;
			Diag.DiagText		:= 'De-energized';
		END_IF
				
	//#################### Check the output interlock ##################
	// if interlock state is checked, error flagged at the beginning of the fub will put the state machine into error state and skip this state
	ELSIF ( Config.InterlockState.EnableMon ) THEN
				
		IF	Internal.Input.InterlockStateOutput2 = 16#9 // output energized
			AND	Internal.Input.InterlockStateOutput1 = 16#9 // output energized
			THEN
			Internal.StateGoTo	:= SC_ENABLED;
			DiagCode			:= 16#8000;
			Diag.DiagText		:= 'Energized';
		ELSE
			// if only one output is enabled, start the interlock timer to check if the other output enables before timeout
			Internal.Fub.TON_Interlock.IN := ( Internal.Input.InterlockStateOutput1 = 16#9 ) XOR ( Internal.Input.InterlockStateOutput2 = 16#9 );
					
			IF ( Internal.Fub.TON_Interlock.Q ) THEN
				Internal.Fub.TON_Interlock.IN := FALSE;
				Diag.ErrorInterlock	:= TRUE; // set the error flag and it will put the state machine into error state
				DiagCode			:= 16#C340;
				Diag.DiagText		:= 'SafeDOCardPosOutputsNotSameTime';
			END_IF
		END_IF
				
	//#################### Show state text and check transitions when there is no monitoring ####################
	ELSE
		// Go to enabled state if SO card outputs are physically active during operation
		IF ( Internal.Input.SO_In_Output1PhysicalState AND Internal.Input.SO_In_Output2PhysicalState ) THEN
			Internal.StateGoTo	:= SC_ENABLED;
			DiagCode			:= 16#8000;
			Diag.DiagText		:= 'Energized';
		ELSE
			DiagCode			:= 16#8110;
			Diag.DiagText		:= 'De-energized';
		END_IF
	END_IF
	
END_ACTION
