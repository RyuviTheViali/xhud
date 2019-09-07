local function VechudInitTargetID()
	local isvisible = isvisible or false
	
	local alpha = 128
	local bgcol = Color(0,0,0,alpha)
	local m = LocalPlayer()
	
	local dsv = 0
	local dev = 1
	local dssv = 16
	local dbv = 0
	local val = 0
	
	local function PropDetails()
		local t = m:GetEyeTrace()
		local v = t.Entity
		if not v:IsPlayer() then
		if t.HitWorld then
			isvisible = false
		else
			isvisible = true
		end
		if isvisible == true then
			if dbv < 0.999 then
				dbv = Lerp(dssv*FrameTime(),dbv,dev)
				val = math.Clamp(dbv,dsv,dev)
			else
				dbv = 1
				val = dbv
			end
		end
		if isvisible == false then
			if dbv > 0.009 then
				dbv = Lerp(dssv*FrameTime(),dbv,dsv)
				val = math.Clamp(dbv,dsv,dev)
			else
				dbv = 0
				val = dbv
			end
		end
		if isvisible == false and val == 0 then return end
		if not v:IsValid() and v ~= game.GetWorld() then return end
		
		local dat  = {{["x"]=ScrW(),["y"]=ScrH()/2+90},{["x"]=ScrW()-val*200,["y"]=ScrH()/2},{["x"]=ScrW(),["y"]=ScrH()/2-90}}
		local dat2 = {{["x"]=ScrW(),["y"]=ScrH()/2+140},{["x"]=ScrW()-val*130,["y"]=ScrH()/2},{["x"]=ScrW(),["y"]=ScrH()/2-140}}
		local dat3 = {{["x"]=ScrW(),["y"]=ScrH()/2+230},{["x"]=ScrW()-val*50,["y"]=ScrH()/2},{["x"]=ScrW(),["y"]=ScrH()/2-230}}
		local owner = v.CPPIGetOwner and v:CPPIGetOwner() or NULL
		owner = owner:IsValid() and owner or "World"
		surface.SetTexture(surface.GetTextureID("vgui/white"))
		if owner and type(owner) == "Player" and owner:IsBanned() then
	   		surface.SetDrawColor(Color(64,16,16,bgcol.a))
	   	else
	   		surface.SetDrawColor(bgcol)
	   	end
	    surface.DrawPoly(dat)
	    surface.DrawPoly(dat2)
	    surface.DrawPoly(dat3)
			local mod = "Model: "..(string.sub(table.remove(string.Explode("/", v:GetModel())), 1,-5) or "N/A")
			local pos = "Pos: "  ..(math.Round(tonumber(v:GetPos().x))   ..", "..math.Round(tonumber(v:GetPos().y))   ..", "..math.Round(tonumber(v:GetPos().z))    or "N/A")
			local ang = "Ang: "  ..(math.Round(tonumber(v:GetAngles().p))..", "..math.Round(tonumber(v:GetAngles().y))..", "..math.Round(tonumber(v:GetAngles().r)) or "N/A")
			local ind = "{"      ..(v:EntIndex() or "N/A").."}"
			local cla = "Class :"..(v:GetClass() or "N/A")
			local own = "Owner: "..(owner and (isstring(owner) and owner or owner:Nick()) or "N/A")
			local c   = owner and isstring(owner) and Color(255,255,255,255) or team.GetColor(owner:Team())
			c = {r=(c.r+64)/255,g=(c.g+64)/255,b=(c.b+64)/255,a=c.a/255}
			
			draw.SimpleTextOutlined(ind,"DefaultSmall",504+ScrW()-val*512,ScrH()/2-55,Color(c.r*85 ,c.g*85 ,c.b*85 ,255),2,1,1,Color(0,0,0,255))
			draw.SimpleTextOutlined(own,"Default"     ,440+ScrW()-val*448,ScrH()/2-40,Color(c.r*180,c.g*180,c.b*180,255),2,1,1,Color(0,0,0,255))
			draw.SimpleTextOutlined(pos,"DefaultLarge",312+ScrW()-val*320,ScrH()/2-20,Color(c.r*200,c.g*200,c.b*200,255),2,1,1,Color(0,0,0,255))
			draw.SimpleTextOutlined(mod,"TargetID"    ,220+ScrW()-val*228,ScrH()/2   ,Color(c.r*255,c.g*255,c.b*255,255),2,1,1,Color(0,0,0,255))
			draw.SimpleTextOutlined(ang,"DefaultLarge",312+ScrW()-val*320,ScrH()/2+20,Color(c.r*180,c.g*180,c.b*180,255),2,1,1,Color(0,0,0,255))
			draw.SimpleTextOutlined(cla,"Default"     ,440+ScrW()-val*448,ScrH()/2+40,Color(c.r*128,c.g*128,c.b*128,255),2,1,1,Color(0,0,0,255))
		end
	end
	hook.Add("HUDPaint","Vechud_TargetID",PropDetails)
end

hook.Add("InitPostEntity","Vechud_InitTargetID",VechudInitTargetID)

if LocalPlayer and LocalPlayer():IsValid() then
	VechudInitTargetID()
end