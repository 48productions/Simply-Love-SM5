local args = ...
local SongWheel = args[1]
local TransitionTime = args[2]
local row = args[3]
local col = args[4]

local CloseFolderTexture = nil
local NoJacketTexture = nil

-- max number of characters allowed in a song title before truncating to ellipsis
local max_chars = 17

local song_mt = {
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
					subself:diffusealpha(0)
				end,
				OnCommand=function(subself)
					subself:finishtweening():sleep(0.25):linear(0.25):diffusealpha(1):queuecommand("PlayMusicPreview")
				end,

                -- Position jackets when moving from group to song selection
				StartCommand=function(subself)
					-- slide the chosen Actor into place
					if self.index == SongWheel:get_actor_item_at_focus_pos().index then
						subself:queuecommand("SlideToTop")
						MESSAGEMAN:Broadcast("SwitchFocusToSingleSong")

					-- hide everything else
					else
						subself:decelerate(0.2):addy(70):diffusealpha(0)
					end
				end,
                -- Hide everything so we can go to group selection
				HideCommand=function(subself)
					stop_music()
                    subself:decelerate(0.2):diffusealpha(0)
                    if self.index ~= SongWheel:get_actor_item_at_focus_pos().index then
                        subself:addy(70)
                    end
				end,
                -- Move back to song selection from difficulty selection
				UnhideCommand=function(subself)

					-- we're going back to song selection
					-- slide the chosen song ActorFrame back into grid position
					if self.index == SongWheel:get_actor_item_at_focus_pos().index then
						subself:playcommand("SlideBackIntoGrid")
						MESSAGEMAN:Broadcast("SwitchFocusToSongs")
					else
                        subself:decelerate(0.25):diffusealpha(1):addy(-70)
                    end
				end,
                -- Move from song to difficulty selection (selected song only)
				SlideToTopCommand=function(subself)
                    subself:sleep(0.01)
                    if AllowThonk() then subself:bezier(0.4, {0, 0, 0.3, -3, 0.6, 3, 1, 1}) else subself:decelerate(0.3) end
                    subself:xy(col.w * WideScale(1.5, 2.25), _screen.cy-67)
                end,
                -- Move from difficulty to song selection (selected song only)
				SlideBackIntoGridCommand=function(subself)
                    subself:sleep(0.01)
                    if AllowThonk() then
                        subself:linear(0.3):y(-75):linear(0):xy( col.w * (6 - 1.75), _screen.h):linear(0.2)
                    else
                        subself:decelerate(0.3)
                    end
                    subself:xy( col.w * (6 - 1.75), row.h * 2 )
                end,

				-- wrap the function that plays the preview music in its own Actor so that we can
				-- call sleep() and queuecommand() and stoptweening() on it and not mess up other Actors
				Def.Actor{
					InitCommand=function(subself) self.preview_music = subself end,
					PlayMusicPreviewCommand=function(subself) play_sample_music() end,
				},

				-- AF for Banner and blinking Quad
				Def.ActorFrame{
					GainFocusCommand=function(subself) subself:y(10) end,
					LoseFocusCommand=function(subself) subself:y(0) end,
					SlideToTopCommand=function(subself) subself:y(0) end,
					SlideBackIntoGridCommand=function(subself) subself:y(10) end,

					-- blinking quad behind banner
					Def.Quad{
						InitCommand=function(subself) subself:diffuse(0,0,0,0):zoomto(0,0) end,
                        OnCommand=function(subself)
                            if self.index == SongWheel:get_actor_item_at_focus_pos().index then
                                subself:diffusealpha(0):sleep(self.index * 0.05):smooth(0.1):diffusealpha(1)
                            end
                        end,
						GainFocusCommand=function(subself)
							if self.song == "CloseThisFolder" then
								subself:visible(false)
							else
								subself:visible(true):linear(0.2):diffusealpha(1):zoomto(128, 128)
									:diffuseramp():effectcolor2(0.75,0.75,0.75,1):effectcolor1(0,0,0,1):effectclock("beat"):effectperiod(1)
							end
						end,
						LoseFocusCommand=function(subself) subself:visible( false):diffusealpha(0):stopeffect():zoomto(0,0) end,
						SlideToTopCommand=function(subself) subself:linear(0.12):zoomto(112, 112) end,
						SlideBackIntoGridCommand=function(subself) subself:linear(0.12):zoomto(128,128) end
					},

					-- banner / jacket
					Def.Sprite{
						Name="Banner",
						InitCommand=function(subself) self.banner = subself; subself:diffusealpha(0) end,
						OnCommand=function(subself)
                            subself:zoomto(55,5):sleep(self.index * 0.05):smooth(0.1):diffusealpha(1)
                            if self.index ~= SongWheel:get_actor_item_at_focus_pos().index then
                                subself:zoomto(55,55)
                            else
                                subself:zoomto(126,126)
                            end
                            subself:queuecommand("Refresh")
                        end,
						RefreshCommand=function(subself)
							subself:scaletoclipped(45,45)
							if self.index ~= SongWheel:get_actor_item_at_focus_pos().index then
								subself:zoomto(55,55)
							else
								subself:zoomto(126,126)
							end
							--subself:diffusealpha(1)
						end,
						GainFocusCommand=function(subself)
							subself:decelerate(0.2):zoomto(126,126):stopeffect()
							if self.song == "CloseThisFolder" then
								subself:diffuseshift():effectcolor1(1,0.65,0.65,1):effectcolor2(1,1,1,1)
							end
						end,
						LoseFocusCommand=function(subself) subself:decelerate(0.2):zoomto(55,55):stopeffect() end,
						SlideToTopCommand=function(subself) subself:linear(0.3):zoomto(110,110):rotationy(360):sleep(0):rotationy(0) end,
						SlideBackIntoGridCommand=function(subself) subself:linear(0.12):zoomto(126,126) end,
					},
				},

				-- title
				Def.BitmapText{
					Font="Common Normal",
					InitCommand=function(subself)
						self.title_bmt = subself
						subself:zoom(0.8):diffuse(Color.White):shadowlength(0.75):maxwidth(80)
					end,
                    OnCommand=function(subself)
                        subself:diffusealpha(0):sleep(self.index * 0.05):smooth(0.1)
                        if self.index ~= SongWheel:get_actor_item_at_focus_pos().index then subself:diffusealpha(1) end
                    end,
					GainFocusCommand=function(subself)
						if self.song == "CloseThisFolder" then
							subself:decelerate(0.1):y(10):zoom(0.9)
						else
							subself:decelerate(0.05):diffusealpha(0)
						end
					end,
					LoseFocusCommand=function(subself)
						if self.song == "CloseThisFolder" then
							subself:decelerate(0.1):zoom(0.8)
						else
							subself:sleep(0.05):decelerate(0.05):zoom(0.725):diffusealpha(1)
						end
						subself:y(40)
					end,
				},
			}

			return af
		end,

		transform = function(self, item_index, num_items, has_focus)

			self.container:finishtweening()
			stop_music()

			if has_focus then
				if self.song ~= "CloseThisFolder" then
					GAMESTATE:SetCurrentSong(self.song)
					MESSAGEMAN:Broadcast("CurrentSongChanged", {song=self.song})

					-- wait for the musicgrid to settle for at least 0.2 seconds before attempting to play preview music
					self.preview_music:stoptweening():sleep(0.2):queuecommand("PlayMusicPreview")
				else
					MESSAGEMAN:Broadcast("CloseThisFolderHasFocus")
				end
				self.container:playcommand("GainFocus")
			else
				self.container:playcommand("LoseFocus")
			end

			-- Chain all below commands to happen over this period of time:
			self.container:decelerate(0.2)

			local middle_index = math.floor(num_items/2)
			--local middle_index = 6

						
			--Song icons loop around to the opposite side of the screen if they go off one edge, so fade out banners that leave the screen
			if item_index == 1 or item_index > num_items-2 then
				self.container:diffusealpha(0)
			else
				self.container:diffusealpha(1)
			end
			

			-- Position icons in the bottom row
			if item_index ~= middle_index  then
                self.container:y( AllowThonk() and (row.h * 3 + (20 * math.sin(2 * item_index))) or (row.h * 3) )
                self.container:x( col.w * (item_index - 1.75))

			-- Now position the center row icon
			elseif item_index == middle_index then
				self.container:y( row.h * 2 ):x( col.w * (6 - 1.75))
			end
		end,

		set = function(self, song)

			if not song then return end

			self.img_path = ""
			self.img_type = ""

			-- this SongMT was passed the string "CloseThisFolder"
			-- so this is a special case song metatable item
			if type(song) == "string" then
				self.song = song
				self.title_bmt:settext( THEME:GetString("ScreenSelectMusicCasual", "CloseThisFolder") )
				self.img_path = THEME:GetPathB("ScreenSelectMusicCasual", "overlay/img/CloseThisFolder.png")

				if CloseFolderTexture ~= nil then
					self.banner:SetTexture(CloseFolderTexture)
				else
					-- we should only get in here and need to Load() directly from
					-- from disk once, on screen init
					self.banner:Load(self.img_path)
					CloseFolderTexture = self.banner:GetTexture()
				end
			else
				-- we are passed in a Song object as info
				self.song = song
				self.title_bmt:settext( self.song:GetDisplayMainTitle() ):Truncate(max_chars)

				if song:HasJacket() then
					self.img_path = song:GetJacketPath()
					self.img_type = "Jacket"
				elseif song:HasBackground() then
					self.img_path = song:GetBackgroundPath()
					self.img_type = "Background"
				elseif song:HasBanner() then
					self.img_path = song:GetBannerPath()
					self.img_type = "Banner"
				else
					self.img_path = nil
					self.img_type = nil

					if NoJacketTexture ~= nil then
						self.banner:SetTexture(NoJacketTexture)
					else
						self.banner:Load( THEME:GetPathB("ScreenSelectMusicCasual", "overlay/img/no-jacket.png") )
						NoJacketTexture = self.banner:GetTexture()
					end
					return
				end

				-- thank you, based Jousway
				if (Sprite.LoadFromCached ~= nil) then
					self.banner:LoadFromCached(self.img_type, self.img_path)

				-- support SM5.0.12 begrudgingly
				else
					self.banner:LoadBanner(self.img_path)
				end
			end
		end
	}
}

return song_mt