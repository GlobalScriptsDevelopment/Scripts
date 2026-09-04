-- // GLOBAL SCRIPTS: PREMIUM DATABASE \\ --
-- // Hosted on GitHub \\ --

local PremiumDatabase = {
    -- This is the master secret. The game scripts will check against this.
    -- Change this periodically for maximum security.
    MasterSecret = "GlobalScripts_Secure_Test",
    
    -- List of authorized Premium users by their Roblox UserId
    Players = {
        [80349677404572] = { Status = true, Role = "Owner" }, -- Replace with your actual UserId
        [10104009628] = { Status = true, Role = "Premium User" },
        [987654321] = { Status = true, Role = "Tester" }
    }
}

return PremiumDatabase
