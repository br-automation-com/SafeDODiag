
ACTION SimAction_DiagCode:
	
	IF ( Simulation.Input.SF_In_DiagCode < 16#C000 ) THEN
		// both outputs are expected to energize together, so either output acting alone will be treated as outputs not energized
		IF ( Simulation.Input.SO_In_Output1PhysicalState AND Simulation.Input.SO_In_Output2PhysicalState ) THEN
			Simulation.Input.SF_In_DiagCode	:= 16#8000;
		ELSE
			Simulation.Input.SF_In_DiagCode	:= 16#8010;
		END_IF
		// simulate SF_EDM response after monitor time is over
		Internal.Fub.TON_EDMMonitorSim.IN := ( Simulation.Input.SO_In_Output1PhysicalState = Internal.Prev.SimOutput1 ) AND ( Simulation.Input.SO_In_Output2PhysicalState = Internal.Prev.SimOutput2 );
		IF ( Internal.Fub.TON_EDMMonitorSim.IN AND Internal.Fub.TON_EDMMonitorSim.Q ) THEN
			// both outputs are expected to energize together, so either output acting alone will be treated as outputs not energized
			IF ( NOT ( Simulation.Input.SO_In_Output1PhysicalState AND Simulation.Input.SO_In_Output2PhysicalState ) AND Simulation.Input.SI_In_Contactor1Fdbk AND Simulation.Input.SI_In_Contactor2Fdbk ) THEN
				Simulation.Input.SF_In_DiagCode	:= 16#8010;
			ELSIF ( NOT ( Simulation.Input.SO_In_Output1PhysicalState AND Simulation.Input.SO_In_Output2PhysicalState ) AND NOT Simulation.Input.SI_In_Contactor1Fdbk AND Simulation.Input.SI_In_Contactor2Fdbk ) THEN
				Simulation.Input.SF_In_DiagCode	:= 16#C040;
			ELSIF ( NOT ( Simulation.Input.SO_In_Output1PhysicalState AND Simulation.Input.SO_In_Output2PhysicalState ) AND Simulation.Input.SI_In_Contactor1Fdbk AND NOT Simulation.Input.SI_In_Contactor2Fdbk ) THEN
				Simulation.Input.SF_In_DiagCode	:= 16#C050;
			ELSIF ( NOT ( Simulation.Input.SO_In_Output1PhysicalState AND Simulation.Input.SO_In_Output2PhysicalState ) AND NOT Simulation.Input.SI_In_Contactor1Fdbk AND NOT Simulation.Input.SI_In_Contactor2Fdbk ) THEN
				Simulation.Input.SF_In_DiagCode	:= 16#C060;
			ELSIF ( Simulation.Input.SO_In_Output1PhysicalState AND Simulation.Input.SO_In_Output2PhysicalState AND Simulation.Input.SI_In_Contactor1Fdbk AND Simulation.Input.SI_In_Contactor2Fdbk ) THEN
				Simulation.Input.SF_In_DiagCode	:= 16#C090;
			ELSIF ( Simulation.Input.SO_In_Output1PhysicalState AND Simulation.Input.SO_In_Output2PhysicalState AND NOT Simulation.Input.SI_In_Contactor1Fdbk AND Simulation.Input.SI_In_Contactor2Fdbk ) THEN
				Simulation.Input.SF_In_DiagCode	:= 16#C080;
			ELSIF ( Simulation.Input.SO_In_Output1PhysicalState AND Simulation.Input.SO_In_Output2PhysicalState AND Simulation.Input.SI_In_Contactor1Fdbk AND NOT Simulation.Input.SI_In_Contactor2Fdbk ) THEN
				Simulation.Input.SF_In_DiagCode	:= 16#C070;
			ELSIF ( Simulation.Input.SO_In_Output1PhysicalState AND Simulation.Input.SO_In_Output2PhysicalState AND NOT Simulation.Input.SI_In_Contactor1Fdbk AND NOT Simulation.Input.SI_In_Contactor2Fdbk ) THEN
				Simulation.Input.SF_In_DiagCode	:= 16#8000;
			END_IF
			// check for static TRUE signal on EDM reset at the time error occurs
			IF ( Status.SafetyResetRequested AND Simulation.Input.SF_In_DiagCode >= 16#C000 ) THEN
				Simulation.Input.SF_In_DiagCode	:= Simulation.Input.SF_In_DiagCode + 1;
			END_IF
		END_IF
	ELSE
		Internal.Fub.TON_EDMMonitorSim.IN := FALSE;
		IF ( Status.SafetyResetRequested ) THEN
			Simulation.Input.SF_In_DiagCode	:= 16#8010;
		END_IF
	END_IF
	
END_ACTION
