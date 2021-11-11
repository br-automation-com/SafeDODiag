
ACTION DiagAction_DiagCode:
	
	// Pass through safety CPU's SF_EDM fub DiagCode
	IF ( Internal.Input.SF_In_DiagCode > 0 ) THEN
		// 16#0 is not passed through because whether it is information or error (and require a custom DiagCode display) depends on preexisting fub state and timeout
		DiagCode	:= Internal.Input.SF_In_DiagCode;
	END_IF
	// Go to error state if any error is reported by safety CPU
	IF ( Internal.Input.SF_In_DiagCode >= 16#C000 ) THEN // SF_EDM DiagCode shows an error
		Internal.StateGoTo	:= SC_ERROR;
		Diag.ErrorSafeFub	:= TRUE;
	END_IF
	
	// Look up custom DiagText
	CASE Internal.Input.SF_In_DiagCode OF
		// 16#0 is not listed because whether it is information or error depends on the fub state and timeout
		// Information
		16#8000:
		Diag.DiagText := 'Energized';
		16#8001:
		Diag.DiagText := 'RequireStartReset';
		16#8010:
		IF NOT( Config.InterlockState.EnableMon ) THEN
			Diag.DiagText := 'RequireOutReq';
		ELSE
			// See Config.InterlockState.EnableMon section
		END_IF
		// Error
		16#C001:
		Diag.DiagText := 'PosReset';
		16#C010:
		Diag.DiagText := 'SameTimePosEdgeOutReqNegEdgeFdbk1';
		16#C011:
		Diag.DiagText := 'SameTimePosEdgeOutReqNegEdgeFdbk1PosReset';
		16#C020:
		Diag.DiagText := 'SameTimePosEdgeOutReqNegEdgeFdbk2';
		16#C021:
		Diag.DiagText := 'SameTimePosEdgeOutReqNegEdgeFdbk2PosReset';
		16#C030:
		Diag.DiagText := 'SameTimePosEdgeOutReqNegEdgeFdbk1Fdbk2';
		16#C031:
		Diag.DiagText := 'SameTimePosEdgeOutReqNegEdgeFdbk1Fdbk2PosReset';
		16#C040:
		Diag.DiagText := 'NegFdbk1AfterNegOutReq';
		16#C041:
		Diag.DiagText := 'NegFdbk1PosResetAfterNegOutReq';
		16#C050:
		Diag.DiagText := 'NegFdbk2AfterNegOutReq';
		16#C051:
		Diag.DiagText := 'NegFdbk2PosResetAfterNegOutReq';
		16#C060:
		Diag.DiagText := 'NegFdbk1Fdbk2AfterNegOutReq';
		16#C061:
		Diag.DiagText := 'NegFdbk1Fdbk2PosResetAfterNegOutReq';
		16#C070:
		Diag.DiagText := 'PosFdbk1AfterPosOutReq';
		16#C071:
		Diag.DiagText := 'PosFdbk1PosResetAfterPosOutReq';
		16#C080:
		Diag.DiagText := 'PosFdbk2AfterPosOutReq';
		16#C081:
		Diag.DiagText := 'PosFdbk2PosResetAfterPosOutReq';
		16#C090:
		Diag.DiagText := 'PosFdbk1Fdbk2AfterPosOutReq';
		16#C091:
		Diag.DiagText := 'PosFdbk1Fdbk2PosResetAfterPosOutReq';
		16#C111:
		Diag.DiagText := 'SameTimePosEdgeOutReqPosEdgeReset';
	END_CASE
	
END_ACTION
