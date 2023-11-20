
IEex_FakeInputRoutine_EnableClickAllInventoryButtons = false

IEex_AbsoluteOnce("IEex_FakeInputRoutine_Register", function()

	if IEex_FakeInputRoutine_EnableClickAllInventoryButtons then
		local routine = {}
		for i = 0, 5 do
			table.insert(routine, {IEex_FakeInputRoutineEvent.CLICK_CONTROL, "GUIINV", 1, i})
			for j = 0, 112 do
				if (j < 82 or j > 83) and (j < 62 or j > 63) then
					table.insert(routine, {IEex_FakeInputRoutineEvent.CLICK_CONTROL, "GUIINV", 2, j})
					table.insert(routine, {IEex_FakeInputRoutineEvent.WAIT, 500000})
					table.insert(routine, {IEex_FakeInputRoutineEvent.CLICK_CONTROL, "GUIINV", 2, j})
				end
			end
		end
		IEex_RegisterFakeInputRoutineStartStopKeys("IEex_FakeInputRoutine_ClickAllInventoryButtons",
			routine, IEex_KeyIDS.F1, IEex_KeyIDS.F1
		)
	end
end)
