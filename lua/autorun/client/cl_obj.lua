local w = ScrW()
local h = ScrH()
local a = 255
local aIn = 0
local initA = 255
local SoundObj = "batdr_sfx_keybreak.wav"
local SoundObj2 = "sfx_objective_complete.wav"
local mat = Material("objective.png")
local i1 = Material("interact_1.png")
local i2 = Material("interact_2.png")
local i3 = Material("interact_3.png")
local startTime = CurTime()
local timeToEnd = 5.51
local Cooldown = false
local soundWarning = "insane_sounds.wav"
local act = "Interact"
local OverlayMat = Material("Overlay_InkVignette_02.png")
local x, y = ScrW() * .38, ScrH() * 0.05

-- Some ConVars
local lightUI = CreateClientConVar("batdr_objective_lightui", "0", true, false)
local perfSound = CreateClientConVar("batdr_lowhp_sound", "0", true, false)
local drawInteraction = CreateClientConVar("batdr_interaction_draw", "1", true, false)
local upperCase = CreateClientConVar("batdr_objective_uppercase", "1", true, false)


local function ScaleFontSize(baseFontSize)
    local screenWidth = ScrW()
    local screenHeight = ScrH()
    
    local scaleFactor = math.min(screenWidth, screenHeight) / 1080

    local scaledFontSize = baseFontSize * scaleFactor
    
    return scaledFontSize
end

surface.CreateFont("Objective-Font20", {

    font = "Caviar Dreams",

    size = ScaleFontSize(20),

    weight = 3700,

    antialias = true,

    shadow = false

})

surface.CreateFont("Objective-Font40", {

    font = "Caviar Dreams",

    size = ScaleFontSize(40),

    weight = 3700,

    antialias = true,

    shadow = false

})

surface.CreateFont("Objective-Font35", {

    font = "Caviar Dreams",

    size = ScaleFontSize(35),

    weight = 3700,

    antialias = true,

    shadow = false

})

surface.CreateFont("Objective-Font30", {

    font = "Caviar Dreams",

    size = ScaleFontSize(30),

    weight = 3700,

    antialias = true,

    shadow = false

})

hook.Add( "OnPlayerChat", "HelloCommand", function( ply, strText, bTeam, bDead ) 
    if ( ply != LocalPlayer() ) then return end

    if string.sub(strText, 1, 10) == "/objective" then
        
        local arguments = string.sub(strText, 12)
        
        LocalPlayer():ConCommand("batdr_objective_add "..arguments)

    end
end ) -- Chat command for the addon

concommand.Add( "batdr_objective_add", function( sender, cmd, args, argStr )

    if not (CanSendObjective) then return end

    if Cooldown then sender:ChatPrint("You must wait before using this again.") return end

    newObj = true

    if #args == 0 then sender:ChatPrint("Invalid objective!") return end

    local msg = table.concat(args," ")

    if upperCase:GetBool() then
        msg = string.upper(msg)    
    end
    
    Cooldown = true

    surface.PlaySound(SoundObj)

    timer.Simple(.5, function()

        surface.PlaySound(SoundObj2)

    end)

    timer.Simple(7, function() Cooldown = false end)

    hook.Add("HUDPaint", "ObjHUD", function()

        if newObj then
            

            timer.Simple(3.5, function()
                hook.Add("Think", "FixAlpha", function() 
    
                    a = a - 2
     
                end)
            end)            

            math.Clamp(a, 0, 255) -- Alpha cant go under or above 0 or 255

        end        
        
        hook.Add("Think", "FixUIStuff", function()
        
            if lightUI:GetBool() then
    
                mat = Material("ui_archgate_objective.png")
        
            else 
        
                mat = Material("objective.png")
        
            end

        end)

        surface.SetMaterial(mat) -- Set the material for the rectangle to the png

        surface.SetDrawColor( 255, 255, 255, a ) -- Set color to white (color already present in the png)
        
        surface.DrawTexturedRect( x, y, w / 3.6, h / 8 ) -- Draw Object PNG

        if lightUI:GetBool() then
    
            draw.DrawText("N E W  O B J E C T I V E", "Objective-Font20", w / 1.932, h / 19, Color(0,0,0,a), TEXT_ALIGN_CENTER)

            draw.DrawText(msg, "Objective-Font40", w/1.932, h / 11, Color(255,255,255,a), TEXT_ALIGN_CENTER)
    
        else 
    
            draw.DrawText("N E W  O B J E C T I V E", "Objective-Font20", w/1.932, h / 19 + 2.5, Color(255,255,255,a), TEXT_ALIGN_CENTER)

            draw.DrawText(msg, "Objective-Font40", w/1.932, h / 11, Color(255,255,255,a), TEXT_ALIGN_CENTER)
    
        end

    end)

    local function ResetAll()    

        hook.Remove("HUDPaint", "ObjHUD") -- Remove HUDPaint hook to be rendered again later
        
        hook.Remove("Think", "FixAlpha")

        a = initA -- reset Alpha 

        newObj = false -- reset

    end

    hook.Add("Think", "Watcher", function()
        if a <= 10 then
            ResetAll()
        end
    end)

end )   

