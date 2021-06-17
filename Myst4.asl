state("Myst4", "25th Anniversary") {
	// Current state
	int cWorld: "m4_ai_thor_rd.dll", 0x000851E0, 0x210;
	int cZone: "m4_ai_thor_rd.dll", 0x000851E0, 0x214;
	int cNode: "m4_ai_thor_rd.dll", 0x000851E0, 0x218;
	// Loading state
	int lWorld: "m4_ai_global_rd.dll", 0x00079240, 0x74;
	int lZone: "m4_ai_global_rd.dll", 0x00079240, 0x78;
	int lNode: "m4_ai_global_rd.dll", 0x00079240, 0x7C;
	// Game has taken control of the camera
	int cameraAuto: "m4_thor_rd.dll", 0x001B9944, 0xA8;
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
	if (MD5Hash == "4DBD3A95ACDD65D2B710FE81360FF833") {
		print("25th Anniversary version.");
		version = "25th Anniversary";
	} else {
		print("Unsupported version. MD5 hash: " + MD5Hash.ToString());
		version = "Unknown (contact Exodustx0)";
	}
}

startup {
	settings.Add("fullgame", true, "Full-game splits");
	settings.Add("sound", true, "Step away from sound panel after Atrus leaves.", "fullgame");
	settings.Add("tomahnaNight", true, "Transition to night in Tomahna.", "fullgame");
	settings.Add("toSpire", true, "Link into Spire", "fullgame");
	settings.Add("conductor", true, "Step away from conductor box on Spire's faraway island.", "fullgame");
	settings.Add("fromSpire", true, "Link out of Spire", "fullgame");
	settings.Add("toSerenia", true, "Link into Serenia", "fullgame");
	settings.Add("bathy", true, "Reach bathysphere.", "fullgame");
	settings.Add("colour", true, "Step away from colour puzzle panel.", "fullgame");
	settings.Add("dream", true, "Lose control to Dream stone in old memory chamber.", "fullgame");
	settings.Add("end", true, "Trigger ending.", "fullgame");
	
	settings.Add("il", false, "Individual-level splits");
	settings.SetToolTip("il", "This autosplitter will start the timer when you enter any of the IL ages, and split when you exit it.");
	
	settings.Add("menuReset", false, "Reset upon returning to menu.");
	settings.SetToolTip("menuReset", "Obviously, if you enable this, you must be sure to never accidentally go to the menu during a run. Doesn't reset automatically after finished run.");
}

update {
	// If version is unknown, force autosplitter to deactivate
	if (version == "Unknown (contact Exodustx0)") return false;
}

start {
	if (settings["fullgame"]) {
		if (old.cWorld == 6 && old.cZone == 6 && old.cNode == 11 && current.cWorld == 5 && current.cZone == 1 && current.cNode == 10) {
			return true;
		}
	}
	
	if (settings["il"]) {
		// All IL runs start with linking from night-time Tomahna to Haven, Spire or Serenia
		if (old.cWorld == 1 && current.cWorld > 1 && current.cWorld <= 4) {
			return true;
		}
	}
}

isLoading {
	if (current.lNode != current.cNode || current.lZone != current.cZone || current.lWorld != current.cWorld) {
		return true;
	} else {
		return false;
	}
}

split {
	if (settings["fullgame"]) {
		if (settings["sound"] && current.cWorld == 5 && current.cZone == 2 && old.lNode == 30 && current.lNode == 130) {
			// Step away from sound panel after Atrus leaves
			return true;
		} else if (settings["tomahnaNight"] && old.lWorld == 5 && current.lWorld == 1) {
			// Tomahna day to night
			return true;
		} else if (settings["toSpire"] && old.lWorld == 1 && current.lWorld == 3) {
			// Tomahna to Spire
			return true;
		} else if (settings["conductor"] && current.cWorld == 3 && current.cZone == 4 && old.lNode == 130 && current.lNode == 120) {
			// Step away from conductor box on island
			return true;
		} else if (settings["fromSpire"] && old.lWorld == 3 && current.lWorld == 1) {
			// Spire to Tomahna
			return true;
		} else if (settings["toSerenia"] && old.lWorld == 1 && current.lWorld == 4) {
			// Tomahna to Serenia
			return true;
		} else if (settings["bathy"] && current.cWorld == 4 && current.cZone == 6 && old.lNode == 50 && current.lNode == 250) {
			// Reach bathysphere
			return true;
		} else if (settings["colour"] && current.cWorld == 4 && current.cZone == 6 && old.lNode == 61 && current.lNode == 60) {
			// Finish colour puzzle
			return true;
		} else if (settings["dream"] && current.cWorld == 4 && current.cZone == 6 && current.cNode == 220 && old.cameraAuto == 0 && current.cameraAuto == 1) {
			// Lose control to Dream stone
			return true;
		} else if (settings["end"] && current.cWorld == 4 && current.cZone == 6 && old.lNode == 220 && current.lNode == 210) {
			// Trigger ending
			return true;
		}
	}
	
	if (settings["il"]) {
		if (old.lWorld == 2 && current.lWorld == 1) {
			// Haven to Tomahna
			return true;
		} else if (old.lWorld == 3 && current.lWorld == 1) {
			// Spire to Tomahna
			return true;
		} else if (current.cWorld == 4 && current.cZone == 6 && current.cNode == 220 && old.cameraAuto == 0 && current.cameraAuto == 1) {
			// Lose control to Dream stone
			return true;
		}
	}
}

reset {
	if (settings["menuReset"] && old.cWorld != 6 && current.cWorld == 6 && !(old.cWorld == 4 && old.cZone == 6 && old.cNode == 210)) {
		// Reset when transition to menu
		return true;
	}
}
