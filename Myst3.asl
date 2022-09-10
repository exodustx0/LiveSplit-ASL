state("residualvm", "GOG (25th Anniv.)") {
	int node: "residualvm.exe", 0x0071B5A8, 0x4C, 0x16C;
	int room: "residualvm.exe", 0x0071B5A8, 0x4C, 0x168;
}

state("residualvm", "DVD (25th Anniv.)") {
	int node: "residualvm.exe", 0x004ED0A8, 0x4C, 0x16C;
	int room: "residualvm.exe", 0x004ED0A8, 0x4C, 0x168;
}

state("residualvm", "Steam (25th Anniv.)") {
	int node: "residualvm.exe", 0x004EC0A8, 0x4C, 0x16C;
	int room: "residualvm.exe", 0x004EC0A8, 0x4C, 0x168;
}

init {
	// Get the game executable's MD5 hash and print it
	byte[] exeMD5HashBytes = new byte[0];
	using (var md5 = System.Security.Cryptography.MD5.Create()) {
		using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite)) {
			exeMD5HashBytes = md5.ComputeHash(s); 
		} 
	}
	var MD5Hash = exeMD5HashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
	
	// Check the hash against known versions of the game
	switch (MD5Hash) {
	case "67BAFA45FC3EE1F4211A26FCC65CF73E":
		print("GOG version.");
		version = "GOG (25th Anniv.)";
		break;
	case "60C57D14483233F5C71B7B5A04938621":
		print("DVD version.");
		version = "DVD (25th Anniv.)";
		break;
	case "F280D868DF58DC05DD55352DDA474433":
		print("Steam version.");
		version = "Steam (25th Anniv.)";
		break;
	default:
		print("Unsupported version. MD5 hash: " + MD5Hash.ToString());
		version = "Unknown (contact exodustx0)";
		break;
	}
}

startup {
	settings.Add("fullgame", true, "Full-game splits");
	settings.Add("toho2leis", false, "Link from Tomahna to J'nanin.", "fullgame");
	settings.Add("lemt2mais", true, "Link from J'nanin to Amateria.", "fullgame");
	settings.Add("mato2leos", true, "Link from Amateria to J'nanin.", "fullgame");
	settings.Add("lelt2lidr", true, "Link from J'nanin to Edanna.", "fullgame");
	settings.Add("line2leos", true, "Link from Edanna to J'nanin.", "fullgame");
	settings.Add("leet2ensi", true, "Link from J'nanin to Voltaic.", "fullgame");
	settings.Add("enli2leos", true, "Link from Voltaic to J'nanin.", "fullgame");
	settings.Add("leos2nach", false, "Link from J'nanin to Narayan.", "fullgame");
	settings.Add("end", true, "Lose control to ending cutscene.", "fullgame");
	settings.SetToolTip("end", "This autosplitter is not aware of if you get good ending or not, it will simply split when the ending cutscene is triggered.");
	
	settings.Add("il", false, "Individual-level splits");
	settings.SetToolTip("il", "This autosplitter will start the timer when you enter any of the IL ages, and split when you exit it.");
	
	settings.Add("menuReset", false, "Reset upon returning to menu.");
	settings.SetToolTip("menuReset", "Obviously, if you enable this, you must be sure to never accidentally go to the menu during a run. Doesn't reset automatically after finished run.");
}

update {
	// If version is unknown, force autosplitter to deactivate
	if (version == "Unknown (contact exodustx0)") return false;
}

start {
	if (settings["fullgame"]) {
		if (old.room == 901 && old.node == 100 && current.room != 901) {
			return true;
		}
	} else if (settings["il"]) {
		if (old.room == 505 && current.room == 1002) {
			// J'nanin to Amateria
			return true;
		} else if (old.room == 504 && current.room == 601) {
			// J'nanin to Edanna
			return true;
		} else if (old.room == 503 && current.room == 701) {
			// J'nanin to Voltaic
			return true;
		} else if (old.room == 502 && current.room == 801) {
			// J'nanin to Narayan
			return true;
		}
	}
}

split {
	if (settings["fullgame"]) {
		if (settings["toho2leis"] && old.room == 301 && current.room == 501) {
			// Tomahna to J'nanin
			return true;
		} else if (settings["lemt2mais"] && old.room == 505 && current.room == 1002) {
			// J'nanin to Amateria
			return true;
		} else if (settings["mato2leos"] && old.room == 1006 && current.room == 502) {
			// Amateria to J'nanin
			return true;
		} else if (settings["lelt2lidr"] && old.room == 504 && current.room == 601) {
			// J'nanin to Edanna
			return true;
		} else if (settings["line2leos"] && old.room == 605 && current.room == 502) {
			// Edanna to J'nanin
			return true;
		} else if (settings["leet2ensi"] && old.room == 503 && current.room == 701) {
			// J'nanin to Voltaic
			return true;
		} else if (settings["enli2leos"] && old.room == 708 && current.room == 502) {
			// Voltaic to J'nanin
			return true;
		} else if (settings["leos2nach"] && old.room == 502 && current.room == 801) {
			// J'nanin to Narayan
			return true;
		} else if (settings["end"] && current.room == 401 && old.node == 1 && current.node != 1) {
			// Trigger ending cutscene; doesn't check for good ending, just *an* ending
			return true;
		}
	}
	
	if (settings["il"]) {
		if (old.room == 1006 && current.room == 502) {
			// Amateria done
			return true;
		} else if (old.room == 605 && current.room == 502) {
			// Edanna done
			return true;
		} else if (old.room == 708 && current.room == 502) {
			// VOltaic done
			return true;
		} else if (old.room == 801 && current.room == 401) {
			// Narayan done
			return true;
		}
	}
}

reset {
	if (settings["menuReset"] && old.room != 901 && current.room == 901 && old.room != 401) {
		// Reset when transition to menu, except when after credits
		return true;
	}
}
