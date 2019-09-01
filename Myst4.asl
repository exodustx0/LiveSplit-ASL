state("Myst4", "25th Anniversary"){
	int cWorld: "m4_ai_thor_rd.dll", 0x000851E0, 0x210;
	int cZone: "m4_ai_thor_rd.dll", 0x000851E0, 0x214;
	int cNode: "m4_ai_thor_rd.dll", 0x000851E0, 0x218;
	int lWorld: "m4_ai_global_rd.dll", 0x00079240, 0x74;
	int lZone: "m4_ai_global_rd.dll", 0x00079240, 0x78;
	int lNode: "m4_ai_global_rd.dll", 0x00079240, 0x7C;
	int cameraAuto: "m4_thor_rd.dll", 0x001B9944, 0xA8;
}

init{
	// I robbed this md5 code from Gelly's Myst autosplitter who robbed it from CptBrian's RotN autosplitter
	// Shoutouts to them
	byte[] exeMD5HashBytes = new byte[0];
	using (var md5 = System.Security.Cryptography.MD5.Create())
	{
		using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
		{
			exeMD5HashBytes = md5.ComputeHash(s); 
		} 
	}
	var MD5Hash = exeMD5HashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
	print("MD5Hash: " + MD5Hash.ToString());
	
	if(MD5Hash == "4DBD3A95ACDD65D2B710FE81360FF833"){
		print("25th Anniversary version.");
		version = "25th Anniversary";
	}else{
		print("Unsupported version.");
	}
}

startup{
	settings.Add("sound", true, "Split when stepping away from sound panel after Atrus leaves.");
	settings.Add("conductor", true, "Split when stepping away from conductor box on Spire's faraway island.");
	settings.Add("bathy", true, "Split when reaching bathysphere.");
	settings.Add("colour", true, "Split when stepping away from colour puzzle panel.");
}

start{
	if(old.cWorld == 6 && old.cZone == 6 && old.cNode == 11 && current.cWorld == 5 && current.cZone == 1 && current.cNode == 10){
		return true;
	}else{
		return false;
	}
}

isLoading{
	if(current.lNode != current.cNode || current.lZone != current.cZone || current.lWorld != current.cWorld){
		return true;
	}else{
		return false;
	}
}

split{
	if(settings["sound"] && current.cWorld == 5 && current.cZone == 2 && old.lNode == 30 && current.lNode == 130){
		// Step away from sound panel after Atrus leaves
		return true;
	}else if(old.lWorld == 5 && current.lWorld == 1){
		// Tomahna day to night
		return true;
	}else if(old.lWorld == 1 && current.lWorld == 3){
		// Tomahna to Spire
		return true;
	}else if(settings["conductor"] && current.cWorld == 3 && current.cZone == 4 && old.lNode == 130 && current.lNode == 120){
		// Step away from conductor box on island
		return true;
	}else if(old.lWorld == 3 && current.lWorld == 1){
		// Spire to Tomahna
		return true;
	}else if(old.lWorld == 1 && current.lWorld == 4){
		// Tomahna to Serenia
		return true;
	}else if(settings["bathy"] && current.cWorld == 4 && current.cZone == 6 && old.lNode == 50 && current.lNode == 250){
		// Reach bathysphere
		return true;
	}else if(settings["colour"] && current.cWorld == 4 && current.cZone == 6 && old.lNode == 61 && current.lNode == 60){
		// Finish colour puzzle
		return true;
	}else if(current.cWorld == 4 && current.cZone == 6 && current.cNode == 220 && old.cameraAuto == 0 && current.cameraAuto == 1){
		// Lose control to Dream stone
		return true;
	}else if(current.cWorld == 4 && current.cZone == 6 && old.lNode == 220 && current.lNode == 210){
		// Trigger ending
		return true;
	}else{
		return false;
	}
}