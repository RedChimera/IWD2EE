
(function()

	IEex_DisableCodeProtection()

	--------------------------------------------------------------------------------------------------------
	-- The engine attempts to flag bought store items as Identified. This makes little sense, as the item --
	-- transferred to the party is still unidentified. This also causes a crash, as the store cannot find --
	-- the bought item to remove it from its stock due to the identify flag suddenly changing.            --
	--------------------------------------------------------------------------------------------------------

	IEex_WriteAssembly(0x54C2A5, {"!repeat(3,!nop)"})

	IEex_EnableCodeProtection()

end)()