hook.Add("HUDPaint", "InkVignette", function()

    if LocalPlayer():Health() <= 25 then

        if perfSound then

            surface.PlaySound(soundWarning)
            
        end

        surface.SetMaterial(OverlayMat) -- Set the material for the rectangle to the png

        surface.SetDrawColor( 255, 255, 255, 255 ) -- Set color to white (color already present in the png)
                
        surface.DrawTexturedRect( 0, 0, w, h ) -- Draw Object PNG

    end
end)

hook.Add("Think","Mbrap", function()

    if LocalPlayer():Health() <= 25 then

        hook.Add("RenderScreenspaceEffects", "LowHP", function()

            local tab = {

                ["$pp_colour_addr"] = 0,

                ["$pp_colour_addg"] = 0,

                ["$pp_colour_addb"] = 0,

                ["$pp_colour_brightness"] = 0,

                ["$pp_colour_contrast"] = 1,

                ["$pp_colour_colour"] = 0,

                ["$pp_colour_mulr"] = 0.5,

                ["$pp_colour_mulg"] = 0.5,

                ["$pp_colour_mulb"] = 0.5

            }
            
            DrawColorModify( tab )

        end)

    else

        hook.Remove("RenderScreenspaceEffects", "LowHP")
        
    end

end)

hook.Add("HUDPaint", "DrawInteraction", function()

    hook.Add("Think", "Interactions", function()

        local e = LocalPlayer():GetEyeTrace().Entity
    
        if !(IsValid(e)) then shouldDrawInteract = false return else shouldDrawInteract = true end
    
        if (LocalPlayer():GetPos() - e:GetPos() ):LengthSqr() > (80^2 * 2) then
            shouldDrawInteract = false
        end
    
        if e:IsNPC() then return end
        if e:IsPlayer() then return end

        if (drawInteraction:GetBool() == false) then shouldDrawInteract = false end
    
    end)

    
    
    if shouldDrawInteract then  
        hook.Remove("Think", "FixAlphaInteractionMinus")  
        hook.Add("Think", "FixAlphaInteractionPlus", function() 
            aIn = aIn + 10 * 2
        end)

        if aIn > 255 then
            aIn = 255 -- lua being weird
        end
    else
        hook.Remove("Think", "FixAlphaInteractionPlus")
        hook.Add("Think", "FixAlphaInteractionMinus", function() 
            aIn = aIn - 10 * 2
        end)

        if aIn < 0 then 
            aIn = 0 -- lua being weird
        end
    end

    
    
    if lightUI:GetBool() == true then
        surface.SetMaterial(Material("ui_title_menu_difficulty_box_02.png")) -- Set the material for the rectangle to the png

        surface.SetDrawColor( 255, 255, 255, aIn ) -- Set color to white (color already present in the png)
                
        surface.DrawTexturedRect( w / 2.65, h / 1.172, w / 3.8,  h / 12 ) -- Draw Object PNG

        draw.DrawText("Press E to "..act, "Objective-Font30", w / 1.975, h / 1.14 , Color(255,255,255, aIn), 1)
    else
        surface.SetMaterial(i1) -- Set the material for the rectangle to the png

        surface.SetDrawColor( 255, 255, 255, aIn ) -- Set color to white (color already present in the png)
            
        surface.DrawTexturedRect( w / 2.16, h / 1.255, w / 10.8,  h / 7 ) -- Draw Object PNG

        draw.DrawText("E", "Objective-Font35", w / 1.975, h / 1.21, Color(197, 155, 54, aIn), 1)

        draw.DrawText(act, "Objective-Font30", w / 1.975, h / 1.14 , Color(197, 155, 54, aIn), 1)
    end

end)
