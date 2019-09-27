XHUD = XHUD or {}

XHUD.Nametags = XHUD.Nametags or {}

local n = XHUD.Nametags

n.ValidNametag = function(tag)
	if tag == false                  then return true end
	if tag == nil                    then return true end
	if isstring(tag) and #tag < 1024 then return true end
end

local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:SetNametagTitle(title)
	if title == "" then
		title = nil
	end
	
	if not n.ValidNametag(title) then return false end
	
	self:SetNetData("XHUDNametagTitle",title)
end

function PlayerMeta:GetNametagTitle()
	return self:GetNetData("XHUDNametagTitle")
end

n.NametagNetData = function(ply,key,nametag)
	if key ~= "XHUDNametagTitle"     then return end
	if not n.ValidNametag(title) then return false end
	
	if SERVER then return true end
	
	local ent = player.UserIDToEntity(ply)
	
	if IsValid(ent) then
		ent.NametagTitle = nametag or false
	end
	
	local lp = LocalPlayer()
	lp = IsValid(lp) and lp
	
	if lp and ply == lp:UserID() then
		if GetConVarNumber("xhud_nametags_report_change") == 1 then
			Msg("[XHUD:Nametags] Saved nametag '"..tostring(nametag or "[NULL Nametag]").."'")
		end
		
		nametag = (not nametag or nametag == "") and " " or nametag
		
		if not file.IsDir("xenora","DATA") then
			file.CreateDir("xenora")
		end
		
		file.Write("xenora/nametag_title.txt",nametag)
	end
	
	return true
end
hook.Add("NetData","XHUDNametags",n.NametagNetData)

