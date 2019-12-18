local waiting = false
local casino = ""
local seconds = 0
local blip = nil
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

RegisterNetEvent('esx_casinoheist:isrobbing')
AddEventHandler('esx_casinoheist:isrobbing', function(robb)
			waiting = true
			casino = robb
			seconds = 300
end)

RegisterNetEvent('esx_casinoheist:stopblip')
AddEventHandler('esx_casinoheist:stopblip', function()
	RemoveBlip(blipCasino)
end)

RegisterNetEvent('esx_casinoheist:setblip')
AddEventHandler('esx_casinoheist:setblip', function(position)
	blipCasino = AddBlipForCoord(position.x, position.y, position.z)
	SetBlipSprite(blipCasino , 500)
	SetBlipScale(blipCasino , 0.6)
	SetBlipColour(blipCasino , 5)
	PulseBlip(blipCasino)
end)	

RegisterNetEvent('esx_casinoheist:goneawaylocal')
AddEventHandler('esx_casinoheist:goneawaylocal', function(robb)
		waiting = false
		ESX.ShowNotification(_U('heist_cancelled'))
		casinoName = ""
		seconds = 0
		incircle = false
end)

RegisterNetEvent('esx_casinoheist:heistcomplete')
AddEventHandler('esx_casinoheist:heistcomplete', function(robb)
	waiting = false
	ESX.ShowNotification(_U('heist_complete') .. Casino[casino].reward)
	casino = ""
	seconds = 0
	incircle = false
end)

Citizen.CreateThread(function()
	for k,v in pairs(Casino)do
		local ve = v.position

		local blip = AddBlipForCoord(ve.x, ve.y, ve.z)
		SetBlipSprite(blip, 255)--156
		SetBlipScale(blip, 0.8)
		SetBlipColour(blip, 75)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('casino_heist'))
		EndTextCommandSetBlipName(blip)
	end
end)

incircle = false

Citizen.CreateThread(function()
	while true do
		local pos = GetEntityCoords(GetPlayerPed(-1), true)

		for k,v in pairs(Casino)do
			local pos2 = v.position

			if(Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) < 15.0)then
				if not waiting then
					DrawMarker(1, v.position.x, v.position.y, v.position.z - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 1555, 0, 0,255, 0, 0, 0,0)

					if(Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) < 1.0)then
						if (incircle == false) then
							DisplayHelpText(_U('press_to_rob') .. v.casinoname)
						end
						incircle = true
						if IsControlJustReleased(1, 51) then
							TriggerServerEvent('esx_casinoheist:rob', k)
						end
					elseif(Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) > 1.0)then
						incircle = false
					end
				end
			end
		end

		if waiting then

				drawTxt(0.66, 1.44, 1.0,1.0,0.4, _U('heist_of') .. secondsRemaining .. _U('seconds_remaining'), 255, 255, 255, 255)

				local pos2 = Casino[casino].position

					if(Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) > 7.5)then
							TriggerServerEvent('esx_casinoheist:toofar', casino)
					end
		end

		Citizen.Wait(0)
	end
end)	