Config = Config or {} -- dont touch :)

Config.NoRestrictTeams = {} -- Your teams that can post objectives go here, EX: Config.NoRestrictTeams = {TEAM_CITIZEN, TEAM_COP, TEAM_MAYOR}
Config.Restrict = false -- Restrict the access to what teams you must be to use the objectives system 
Config.UniqueTeam = false -- Whether or not the receiving end of the objective is team based. 

-- I wouldn't touch the below function unless you know what you're doing :)

function CanSendObjective()
    if Config.Restrict then
        for _, v in pairs(Config.NoRestrictTeams) do
            if LocalPlayer():Team() == v then      
                return true
            end
        end
    else
        return true
    end
end

function CanSeeObjective()

end
