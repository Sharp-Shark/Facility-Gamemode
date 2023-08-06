-- Loot Tables
FG.lootTables = {
--	Uses binomial distribution (p is %, n is tries)
--	fg_tag = {
--		{'identifier', p, n, amount}
--	}
	fg_trash = {
		{'plastic', 0.65, 1, 1},
		{'antidama2', 0.35, 1, 1},
		{'shotgunshell', 0.25, 3, 2}
	},
	fg_office1 = {
		{'midazolam', 0.35, 1, 1},
		{'batterycell', 0.3, 1, 1},
		{'opium', 0.3, 2, 1},
		{'tonicliquid', 0.2, 3, 1},
		{'proteinbar', 0.3, 4, 1},
		{'idcardstaff', 0.3, 1, 1}
	},
	fg_office2 = {
		{'flashlight', 0.35, 1, 1},
		{'antibleeding2', 0.2, 1, 1},
		{'antibleeding1', 0.4, 2, 1},
		{'batterycell', 0.3, 2, 1},
		{'opium', 0.3, 2, 1},
		{'tonicliquid', 0.3, 3, 1},
		{'proteinbar', 0.3, 3, 1},
		{'mercspistol', 0.1, 1, 1},
		{'smgmagazine', 0.3, 2, 1},
		{'cigar', 0.65, 1, 1},
		{'clownmask', 0.01, 1, 1},
		{'idcardstaff', 0.4, 1, 1}
	},
	fg_office3 = {
		{'harmonica', 0.2, 1, 1},
		{'flashlight', 0.35, 1, 1},
		{'antibleeding2', 0.2, 2, 1},
		{'antibleeding1', 0.4, 3, 1},
		{'batterycell', 0.3, 2, 1},
		{'steroids', 0.2, 2, 1},
		{'antibiotics', 0.2, 2, 1},
		{'opium', 0.3, 2, 1},
		{'mercspistol', 0.2, 1, 1},
		{'smgmagazine', 0.5, 2, 1},
		{'cigar', 0.6, 2, 1},
		{'idcardstaff', 0.2, 1, 1},
		{'idcardenforcerguard', 0.3, 1, 1},
		{'clownmask', 0.01, 1, 1}
	},
	fg_office4 = {
		{'headset', 0.3, 1, 1},
		{'flashlight', 0.35, 1, 1},
		{'antibleeding1', 0.4, 3, 1},
		{'antibiotics', 0.2, 2, 1},
		{'antidama1', 0.3, 3, 1},
		{'mercssmg', 0.1, 1, 1},
		{'smgmagazine', 0.4, 2, 1},
		{'mercspistol', 0.3, 1, 1},
		{'smgmagazine', 0.5, 2, 1},
		{'batterycell', 0.4, 4, 1},
		{'idcardenforcerguard', 0.3, 1, 1},
		{'idcardeliteguard', 0.2, 1, 1},
		{'idcardoverseer', 0.2, 1, 1},
		{'stungrenade', 0.6, 2, 1},
		{'fraggrenade', 0.4, 1, 1},
		{'handcuffs', 0.75, 1, 1}
	},
	fg_supplies1 = {
		{'extinguisher', 0.4, 1, 1},
		{'plastic', 0.4, 3, 1},
		{'antibleeding2', 0.3, 3, 1},
		{'jetrevolver', 0.3, 1, 1},
		{'shotgunshell', 0.25, 3, 6},
		{'riflebullet', 0.15, 3, 6},
		{'ironhelmet', 0.35, 1, 1},
		{'toolbelt', 0.35, 1, 1},
		{'crowbar', 0.5, 1, 1},
		{'wrench', 0.35, 1, 1},
		{'flashlight', 0.35, 1, 1},
		{'weldingfueltank', 0.4, 4, 1},
		{'batterycell', 0.4, 4, 1},
		{'idcardstaff', 0.3, 1, 1},
		{'idcardenforcerguard', 0.05, 1, 1}
	},
	fg_supplies2 = {
		{'extinguisher', 0.6, 1, 1},
		{'plastic', 0.5, 4, 1},
		{'antibleeding2', 0.4, 4, 1},
		{'jetshotgun', 0.2, 1, 1},
		{'jetrevolver', 0.3, 2, 1},
		{'shotgunshell', 0.5, 3, 6},
		{'riflebullet', 0.35, 3, 6},
		{'ironhelmet', 0.45, 1, 1},
		{'toolbelt', 0.45, 1, 1},
		{'plasmacutter', 0.6, 1, 1},
		{'weldingtool', 0.45, 1, 1},
		{'crowbar', 0.6, 1, 1},
		{'wrench', 0.45, 1, 1},
		{'flashlight', 0.45, 1, 1},
		{'weldingfueltank', 0.4, 4, 1},
		{'oxygentank', 0.4, 4, 1},
		{'batterycell', 0.4, 4, 1},
		{'midazolam', 0.4, 2, 1},
		{'idcardstaff', 0.6, 1, 1},
		{'idcardenforcerguard', 0.2, 1, 1}
	},
	fg_med1 = {
		{'antibloodloss1', 0.4, 3, 1},
		{'antibleeding2', 0.15, 2, 1},
		{'antibleeding1', 0.6, 4, 1},
		{'midazolam', 0.4, 2, 1},
		{'antidama1', 0.3, 2, 1},
		{'antibiotics', 0.4, 2, 1},
		{'calyxanide', 0.4, 1, 1},
		{'opium', 0.5, 3, 1}
	},
	fg_med2 = {
		{'antibloodloss1', 0.5, 5, 1},
		{'antibleeding2', 0.3, 3, 1},
		{'antibleeding1', 0.6, 6, 1},
		{'midazolam', 0.6, 3, 1},
		{'antidama1', 0.4, 3, 1},
		{'antibiotics', 0.6, 3, 1},
		{'calyxanide', 0.6, 2, 1},
		{'opium', 0.5, 5, 1},
	},
	fg_guns = {
		{'bodyarmor', 0.5, 1, 1},
		{'mercssmg', 0.15, 1, 1},
		{'smgmagazine', 0.75, 2, 1},
		{'mercspistol', 0.5, 2, 1},
		{'riflebullet', 0.8, 6, 3},
		{'shotgunshell', 0.8, 6, 3},
		{'divingknife', 0.5, 2, 1},
		{'stungrenade', 0.6, 2, 1},
		{'fraggrenade', 0.4, 1, 1},
		{'handcuffs', 0.75, 2, 1}
	},
	fg_shelter = {
		{'carbonatespray', 0.6, 1, 1},
		{'extinguisher', 0.6, 1, 1},
		{'divingmask', 0.6, 2, 1},
		{'oxygentank', 0.55, 3, 1},
		{'antibleeding1', 0.5, 3, 1},
		{'midazolam', 0.2, 2, 1},
		{'antidama1', 0.2, 2, 1},
		{'bodyarmor', 0.2, 2, 1},
		{'mercspistol', 0.6, 1, 1},
		{'smgmagazine', 0.2, 2, 1},
		{'jetrevolver', 0.6, 1, 1},
		{'shotgunshell', 0.2, 2, 6},
		{'flashlight', 0.35, 1, 1},
		{'crowbar', 0.45, 1, 1},
		{'batterycell', 0.3, 3, 1},
		{'flare', 0.2, 2, 2},
		{'idcardoverseer', 0.4, 1, 1}
	},
	fg_armory = {
		{'carbonatespray', 0.6, 1, 1},
		{'headset', 0.35, 2, 1},
		{'antibleeding1', 0.5, 3, 1},
		{'midazolam', 0.2, 2, 1},
		{'antidama1', 0.2, 2, 1},
		{'bodyarmor', 0.2, 2, 1},
		{'mercspistol', 0.6, 1, 1},
		{'flashlight', 0.35, 1, 1},
		{'smgmagazine', 0.2, 4, 1},
		{'crowbar', 0.45, 1, 1},
		{'divingknife', 0.2, 2, 1},
		{'batterycell', 0.3, 3, 1},
		{'idcardenforcerguard', 0.3, 1, 1},
		{'idcardeliteguard', 0.1, 1, 1},
		{'fraggrenade', 0.6, 3, 1},
		{'stungrenade', 0.5, 2, 1},
		{'chemgrenade', 0.4, 1, 1},
		{'handcuffs', 0.5, 5, 1}
	},
	fg_ammo = {
		{'assaultriflemagazine', 0.8, 10, 1},
		{'riflebullet', 0.8, 6, 6},
		{'smgmagazine', 0.8, 6, 1},
		{'shotgunshell', 0.8, 4, 6},
		{'fraggrenade', 0.6, 3, 1},
		{'chemgrenade', 0.4, 2, 1},
		{'handcuffs', 0.75, 2, 1}
	},
	fg_diving = {
		{'underwaterscooter', 0.35, 2, 1},
		{'flashlight', 0.75, 2, 1},
		{'divingmask', 0.6, 5, 1},
		{'oxygentank', 0.55, 5, 1},
		{'batterycell', 0.6, 3, 1},
		{'wrench', 0.65, 3, 1}
	},
	fg_deadinmate = {
		{'jetrevolver', 0.15, 1, 1},
		{'divingmask', 0.2, 1, 1},
		{'oxygentank', 0.35, 2, 1},
		{'opium', 0.35, 3, 1},
		{'antidama2', 0.35, 2, 1},
		{'handcuffs', 0.25, 1, 1},
		{'crowbar', 0.35, 1, 1},
		{'plasmacutter', 0.6, 1, 1},
		{'shotgunshell', 0.2, 4, 3},
		{'divingknife', 0.65, 2, 1},
		{'cigar', 0.35, 1, 1}
	},
	fg_deadrepairmen = {
		{'divingmask', 0.35, 1, 1},
		{'oxygentank', 0.5, 2, 1},
		{'weldingtool', 0.25, 1, 1},
		{'weldingfueltank', 0.35, 2, 1},
		{'mercspistol', 0.25, 1, 1},
		{'smgmagazine', 0.25, 2, 1},
		{'opium', 0.35, 2, 1},
		{'antidama1', 0.35, 1, 1},
		{'antibleeding2', 0.35, 3, 1},
		{'wrench', 0.35, 1, 1},
		{'flashlight', 0.35, 1, 1},
		{'cigar', 0.35, 1, 1}
	},
	fg_deadresearcher = {
		{'mercspistol', 0.25, 1, 1},
		{'smgmagazine', 0.25, 2, 1},
		{'opium', 0.35, 3, 1},
		{'antidama1', 0.35, 2, 1},
		{'combatstimulantsyringe', 0.2, 1, 1},
		{'calyxanide', 0.25, 1, 1},
		{'antibloodloss1', 0.3, 1, 1},
		{'cigar', 0.35, 1, 1}
	},
	fg_deadenforcerguard = {
		{'mercssmg', 0.5, 1, 1},
		{'mercspistol', 0.75, 1, 1},
		{'smgmagazine', 0.35, 4, 1},
		{'handcuffs', 0.5, 2, 1},
		{'opium', 0.35, 3, 1},
		{'antidama1', 0.35, 2, 1},
		{'antibleeding1', 0.35, 3, 1},
		{'flashlight', 0.35, 1, 1},
		{'cigar', 0.35, 1, 1}
	}
}

FG.loadedFiles['lootTables'] = true