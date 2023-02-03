-- Loot Tables
global_lootTables = {
--	Uses binomial distribution (p is %, n is tries)
--	fg_tag = {
--		{'identifier', p, n, amount}
--	}
	fg_trash = {
		{'antidama2', 0.35, 1, 1},
		{'idcardstaff', 0.3, 1, 1},
		{'revolverround', 0.25, 1, 3},
	},
	fg_office1 = {
		{'antidama2', 0.35, 1, 1},
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
		{'revolver', 0.15, 1, 1},
		{'revolverround', 0.3, 3, 3},
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
		{'revolver', 0.3, 1, 1},
		{'revolverround', 0.5, 3, 3},
		{'cigar', 0.6, 2, 1},
		{'idcardstaff', 0.2, 1, 1},
		{'idcardenforcerguard', 0.2, 1, 1},
		{'idcardoverseer', 0.05, 1, 1}
	},
	fg_office4 = {
		{'headset', 0.3, 1, 1},
		{'flashlight', 0.35, 1, 1},
		{'antibleeding1', 0.4, 3, 1},
		{'antibiotics', 0.2, 2, 1},
		{'antidama1', 0.3, 3, 1},
		{'smg', 0.2, 1, 1},
		{'smgmagazine', 0.4, 2, 1},
		{'revolver', 0.6, 1, 1},
		{'revolverround', 0.6, 4, 3},
		{'oxygentank', 0.4, 4, 1},
		{'batterycell', 0.4, 4, 1},
		{'idcardenforcerguard', 0.3, 1, 1},
		{'idcardeliteguard', 0.1, 1, 1},
		{'idcardoverseer', 0.1, 1, 1}
	},
	fg_supplies1 = {
		{'antibleeding2', 0.3, 3, 1},
		{'handcannon', 0.3, 1, 1},
		{'handcannonround', 0.25, 3, 6},
		{'ironhelmet', 0.35, 1, 1},
		{'toolbelt', 0.35, 1, 1},
		{'crowbar', 0.5, 1, 1},
		{'wrench', 0.35, 1, 1},
		{'flashlight', 0.35, 1, 1},
		{'weldingfueltank', 0.4, 4, 1},
		{'batterycell', 0.4, 4, 1},
		{'idcardstaff', 0.4, 1, 1},
		{'idcardenforcerguard', 0.1, 1, 1}
	},
	fg_supplies2 = {
		{'antibleeding2', 0.4, 4, 1},
		{'shotgun', 0.6, 1, 1},
		{'shotgunshell', 0.5, 3, 6},
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
		{'idcardstaff', 0.6, 1, 1},
		{'idcardenforcerguard', 0.2, 1, 1}
	},
	fg_med1 = {
		{'antibleeding2', 0.15, 2, 1},
		{'antibleeding1', 0.6, 4, 1},
		{'antidama1', 0.2, 2, 1},
		{'deusizine', 0.15, 2, 1},
		{'antibiotics', 0.15, 2, 1},
		{'opium', 0.5, 3, 1}
	},
	fg_med2 = {
		{'antibloodloss1', 0.3, 3, 1},
		{'antibleeding2', 0.3, 3, 1},
		{'antibleeding1', 0.6, 6, 1},
		{'antidama1', 0.4, 3, 1},
		{'chloralhydrate', 0.6, 3, 1},
		{'deusizine', 0.3, 3, 1},
		{'antibiotics', 0.3, 3, 1},
		{'calyxanide', 0.6, 1, 1},
		{'combatstimulantsyringe', 0.1, 1, 1}
	},
	fg_guns = {
		{'bodyarmor', 0.5, 1, 1},
		{'machinepistol', 0.25, 1, 1},
		{'smgmagazine', 0.75, 8, 1},
		{'revolver', 0.55, 2, 1},
		{'revolverround', 0.5, 6, 6},
		{'divingknife', 0.5, 2, 1}
	},
	fg_shelter = {
		{'extinguisher', 0.5, 1, 1},
		{'divingmask', 0.6, 2, 1},
		{'oxygentank', 0.55, 3, 1},
		{'antibleeding1', 0.5, 3, 1},
		{'antidama1', 0.2, 2, 1},
		{'bodyarmor', 0.2, 2, 1},
		{'revolver', 0.6, 1, 1},
		{'flashlight', 0.35, 1, 1},
		{'revolverround', 0.2, 2, 6},
		{'crowbar', 0.45, 1, 1},
		{'divingknife', 0.2, 2, 1},
		{'batterycell', 0.3, 3, 1},
		{'flare', 0.2, 2, 2},
		{'idcardoverseer', 0.4, 1, 1}
	},
	fg_armory = {
		{'extinguisher', 0.5, 1, 1},
		{'headset', 0.35, 2, 1},
		{'antibleeding1', 0.5, 3, 1},
		{'antidama1', 0.2, 2, 1},
		{'bodyarmor', 0.2, 2, 1},
		{'revolver', 0.6, 1, 1},
		{'flashlight', 0.35, 1, 1},
		{'smgmagazine', 0.2, 2, 1},
		{'revolverround', 0.2, 2, 6},
		{'crowbar', 0.45, 1, 1},
		{'divingknife', 0.2, 2, 1},
		{'batterycell', 0.3, 3, 1},
		{'idcardenforcerguard', 0.3, 1, 1},
		{'idcardeliteguard', 0.1, 1, 1}
	},
	fg_ammo = {
		{'assaultriflemagazine', 0.8, 10, 1},
		{'shotgunshell', 0.8, 8, 6},
		{'smgmagazine', 0.7, 6, 1},
		{'revolverround', 0.7, 6, 6}
	},
	fg_diving = {
		{'underwaterscooter', 0.35, 2, 1},
		{'flashlight', 0.75, 2, 1},
		{'divingmask', 0.6, 5, 1},
		{'oxygentank', 0.55, 5, 1},
		{'batterycell', 0.6, 3, 1},
		{'divingknife', 0.75, 1, 1}
	}
}

global_loadedFiles['lootTables'] = true