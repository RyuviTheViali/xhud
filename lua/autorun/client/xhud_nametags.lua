local function XHUDNameTagsInit()
	--vechud nametags
	
	local blur = Material("pp/blurscreen")
	local alpha = 100
	local bgcol = Color(0,0,0,alpha)
	local m = LocalPlayer()
	local o = Color(0,0,0,255)
	
	local a,b,c,n,nn,l,ll,o,oo,g = 0,1,16,0,0,{},{},{},{},{}
	local x1,x2,y1,y2 = {},{},{},{}
	local pp1,pp2,pp3 = {},{},{}
	local tw,th = {},{}
	local font  = "Default"
	
	local function vechudnametags()
		n = math.sin(CurTime()*6+0.66)*0.2
		nn = math.sin(CurTime()*6)*0.2
		for k,v in pairs(player.GetAll()) do
			if v == m then continue end
			if not v:IsValid() then return end
			local p = (v:EyePos()+Vector(0,0,20)):ToScreen()
			x1[k],x2[k],y1[k],y2[k] = x1[k] or 0,x2[k] or 0,y1[k] or 0,y2[k] or 0
			o[k] ,oo[k],l[k] ,ll[k] = o[k]  or 0.5,oo[k] or 0.5,l[k]  or 0,ll[k] or 0
			tw[k],th[k],g[k] 		= tw[k] or 0,th[k] or 0,g[k]  or 0
			g[k] = math.Clamp(v:Health(),0,v:GetMaxHealth())/v:GetMaxHealth()
			local p1,p2,p3 = pp1[k],pp2[k],pp3[k]
		    if v:Alive() then 
		    	if not v:Crouching() then
		    	o[k] = AdvLerp(o[k],a,b,1,c,0.001) l[k] = o[k]
		    	oo[k] = AdvLerp(oo[k],a,b,1,c,0.001) ll[k] = oo[k]
		    	else
		    		o[k] = AdvLerp(o[k],a,b,-1,c,0.001) l[k] = o[k]
		    		oo[k] = AdvLerp(oo[k],a,b,-1,c,0.001) ll[k] = oo[k]
	    		end
	    		if g[k] <= 0.25 and not v:Crouching() then l[k] = o[k] + n ll[k] = oo[k] + nn else l[k] = o[k] end
		    else 
		    	o[k] = AdvLerp(o[k],a+0.25,b,-1,c,0.001) l[k] = o[k]
		    	oo[k] = AdvLerp(oo[k],a+0.25,b,-1,c,0.001) ll[k] = oo[k]
		    end
			if l[k] <= 0 and ll[k] <= 0 then continue end
			local pname = v:Nick():gsub("%^%d+", ""):gsub("<(.-)=(.-)>", "")
			surface.SetFont(font)
			local x1,x2,y1,y2,l,ll,x,y,w,h = x1[k],x2[k],y1[k],y2[k],l[k],ll[k],p.x,p.y,tw[k],th[k]
			w,h = surface.GetTextSize(pname)
			w,h = w,h*3
			local t = team.GetColor(v:Team())
			if x < 0 or x > ScrW() then continue end
			if y < 0 or y > ScrH() then continue end
			
			x1,x2,y1,y2 = (x-l*w*0.8)+5,(x+l*w*0.8)-5,(y-ll*h*0.2)+5,(y+ll*h*0.2)-5
		    p1 = {
		    	{["x"]=x1-5,["y"]=y,	["u"]=x1/ScrW(),["v"]=y/ScrH()},
		    	{["x"]=x,	["y"]=y1-5,	["u"]=x/ScrW(),	["v"]=y1/ScrH()},
		    	{["x"]=x2+5,["y"]=y,	["u"]=x2/ScrW(),["v"]=y/ScrH()},
		    	{["x"]=x,	["y"]=y2+5,	["u"]=x/ScrW(),	["v"]=y2/ScrH()}
		    }
		    x1,x2,y1,y2 = (x-l*w*0.6)+5,(x+l*w*0.6)-5,(y-ll*h*0.4)+5,(y+ll*h*0.4)-5
			p2 = {
		    	{["x"]=x1-5,["y"]=y,	["u"]=x1/ScrW(),["v"]=y/ScrH()},
		    	{["x"]=x,	["y"]=y1-5,	["u"]=x/ScrW(),	["v"]=y1/ScrH()},
		    	{["x"]=x2+5,["y"]=y,	["u"]=x2/ScrW(),["v"]=y/ScrH()},
		    	{["x"]=x,	["y"]=y2+5,	["u"]=x/ScrW(),	["v"]=y2/ScrH()}
		    }
			x1,x2,y1,y2 = (x-l*w*0.4)+5,(x+l*w*0.4)-5,(y-ll*h*0.6)+5,(y+ll*h*0.6)-5
			p3 = {
		    	{["x"]=x1-5,["y"]=y,	["u"]=x1/ScrW(),["v"]=y/ScrH()},
		    	{["x"]=x,	["y"]=y1-5,	["u"]=x/ScrW(),	["v"]=y1/ScrH()},
		    	{["x"]=x2+5,["y"]=y,	["u"]=x2/ScrW(),["v"]=y/ScrH()},
		    	{["x"]=x,	["y"]=y2+5,	["u"]=x/ScrW(),	["v"]=y2/ScrH()}
		    }
			surface.SetMaterial(blur)
			for i=0.25,1,0.25 do
				blur:SetInt("$blur",5*i)
				render.UpdateScreenEffectTexture()
				surface.SetDrawColor(0,0,0,128)
				surface.DrawPoly(p1)
				surface.SetDrawColor(bgcol)
				surface.DrawPoly(p2)
				surface.DrawPoly(p3)
			end
			
			surface.SetTexture(surface.GetTextureID("vgui/white"))
			surface.SetDrawColor(t.r,t.g,t.b,alpha)
			surface.DrawPoly(p1)
			surface.SetDrawColor(bgcol)
			surface.DrawPoly(p2)
			if g[k] <= 0.25 then
				if v:Alive() then
					surface.SetDrawColor(math.abs(math.sin(CurTime()*6)*255),0,0,math.abs(math.sin(CurTime()*6)*l*alpha/2))
				else
					surface.SetDrawColor(128,0,0,alpha/2)
				end
			else
				surface.SetDrawColor(bgcol)
			end
			surface.DrawPoly(p3)
			draw.SimpleTextOutlined(pname,font,p.x,p.y,Color(255,255,255,ll*255),1,1,1,Color(0,0,0,ll*255))
		end
	end
	hook.Add("HUDPaint","vechudnametags",vechudnametags)
end
XHUDNameTagsInit()
hook.Add("InitPostEntity","VECHUDcheck_NameTags",XHUDNameTagsInit)