if CLIENT then
	n.NametagsVisible      = CreateClientConVar("xhud_nametags"              ,1,true,true ,"XHUD: Toggle visibility of nametags above players")
	n.NametagsReportChange = CreateClientConVar("xhud_nametags_report_change",0,true,false,"XHUD: Report back if a player's nametag changes"  )
	
	n.Fonts = {
		Nametag = {font="Helvetica",size=64,weight=0,antialias=true,prettyblur=1}
	}

	for k,v in pairs(XHUD.Nametags.Fonts) do
		surface.CreateFont("XNametag_"..k,v)
	end
	
	n.Initialized           = false
	n.HDRCheck              = true
	n.HDR                   = nil
	n.LocalPlayer           = LocalPlayer()
	n.EyePos                = Vector()
	n.EyeAngles             = Vector()
	n.UnitVector            = Vector(1,1,1)
	n.VectorDown            = Vector(0,0,-1)
	n.VectorUp              = Vector(0,0, 1)
	n.NametagAngle          = Angle(0,0,90)
	n.FrameNumber           = 0
	n.LastFrameNumber       = 0
	n.Spacing               = 1.5
	n.FontScale             = 0.1
	n.NametagVerticalOffset = 16
	n.NametagFadeDist       = 1024
	n.Renderables           = {}

	n.Colors = {
		Black = Color(0  ,0  ,0  ,255),
		White = Color(255,255,255,255),
		AFK   = Color(100,100,100,255)
	}
	
	n.PlayerColors = {
		["0"]  = Color(0  ,0  ,0  ),
		["1"]  = Color(128,128,128),
		["2"]  = Color(192,192,192),
		["3"]  = Color(255,255,255),
		["4"]  = Color(0  ,0  ,128),
		["5"]  = Color(0  ,0  ,255),
		["6"]  = Color(0  ,128,128),
		["7"]  = Color(0  ,255,255),
		["8"]  = Color(0  ,128,0  ),
		["9"]  = Color(0  ,255,0  ),
		["10"] = Color(128,128,0  ),
		["11"] = Color(255,255,0  ),
		["12"] = Color(128,0  ,0  ),
		["13"] = Color(255,0  ,0  ),
		["14"] = Color(128,0  ,128),
		["15"] = Color(255,0  ,255)
	}
	
	n.Initialize = function()
		if n.Initialized then return end
		
		n.Initialized = true
		
		local title = file.Read("xenora/nametag_title.txt",nametag)
		
		n.LocalPlayer = LocalPlayer()
		n.LocalPlayer:SetNametagTitle(title)
	end
	hook.Add("InitPostEntity","XHUDNametagsInit",n.Initialize)
	
	if n.LocalPlayer:IsValid() then n.Initialize() end
	
	n.RenderSceneUpdate = function(pos,ang)
		n.EyePos,n.EyeAngles,n.FrameNumber = pos,ang,FrameNumber()
	end
	hook.Add("RenderScene","XHUDNametagsRenderScene",n.RenderSceneUpdate)
	
	n.GetPlayerHeadPos = function(ply)
		local pos
		local bone = ply:GetAttachment(ply:LookupAttachment("eyes"))
		
		pos = bone and bone.Pos or nil
		
		if not pos then
			local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
			
			pos = bone and ply:GetBonePosition(bone) or ply:EyePos()
		end
		
		return pos
	end
	
	n.GetPlayerName = function(ply,data)
		local name = ply:Nick()
		local last = data.XHUDNametagsLastCleanName
		
		if name ~= last then
			last = name:gsub("%^%d+",""):gsub("<(.-)=(.-)>","")
			data.XHUDNametagsLastCleanName = last
		end
		
		return last
	end
	
	n.ParseHexColor = function(col)
		if not col then
			col = "ff00ff"
		end
	
		col     = col:upper()
		local l = col:len()
		
		local rgb
		
		if l == 6 or l == 8 then
			rgb = {}
			
			for pair in string.gmatch(col,"%x%x") do
				local i = tonumber(pair,16)
				if i then
					table.insert(rgb,i)
				end
			end
	
			while #rgb < 4 do
				table.insert(rgb,255)
			end
		elseif l == 3 then
			rgb = {}
			
			for pair in string.gmatch(col,"%x") do
				local i = tonumber(pair..pair,16)
				if i then
					table.insert(rgb,i)
				end
			end
	
			while #rgb < 4 do
				table.insert(rgb,255)
			end
		end
	
		return rgb and Color(unpack(rgb))
	end

	n.LookingAtNametag = function(ply,pos)
		local forward = n.EyeAngles:Forward()
		local forvec  = pos-n.EyePos
		local dot     = forward:Dot(forvec)/forvec:Length()

		return dot >= 0.975
	end
	
	n.RenderNametag = function(ply,alpha,data,ragdoll)
		surface.SetFont("XNametag_Nametag")
		
		local ent = ragdoll:IsValid() and ragdoll or ply
		
		local  scale = ply.pac_model_scale and (ply.pac_model_scale.x+ply.pac_model_scale.y+ply.pac_model_scale.z)/3 or ply:GetModelScale()
		local zscale = scale
		
		if scale < 1 then
			 scale = 0.4+scale*0.6
			zscale = 0.7+scale*0.3
		end
		
		local headpos = n.GetPlayerHeadPos(ent)+ent:GetUp()*(n.NametagVerticalOffset*zscale)
		
		local text = n.GetPlayerName(ply,data)
		local w,h  = surface.GetTextSize(text)
		local size = 0.6*scale*n.FontScale
		local namecol
		
		for col in string.gmatch(ply:Nick(),"%^(%d+)") do
			namecol = n.PlayerColors[col]
		end
		
		for h,s,v in string.gmatch(ply:Nick(),"<hsv=(%d+%.?%d*),(%d+%.?%d*),(%d+%.?%d*)>") do
			namecol = HSVToColor(h,s,v)
		end
		
		for r,g,b in string.gmatch(ply:Nick(),"<color=(%d+%.?%d*),(%d+%.?%d*),(%d+%.?%d*)>") do
			namecol = Color(r,g,b,255)
		end
		
		for hex in string.gmatch(ply:Nick(),"<c=([0123456789abcdefABCDEF]+)>") do
			namecol = n.ParseHexColor(hex) or nil
		end
		
		local col = namecol and namecol or team.GetColor(ply:Team())
		
		n.Colors.Black.a = alpha
		n.Colors.White.a = alpha
		n.Colors.AFK.a   = alpha
		col.a            = alpha
		
		cam.Start3D2D(headpos,n.NametagAngle,size)
			surface.SetTextColor(col)
			surface.SetTextPos(-0.5*w,0)
			surface.DrawText(text)
		cam.End3D2D()
		
		local heightoffset = h*n.Spacing
		
		local title = data.NametagTitle
		
		if title == nil then
			title = ply:GetNametagTitle()
		end
		
		if title then
			local w,h = surface.GetTextSize(title)
			cam.Start3D2D(headpos,n.NametagAngle,scale*n.FontScale*0.4)
				surface.SetTextColor(n.Colors.White)
				surface.SetTextPos(-w/2,heightoffset)
				surface.DrawText(title)
			cam.End3D2D()
			
			heightoffset = heightoffset+(h*n.Spacing*(1/scale))
		end

		local isafk = PlayerMeta.IsAFK and ply:IsAFK() or false
		
		if isafk then
			local w,h = surface.GetTextSize("[AFK]")
			
			cam.Start3D2D(headpos,n.NametagAngle,scale*n.FontScale*0.3)
				surface.SetTextColor(n.Colors.AFK)
				surface.SetTextPos(-w/2,-n.Spacing*h/n.Spacing)
				surface.DrawText("[AFK]")
			cam.End3D2D()
		end

		if not data.NametagExtraInfo then
			data.NametagExtraInfo = 0
		end

		if ply ~= n.LocalPlayer and n.LookingAtNametag(ply,headpos) or n.LocalPlayer:GetEyeTrace().Entity == ply and  then
			data.NametagExtraInfo = Lerp(0.5,data.NametagExtraInfo,1)
		else
			data.NametagExtraInfo = Lerp(0.5,data.NametagExtraInfo,0)
		end

		if data.NametagExtraInfo > 0 then
			local teamname = team.GetName(ply:Team())
			teamname = teamname:sub(1,1):upper()..teamname:sub(2,teamname:sub(-1) == "s" and -2 or -1)
			local w,h  = surface.GetTextSize(teamname)
			local tcol = team.GetColor(ply:Team())
			tcol.a     = alpha*data.NametagExtraInfo
			
			cam.Start3D2D(headpos,n.NametagAngle,scale*n.FontScale*0.3)
				surface.SetTextColor(tcol)
				surface.SetTextPos(-w/2,-n.Spacing*h*(isafk and 1.5 or 0.66))
				surface.DrawText(teamname)
			cam.End3D2D()
		end
	end
	
	n.RenderPlayerNametags = function()
		if not n.NametagsVisible:GetBool()          then return end
		if LocalPlayer():GetNWBool("XHUDHideNames") then return end
		
		local tonemap
		
		if n.HDR then
			tonemap = render.GetToneMappingScaleLinear()
			render.SetToneMappingScaleLinear(n.UnitVector)
		elseif n.HDRCheck then
			n.HDRCheck = false
			local tonemap = render.GetToneMappingScaleLinear()
			n.HDR = tonemap.x ~= 1 or tonemap.y ~= 1 or tonemap.z ~= 1
		end
		
		n.NametagAngle = n.EyeAngles*1
		
		n.NametagAngle:RotateAroundAxis(n.NametagAngle:Up()     ,-90)
		n.NametagAngle:RotateAroundAxis(n.NametagAngle:Forward(), 90)
		
		local currentframenumber = n.FrameNumber-1
		
		for k,v in next,n.Renderables do
			if not k:IsValid() then
				n.Renderables[k] = nil
				continue
			end
			
			local ragdoll = k:GetRagdollEntity()
			
			if v ~= currentframenumber and not ragdoll then continue end
			
			local playereyepos = k:EyePos()
			
			if playereyepos:Distance(n.EyePos) > n.NametagFadeDist or k:Crouching() then continue end
			
			local data = k:GetTable()
			local pixvis = data.XHUDNametagPixVis
			
			if not pixvis then
				pixvis = util.GetPixelVisibleHandle()
				data.XHUDNametagPixVis = pixvis
			end
			
			local pvis = util.PixelVisible(playereyepos,32,pixvis)
			
			if pvis > 0 then
				local lightcolor = render.GetLightColor(playereyepos)
				local rr,gg,bb = lightcolor.x,lightcolor.y,lightcolor.z
				
				if bb+rr*2+gg*3 < 0.006 and 
					render.ComputeDynamicLighting(playereyepos,n.VectorDown):Length() == 0 and
					render.ComputeDynamicLighting(playereyepos,n.VectorUp  ):Length() == 0 then
						continue
				end
				
				pvis = pvis > 0.5 and 1 or pvis
				
				n.RenderNametag(k,pvis*255,data,ragdoll)
			end
		end
		
		if tonemap then
			render.SetToneMappingScaleLinear(tonemap)
		end
	end
	hook.Add("PostDrawTranslucentRenderables","XHUDNametagsRender",n.RenderPlayerNametags)
	
	n.AnimationsCheck = function(ply)
		if ply == n.LocalPlayer and not ply:ShouldDrawLocalPlayer() then return end
		
		n.Renderables[ply] = n.FrameNumber
	end
	hook.Add("UpdateAnimation","XHUDNametagsUpdateAnimation",n.AnimationsCheck)
else
	hook.Add("Tick","XHUDNametagsInitialInit",function()
		if XSYS_FUNCTIONAL then
			xsys.AddCommand("title",function(ply,txt,target,title)
				if not title or not ply:CheckUserGroupLevel("developers") then
					ply:SetNametagTitle(txt or "")
				else
					local ent = easylua.FindEntity(target)
					
					if not IsValid(ent) or not ent:IsPlayer() then return false,xsys.NoTarget(target) end
					
					ent:SetNametagTitle(title)
				end
			end,"players")
			
			hook.Remove("Tick","XHUDNametagsInitialInit")
		end
	end)
end