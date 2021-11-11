
ACTION StateAction_Init:
	
	//#################### Check startup timing error of SF_EDM fub DiagCode monitor ##################
	IF Config.DiagCode.EnableMon THEN
		DiagCode := Internal.Input.SF_In_DiagCode;
		// If SF_EDM DiagCode monitoring is enabled, start the delay timer to give safety CPU's SF_EDM fub enough time (>= MonitorTime) to report that contactors are not open (DiagCode 16#C060)
		Internal.Fub.TON_EDMStartDelay.IN := Internal.Input.SI_In_SafeModuleOK;
				
		IF ( Internal.Fub.TON_EDMStartDelay.Q ) THEN
			Internal.Fub.TON_EDMStartDelay.IN := FALSE;
					
			// Already waited for SF_EDM fub to report stabilized DiagCode but got no response
			IF ( Internal.Input.SF_In_DiagCode = 0 ) THEN
				DiagCode			:= 16#C000;
				Diag.ErrorSafeFub	:= TRUE;
				Diag.DiagText		:= 'SafeFubCommTimeout';
						
				// Check if safety application is operational and SF_EDM reports no error
			ELSIF ( Internal.Input.SF_In_DiagCode < 16#C000 ) THEN
				DiagCode			:= Internal.Input.SF_In_DiagCode;
				IF ( Internal.Input.SF_In_DiagCode = 16#8000 ) THEN
					Internal.StateGoTo	:= SC_ENABLED;
				ELSE
					Internal.StateGoTo	:= SC_DISABLED;
				END_IF
						
				// Check if a start reset of safety CPU's SF_EDM fub is necessary (for situations where the gray CPU reboots but the safety CPU isn't power cycled)
			ELSIF ( Internal.Input.SF_In_DiagCode = 16#C060 ) THEN
				// Start the reset delay timer to give SF_EDM fub enough time to report that contactors are indeed open:
				// Following fdbk SI card's SafeModuleOK, safety CPU may need extra time to determine SI card channels are OK
				Internal.Fub.TON_EDMResetDelay.IN := TRUE;
						
				// if contactors show to be open (feedbacks are TRUE) before timeout, request a safety reset
				IF ( Internal.Input.SI_In_Contactor1Fdbk AND Internal.Input.SI_In_Contactor2Fdbk AND NOT( Internal.EDMReset ) ) THEN
					//Internal.Fub.TON_EDMResetDelay.IN	:= FALSE; //--> the timer shouldn't need to restart because safety CPU's reaction to the reset request should be included in the timer preset
					Internal.EDMReset	:= TRUE;
					DiagCode			:= 16#8001;
					Diag.DiagText		:= 'RequireStartReset';
					// if timeout happens (e.g. actual feedback error or gray CPU doesn't send SF_EDM reset request to safety CPU), set the error flag and it will put the state machine into error state
				ELSIF ( Internal.Fub.TON_EDMResetDelay.Q ) THEN
					Internal.Fub.TON_EDMResetDelay.IN := FALSE;
					Internal.EDMReset	:= FALSE;
					DiagCode			:= Internal.Input.SF_In_DiagCode;
					Diag.ErrorSafeFub	:= TRUE;
				END_IF
						
				// For all other DiagCodes, set the error flag and it will put the state machine into error state
			ELSE
				DiagCode			:= Internal.Input.SF_In_DiagCode;
				Diag.ErrorSafeFub	:= TRUE;
						
			END_IF
				
		ELSE
			IF ( Internal.Input.SI_In_SafeModuleOK ) THEN
				// Wait for SF_EDM fub to report stabilized DiagCode because it is likely to report 16#8010 until MonitorTime has passed
				DiagCode		:= 16#0003;
				Diag.DiagText	:= 'WaitingForSafeFubComm';
			ELSE
				DiagCode		:= 16#0002;
				Diag.DiagText	:= 'WaitingForSafeDIComm';
			END_IF
		END_IF // end DiagCode start delay
				
		//#################### Check startup timing error of Contactor Feedback monitor ####################
	ELSIF Config.Fdbk.EnableMon THEN
		// If feedback monitoring is enabled, start the delay timer to give fdbk SI card enough time to report that contactors are indeed open:
		// Following fdbk SI card's SafeModuleOK, safety CPU may need extra time to determine SI card channels are OK
		Internal.Fub.TON_FdbkStartDelay.IN := Internal.Input.SI_In_SafeModuleOK;
					
		// Check if contactors show to be open (feedbacks are TRUE) before timeout
		IF ( Internal.Input.SI_In_Contactor1Fdbk AND Internal.Input.SI_In_Contactor2Fdbk AND NOT( Internal.EDMReset ) ) THEN
			//Internal.Fub.TON_FdbkStartDelay.IN := FALSE; //--> the timer shouldn't need to restart because safety CPU's reaction to the reset request should be included in the timer preset
			Internal.EDMReset	:= TRUE;
			DiagCode			:= 16#8002;
			Diag.DiagText		:= 'MayRequireStartReset';
					
		ELSIF ( Internal.Fub.TON_FdbkStartDelay.Q ) THEN
			Internal.Fub.TON_FdbkStartDelay.IN := FALSE;
			Internal.EDMReset	:= FALSE;
					
			// if contactors are open when timeout happens, assume SF_EDM fub error has cleared
			IF ( Internal.Input.SI_In_Contactor1Fdbk AND Internal.Input.SI_In_Contactor2Fdbk ) THEN
				Internal.StateGoTo	:= SC_DISABLED;
				DiagCode			:= 16#8110;
				Diag.DiagText		:= 'De-energized';
				// if contactor 2 is open when timeout happens, set the fdbk 1 error flag and it will put the state machine into error state
			ELSIF ( Internal.Input.SI_In_Contactor2Fdbk ) THEN
				DiagCode		:= 16#C040;
				Diag.ErrorFdbk	:= TRUE;
				Diag.DiagText	:= 'NegFdbk1AfterNegOutReq';
				// if contactor 1 is open when timeout happens, set the fdbk 2 error flag and it will put the state machine into error state
			ELSIF ( Internal.Input.SI_In_Contactor1Fdbk ) THEN
				DiagCode		:= 16#C050;
				Diag.ErrorFdbk	:= TRUE;
				Diag.DiagText	:= 'NegFdbk2AfterNegOutReq';
				// if both contactors are closed when timeout happens, set the error flag and it will put the state machine into error state
			ELSE
				DiagCode		:= 16#C060;
				Diag.ErrorFdbk	:= TRUE;
				Diag.DiagText	:= 'NegFdbk1Fdbk2AfterNegOutReq';
			END_IF
					
		ELSE
			DiagCode		:= 16#0002;
			Diag.DiagText	:= 'WaitingForSafeDIComm';
		END_IF // end feedback start delay
				
		//#################### Check startup timing error of Output Interlock monitor ####################
	ELSIF Config.InterlockState.EnableMon THEN
		// If output interlock monitoring is enabled, start the delay timer to give SO card enough time to report that channels are ready:
		// Following SO card's SafeModuleOK, safety CPU may need extra time to determine SO card channels are OK
		Internal.Fub.TON_InterlockStartDelay.IN := Internal.Input.SO_In_SafeModuleOK;
				
		// Check if output interlock states are ready before timeout
		IF ( Internal.Input.InterlockStateOutput1 > 0 AND Internal.Input.InterlockStateOutput2 > 0 ) THEN
			Internal.Fub.TON_InterlockStartDelay.IN := FALSE;
					
			Internal.StateGoTo	:= SC_DISABLED;
					
			// if timeout happens, set the error flag and it will put the state machine into error state
		ELSIF ( Internal.Fub.TON_InterlockStartDelay.Q ) THEN
			Internal.Fub.TON_InterlockStartDelay.IN := FALSE;
					
			DiagCode			:= 16#C300;
			Diag.ErrorInterlock	:= TRUE;
			Diag.DiagText		:= 'SafeDOCardOkTimeout';
					
		ELSE
			DiagCode		:= 16#0001;
			Diag.DiagText	:= 'WaitingForSafeDOComm';
		END_IF // end interlock state start delay
				
		//#################### Ignore startup reset if only current OK monitor is used or if no monitor is used ####################
	ELSE
		// Wait for SO card comm with safety CPU
		IF ( Internal.Input.SO_In_SafeModuleOK ) THEN
			Internal.StateGoTo	:= SC_DISABLED;
			DiagCode			:= 16#8110;
			Diag.DiagText		:= 'De-energized';
		ELSE
			DiagCode		:= 16#0001;
			Diag.DiagText	:= 'WaitingForSafeDOComm';
		END_IF
	END_IF
	
END_ACTION
