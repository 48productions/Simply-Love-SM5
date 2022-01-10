local optionrow_mt = {
	__index = {
		create_actors = function(self, name)
			self.name=name

			-- this is a terrible way to do this
			local item_index = name:gsub("item", "")
			self.index = item_index

			local af = Def.ActorFrame{
				Name=name,
				InitCommand=function(subself)
					self.container = subself
					subself:diffusealpha(0):queuecommand("Hide2")
				end,
				OnCommand=function(subself) subself:y(item_index * 62) end,

				HideCommand=function(subself) subself:linear(0.2):diffusealpha(0):queuecommand("Hide2") end,
				Hide2Command=function(subself) subself:visible(false) end,

				UnhideCommand=function(subself) subself:visible(true):queuecommand("Unhide2") end,
				Unhide2Command=function(subself) subself:sleep(0.3):linear(0.2):diffusealpha(1) end,

				-- helptext
				Def.BitmapText{
					Font="Common Normal",
					InitCommand=function(subself)
						self.helptext = subself
						subself:horizalign(left):zoom(0.9)
							:diffuse(Color.White):diffusealpha(0.5)
					end,
					GainFocusCommand=function(subself) subself:diffusealpha(0.85) end,
					LoseFocusCommand=function(subself) subself:diffusealpha(0.5) end
				},

				-- bg quad
				Def.Quad{
					InitCommand=function(subself)
						self.bgQuad = subself
						subself:horizalign(left):zoomto(200, 95):diffuse(color_slate2):diffusealpha(0.5)
					end,
					OnCommand=function(subself) subself:y(65) end,
					GainFocusCommand=function(subself) subself:diffusealpha(1) end,
					LoseFocusCommand=function(subself) subself:diffusealpha(0.5) end,
				},

				Def.ActorFrame{
					Name="Cursor",
					InitCommand=function(subself) self.cursor = subself end,
					OnCommand=function(self) self:y(26) end,
					LoseFocusCommand=function(subself) subself:diffusealpha(0) end,
					GainFocusCommand=function(subself) subself:diffusealpha(1) end,

					-- arrow
					Def.ActorFrame{
						Name="Arrow",
						OnCommand=function(subself) subself:x(-16):y(28):bounce():effectclock("beatnooffset"):effectmagnitude(-3,0,0):effectperiod(1) end,
						PressCommand=function(subself)
							subself:decelerate(0.05):zoom(0.7):glow(1,1,1,0.086)
							       :accelerate(0.05):zoom(  1):glow(1,1,1,0)
						end,
						ExitRowCommand=function(subself, params)
                            subself:visible(false)
							--[[subself:y(-15)
							if params.PlayerNumber == PLAYER_2 then subself:x(20) end]]--
						end,
						SingleSongCanceledMessageCommand=function(subself) subself:rotationz(0) end,
						BothPlayersAreReadyMessageCommand=function(subself) subself:finishtweening():sleep(0.05):decelerate(0.2):rotationz(180) end,
						CancelBothPlayersAreReadyMessageCommand=function(subself) subself:rotationz(0) end,

						LoadActor("./img/arrow_glow.png")..{
							Name="RightArrowGlow",
							InitCommand=function(subself) subself:zoom(0.15) end,
							OnCommand=function(subself) subself:diffuseshift():effectcolor1(1,1,1,0):effectcolor2(1,1,1,1) end
						},
						LoadActor("./img/arrow.png")..{
							Name="RightArrow",
							InitCommand=function(subself) subself:zoom(0.15):diffuse(Color.White) end,
						}
					},
				},
                
                -- Ready icon (when player has chosen difficulty)
                Def.Sprite{
                    Name="ReadyIcon",
                    Texture=THEME:GetPathG("", "Checkmark (doubleres).png"),
                    Condition= self.name == "item1", -- Only load if this is the difficulty optionrow and not the "Press START" optionrow
                    InitCommand=function(subself) subself:zoom(0.8):diffusealpha(0):rotationz(-50):xy(-22, 60) end,
                    LoseFocusCommand=function(subself) subself:finishtweening():decelerate(0.3):rotationz(0):diffusealpha(1) end,
                    GainFocusCommand=function(subself) subself:finishtweening():decelerate(0.15):rotationz(-50):diffusealpha(0) end,
                }
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)

			self.container:finishtweening()

			if has_focus then
				self.container:playcommand("GainFocus")
			else
				self.container:playcommand("LoseFocus")
			end
		end,

		set = function(self, optionrow)
			if not optionrow then return end
			self.helptext:settext( optionrow.HelpText )
			if optionrow.HelpText == "" then -- Hide the BG Quad for the "Exit" option row
				self.bgQuad:visible(false)
			end
		end
	}
}

return optionrow_mt