hook.Add("InitPostEntity","VECHUDcheck_HUD",function()
veccoms = veccoms or {}
veccoms.visible = veccoms.visible or 1
veccoms.lowhealthbeep = veccoms.lowhealthbeep or 1
veccoms.lowhealthwiggle = veccoms.lowhealthwiggle or 1

local m = LocalPlayer()
local lhnn = lhnn or CreateSound(m,"ui/test.wav")
local blur,alpha = Material("pp/blurscreen"),128
local bgcol,o = Color(0,0,0,alpha),Color(0,0,0,255)
local a,b,c,v,vv,k,kk,g,gg,x1,x2,y1,y2,xx,yy = 0,1,10,0,0,0,0,0,0,0,0,0,0,0,0
local x,y = ScrW()/2,ScrH()

local function Starlight()
	g = math.sin(CurTime()*6+0.66)*0.05
	gg = math.sin(CurTime()*6)*0.1
	local h,ar = math.Clamp(m:Health(),0,m:GetMaxHealth())/m:GetMaxHealth(),m:Armor() <= 200 and (math.Clamp(m:Armor(),0,200))/200 or (math.Clamp(m:Armor(),0,255))/255
	local w = m:GetActiveWeapon()
	if veccoms.visible ~= 0 then if m:Alive() then
		k = AdvLerp(k,a,b,1,c/2,0.001) v = k kk = AdvLerp(kk,a,b,1,c,0.001) vv = kk
		if veccoms.lowhealthwiggle ~= 0 then if h <= 0.25 then v = k + g vv = kk + gg end end
		if veccoms.lowhealthbeep ~= 0 then if h <= 0.25 then if lhnn:IsPlaying() then lhnn:FadeOut(1) end lhnn:Play() lhnn:ChangeVolume(0.375,0) lhnn:ChangePitch(225,0) end end end
		if not m:Alive() then k = AdvLerp(k,a,b,-1,c/4,0.001) v = k kk = AdvLerp(kk,a,b,-1,c,0.001) vv = kk end
	else k = AdvLerp(k,a,b,-1,c/4,0.001) v = k kk = AdvLerp(kk,a,b,-1,c,0.001) vv = kk end
	if not m:Alive() and v <= 0 and vv <= 0 then return end
	local p1 = {
		{["x"]=x,["y"]=y,["u"]=x/ScrW(),["v"]=y/ScrH()},
		{["x"]=x-v*276,["y"]=y,["u"]=(x-v*276)/ScrW(),["v"]=y/ScrH()},
		{["x"]=x-v*119,["y"]=y-vv*109,["u"]=(x-v*119)/ScrW(),["v"]=(y-vv*109)/ScrH()},
		{["x"]=x-v*81,["y"]=y-vv*109,["u"]=(x-v*81)/ScrW(),["v"]=(y-vv*109)/ScrH()},
		{["x"]=x-v*54,["y"]=y-vv*128,["u"]=(x-v*54)/ScrW(),["v"]=(y-vv*128)/ScrH()},
		{["x"]=x,["y"]=y-vv*128,["u"]=x/ScrW(),["v"]=(y-vv*128)/ScrH()},
		{["x"]=x+v*54,["y"]=y-vv*128,["u"]=(x+v*54)/ScrW(),["v"]=(y-vv*128)/ScrH()},
		{["x"]=x+v*81,["y"]=y-vv*109,["u"]=(x+v*81)/ScrW(),["v"]=(y-vv*109)/ScrH()},
		{["x"]=x+v*119,["y"]=y-vv*109,["u"]=(x+v*119)/ScrW(),["v"]=(y-vv*109)/ScrH()},
		{["x"]=x+v*276,["y"]=y-1,["u"]=(x+v*276)/ScrW(),["v"]=y/ScrH()},
	}
    x1,x2,y1,y2 = (x-v*220)+5,(x+v*220)-5,(y-vv*90)+5,(y+vv*90)-5
	local p2 = {
    	{["x"]=x1-5,["y"]=y,	["u"]=x1/ScrW(),["v"]=y/ScrH()},
    	{["x"]=x,	["y"]=y1-5,	["u"]=x/ScrW(),	["v"]=y1/ScrH()},
    	{["x"]=x2+5,["y"]=y,	["u"]=x2/ScrW(),["v"]=y/ScrH()},
    	{["x"]=x,	["y"]=y2+5,	["u"]=x/ScrW(),	["v"]=y2/ScrH()}
    }
	x1,x2,y1,y2 = (x-v*320)+5,(x+v*320)-5,(y-vv*30)+5,(y+vv*30)-5
	 local p3 = {
    	{["x"]=x1-5,["y"]=y,	["u"]=x1/ScrW(),["v"]=y/ScrH()},
    	{["x"]=x,	["y"]=y1-5,	["u"]=x/ScrW(),	["v"]=y1/ScrH()},
    	{["x"]=x2+5,["y"]=y,	["u"]=x2/ScrW(),["v"]=y/ScrH()},
    	{["x"]=x,	["y"]=y2+5,	["u"]=x/ScrW(),	["v"]=y2/ScrH()}
    }
	surface.SetMaterial(blur)
	for i=0.25,1,0.25 do
		blur:SetInt("$blur",10*i)
		render.UpdateScreenEffectTexture()
		surface.SetDrawColor(0,0,0,255)
		surface.DrawPoly(p1)
		surface.DrawPoly(p2)
		surface.DrawPoly(p3)
		surface.SetDrawColor(bgcol)
	end
    surface.SetTexture(surface.GetTextureID("vgui/white"))
    surface.SetDrawColor(bgcol)
    surface.DrawPoly(p1)
    surface.DrawPoly(p2)
	surface.DrawPoly(p3)
	surface.DrawLine(x-v*182,y,x,y-vv*128)
	surface.DrawLine(x+v*182,y,x,y-vv*128)
	surface.DrawLine(x-v*238,y,x-v*81,y-vv*109)
	surface.DrawLine(x+v*238,y,x+v*81,y-vv*109)
    local htopx,htopy,hbotx,hboty = x-v*31,y-vv*124,x-v*210,y
    local hbarx,hbary = Lerp(h,hbotx,htopx),Lerp(h,hboty,htopy)
	local hpoly = {{["x"]=hbarx-19,["y"]=hbary},{["x"]=hbarx+19,["y"]=hbary},{["x"]=hbotx+19,["y"]=hboty},{["x"]=hbotx-19,["y"]=hboty}}
	if h <= 0.25 then surface.SetDrawColor(math.abs(math.sin(CurTime()*6)*255),64,64,math.abs(math.sin(CurTime()*6)*alpha/2)) else surface.SetDrawColor(255,64,64,alpha/2) end
	surface.DrawPoly(hpoly)
	draw.SimpleText(m:Health(),"TargetID",ScrW()/2-v*75,ScrH()-vv*122,Color(255,0,0,vv*alpha*1.2),2,1)
	surface.SetDrawColor(255,64,64,vv*alpha)
	surface.DrawLine(x-v*75-19,y-vv*93,x-v*75+19,y-vv*93)
	surface.DrawLine(x-v*120-19,y-vv*62,x-v*120+19,y-vv*62)
	surface.DrawLine(x-v*165-19,y-vv*31,x-v*165+19,y-vv*31)
	local atopx,atopy,abotx,aboty = x+v*31,y-vv*124,x+v*210,y
    local abarx,abary = Lerp(ar,abotx,atopx),Lerp(ar,aboty,atopy)
	local apoly = {{["x"]=abarx-19,["y"]=abary},{["x"]=abarx+19,["y"]=abary},{["x"]=abotx+19,["y"]=aboty},{["x"]=abotx-19,["y"]=aboty}}
	if ar <= 0.25 then surface.SetDrawColor(64,math.abs(math.sin(CurTime()*6)*255),64,math.abs(math.sin(CurTime()*6)*alpha/2)) else surface.SetDrawColor(64,255,64,alpha/2)	end
	surface.DrawPoly(apoly)
	draw.SimpleText(m:Armor(),"TargetID",ScrW()/2+v*75,ScrH()-vv*122,Color(0,255,0,vv*alpha),0,1)
	surface.SetDrawColor(64,255,64,vv*alpha)
	surface.DrawLine(x+v*75+19,y-vv*93,x+v*75-19,y-vv*93)
	surface.DrawLine(x+v*120+19,y-vv*62,x+v*120-19,y-vv*62)
	surface.DrawLine(x+v*165+19,y-vv*31,x+v*165-19,y-vv*31)
	draw.SimpleText(os.date("%a,%I:%M:%S%p"),"DermaLarge",x,18+y-vv*2*18,Color(255,255,255,vv*alpha),1,1,1)
	draw.SimpleText("FPS: "..math.floor(1/FrameTime()),"TargetID",x,47+y-vv*2*47,Color(255,255,255,vv*alpha),1,1)	
	if w:IsValid() then
		local clip1 = w:Clip1() > 0 and (math.Clamp(w:Clip1(),0,w:GetMaxClip1())/w:GetMaxClip1()) or 0
		local reswp1 = (math.Clamp(m:GetAmmoCount(w:GetPrimaryAmmoType())  ,0,w:GetMaxClip1() > 0 and w:GetMaxClip1() or 0)/(w:GetMaxClip1() > 0 and w:GetMaxClip1() or 0)) or 0
		local reswp2 = (math.Clamp(m:GetAmmoCount(w:GetSecondaryAmmoType()),0,w:GetMaxClip2() > 0 and w:GetMaxClip2() or 6)/(w:GetMaxClip2() > 0 and w:GetMaxClip2() or 6)) or 0
		local aco = reswp2 > 0 and 0 or 14
		x1,y1,x2,y2 = x-v*103,y-vv*106,x-v*255,y
	    xx,yy = Lerp(clip1,x2,x1),Lerp(clip1,y2,y1)
		local clipoly = {{["x"]=xx-14,["y"]=yy},{["x"]=xx+14,["y"]=yy},{["x"]=x2+14,["y"]=y},{["x"]=x2-14,["y"]=y}}
		x1,y1,x2,y2 = x+v*103,y-vv*106,x+v*255,y
	    xx,yy = Lerp(reswp1,x2,x1),Lerp(reswp1,y2,y1)
		local respoly1 = {{["x"]=xx-14,["y"]=yy},{["x"]=xx+aco,["y"]=yy},{["x"]=x2+aco,["y"]=y},{["x"]=x2-14,["y"]=y}}
		x1,y1,x2,y2 = x+v*103,y-vv*106,x+v*255,y
	    xx,yy = Lerp(reswp2,x2,x1),Lerp(reswp2,y2,y1)
		local respoly2 = {{["x"]=xx,["y"]=yy},{["x"]=xx+14,["y"]=yy},{["x"]=x2+14,["y"]=y},{["x"]=x2,["y"]=y}}	
		local alertcolor = Color(math.abs(math.sin(CurTime()*6)*255),math.abs(math.sin(CurTime()*6)*255),64,math.abs(math.sin(CurTime()*6)*alpha/2))
		if w:GetClass() ~= "none" and w:GetClass() ~= "gmod_camera" then
			if clip1 > 0 then
				draw.SimpleText(w:Clip1(),"TargetID",x-v*145,53.5+y-vv*1.5*104,Color(255,255,0,alpha),2,1)
				if clip1 <= 0.25 then surface.SetDrawColor(alertcolor) else surface.SetDrawColor(255,255,64,alpha/2) end
				surface.DrawPoly(clipoly)
				surface.SetDrawColor(255,255,64,alpha)
				local formax = 5
				for i=1,formax do
					local sidelerp,uplerp = Lerp(i/(formax+1),x-v*103,x-v*255),Lerp(i/(formax+1),y-vv*106,y)
					surface.DrawLine(sidelerp-14,uplerp,sidelerp+14,uplerp)
				end
			end
			if reswp1 > 0 then
				draw.SimpleText(m:GetAmmoCount(w:GetPrimaryAmmoType()) or 0,"TargetID",x+v*145,53.5+y-vv*1.5*104,Color(255,255,0,alpha),0,1)
				if reswp1 <= 0.25 then surface.SetDrawColor(alertcolor) else surface.SetDrawColor(255,255,64,alpha/2) end
				surface.DrawPoly(respoly1)
				surface.SetDrawColor(255,255,64,alpha)
				local formax = 9
				for i=1,formax do
					local sidelerp,uplerp = Lerp(i/(formax+1),x+v*103,x+v*255),Lerp(i/(formax+1),y-vv*106,y)
					if reswp2 > 0 then surface.DrawLine(sidelerp-14,uplerp,sidelerp,uplerp)
					else surface.DrawLine(sidelerp-14,uplerp,sidelerp+14,uplerp) end
				end
			end
			if reswp2 > 0 then
				local pwa,xo = m:GetAmmoCount(w:GetPrimaryAmmoType()),0
				if pwa <= 99 then xo = x+v*159 elseif pwa > 99 and pwa <= 999 then xo = x+v*171 elseif pwa > 999 then xo = x+v*180 end
					draw.SimpleText(" / "..m:GetAmmoCount(w:GetSecondaryAmmoType()) or 0,"TargetID",xo,53.5+y-vv*1.5*104,Color(255,255,0,alpha),0,1)
				if reswp2 <= 0.25 then surface.SetDrawColor(alertcolor) else surface.SetDrawColor(255,255,64,alpha/2) end
				surface.DrawPoly(respoly2)
				surface.SetDrawColor(255,255,64,alpha)
				surface.DrawLine(x+v*103,y-vv*106,x+v*255,y)
				local formax = 5
				for i=1,formax do
					local sidelerp,uplerp = Lerp(i/(formax+1),x+v*103,x+v*255),Lerp(i/(formax+1),y-vv*106,y)
					surface.DrawLine(sidelerp,uplerp,sidelerp+14,uplerp)
				end
			end
		end
	end
end
hook.Add("HUDPaint","VECHUD_HUD",Starlight)

local function hidehud(name)
	for k, v in pairs{"CHudHealth", "CHudBattery","CHudCrosshairs","CHudAmmo","CHudSecondaryAmmo"} do
		if name == v then return false end
	end
end
hook.Add("HUDShouldDraw","hidehud",hidehud)

local function VECHUDCOM_autocomplete(com,args)
	local argv = string.Explode(" ",string.sub(args,2))
	if (table.getn(argv)>1) then 
		if (veccoms[argv[1]]~=nil) then 
			return {com.." "..argv[1].." "..veccoms[argv[1]]}
		else 
			return {}
		end
	end
	local vecc = {}
	for k,v in pairs(veccoms) do
		table.insert(vecc,com.." "..k)
	end
	return vecc
end

local function VECHUDCOM(ply,com,args)
	if ( table.getn(args) < 1 ) then Msg(HUD_PRINTCONSOLE,"No var given!\n"); return end
	if ( veccoms[args[1]] == nil ) then Msg(HUD_PRINTCONSOLE,"Unknown VectorHud var '"..args[1].."'!\n"); return end
	if ( table.getn(args) < 2 ) then Msg(HUD_PRINTCONSOLE,"No value given!\n"); return end
	veccoms[args[1]] = tonumber(args[2])
end
concommand.Add("vechud", VECHUDCOM,VECHUDCOM_autocomplete)
end)
