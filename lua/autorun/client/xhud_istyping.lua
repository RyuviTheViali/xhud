local function IsTypingInit()

	veccoms = veccoms or {}
	veccoms.istyping = veccoms.istyping or 1

	local alpha = 200
	local bgcol = Color(0,0,0,alpha)
	local m = LocalPlayer()
	local o = Color(0,0,0,255)
	local pls = 40
	local vv,nn = {},{}
	local poly1 = {}
	local poly2 = {}
	local poly3 = {}
	local tw,th = {},{}
	local font  = "Default"
	
	local function vechudplayerchatting()
		for k,v in pairs(player.GetAll()) do
			nn[k] = nn[k] or 0
			vv[k] = vv[k] or 0
			if veccoms.istyping == 1 and coh.cdata[v] and isstring(coh.cdata[v]) and not coh.cdata[v]:find("\n") then
				vv[k] = AdvLerp(vv[k],0,1,1,16,0.001)
				nn[k] = math.sin(CurTime()+(v:EntIndex()/#player.GetAll())*12)*0.3
			else vv[k] = AdvLerp(vv[k],0,1,-1,16,0.001) end
			if not v:GetNetData("IsTyping") and vv[k] == 0 then continue end
			local vvv = vv[k]
			local pvv = vvv+nn[k]
			local pname = v:Nick():gsub("%^%d+", ""):gsub("<(.-)=(.-)>", "")
			surface.SetFont(font)
			tw[k],th[k] = surface.GetTextSize(pname)
			local tw,th = tw[k],th[k]
			local t = team.GetColor(v:Team())
			surface.SetTexture(surface.GetTextureID("vgui/white"))
			if xsys.xban and v:IsBanned() then
				surface.SetDrawColor(Color(64,16,16,bgcol.a))
			else
				surface.SetDrawColor(bgcol)
			end
			poly1[k] = {{["x"]=0,["y"]=(256+(k*pls))-100},{["x"]=pvv*(tw*0.15),["y"]=256+(k*pls)},{["x"]=0,["y"]=(256+(k*pls))+100}}
			poly2[k] = {{["x"]=0,["y"]=(256+(k*pls))-60 },{["x"]=pvv*(tw*0.70),["y"]=256+(k*pls)},{["x"]=0,["y"]=(256+(k*pls))+60 }}
			poly3[k] = {{["x"]=0,["y"]=(256+(k*pls))-25 },{["x"]=pvv*(tw*1.30),["y"]=256+(k*pls)},{["x"]=0,["y"]=(256+(k*pls))+25 }}
			surface.DrawPoly(poly1[k])
			surface.DrawPoly(poly2[k])
			surface.SetDrawColor(Color(t.r,t.g,t.b,vv[k]*alpha/2))
			surface.DrawPoly(poly3[k])
			draw.SimpleTextOutlined(pname,font,-tw*2+6+vvv*tw*2,256+(k*pls),Color(255,255,255,255),0,1,1,Color(0,0,0,255))
		end
	end
	hook.Add("HUDPaint","vechudplayerchatting",vechudplayerchatting)
end

hook.Add("InitPostEntity","Vechud_IsTypingInit",IsTypingInit)

if LocalPlayer and LocalPlayer():IsValid() then
	IsTypingInit()
end