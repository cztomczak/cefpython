#!/usr/bin/python2

#
# Simple SDL2 / cefpython3 example.
#
# Only handles mouse events but could be extended to handle others.
#
# Requires pysdl2 (and SDL2 library).
#
# Tested under Fedora Linux (x86_64).
#
# by Neil Munday (www.mundayweb.com)
#

import os
import sys
import sdl2
import sdl2.ext
import sdl2.sdlimage
import sdl2.joystick
import sdl2.video
import sdl2.render
import sdl2.sdlgfx
import sdl2.sdlttf

from cefpython3 import cefpython as cef
from PIL import Image

class LoadHandler(object):
	def OnLoadingStateChange(self, browser, is_loading, **_):
		if not is_loading:
			print "loading complete"
			
	def OnLoadError(self, browser, frame, error_code, failed_url, **_):
		if not frame.IsMain():
			return
		print "Failed to load %s" % failed_url
		cef.PostTask(cef.TID_UI, exit_app, browser)

class RenderHandler(object):
	
	def __init__(self, renderer, width, height):
		self.__width = width
		self.__height = height
		self.__renderer = renderer
		self.texture = None
			
	def GetViewRect(self, rect_out, **_):
		rect_out.extend([0, 0, self.__width, self.__height])
		return True
	
	def GetScreenRect(self, browser, rect_out):  # noqa: N802
		return False
	
	def GetScreenPoint(self, browser, view_x, view_y, screen_coordinates_out):
		return False
	
	def OnPaint(self, browser, element_type, paint_buffer, **_):
		#
		# Use PIL to create a set of bytes that we can turn into an SDL2 surface
		# and then convert this to a SDL2 texture for rendering the main program loop.
		#
		if element_type == cef.PET_VIEW:
			data = paint_buffer.GetString(mode="rgba", origin="top-left")
			image = Image.frombuffer('RGBA', (self.__width, self.__height), data, 'raw', 'BGRA')
			#
			# Following PIL to SDL2 surface code from pysdl2 source
			#
			mode = image.mode
			rmask = gmask = bmask = amask = 0
			if mode == "RGB":
				# 3x8-bit, 24bpp
				if sdl2.endian.SDL_BYTEORDER == sdl2.endian.SDL_LIL_ENDIAN:
					rmask = 0x0000FF
					gmask = 0x00FF00
					bmask = 0xFF0000
				else:
					rmask = 0xFF0000
					gmask = 0x00FF00
					bmask = 0x0000FF
				depth = 24
				pitch = self.__width * 3
			elif mode in ("RGBA", "RGBX"):
				# RGBX: 4x8-bit, no alpha
				# RGBA: 4x8-bit, alpha
				if sdl2.endian.SDL_BYTEORDER == sdl2.endian.SDL_LIL_ENDIAN:
					rmask = 0x00000000
					gmask = 0x0000FF00
					bmask = 0x00FF0000
					if mode == "RGBA":
						amask = 0xFF000000
				else:
					rmask = 0xFF000000
					gmask = 0x00FF0000
					bmask = 0x0000FF00
					if mode == "RGBA":
						amask = 0x000000FF
				depth = 32
				pitch = self.__width * 4
			else:
				print "Unsupported mode: %s" % mode
				exit_app()
			
			pxbuf = image.tobytes()
			# create surface
			surface = sdl2.SDL_CreateRGBSurfaceFrom(pxbuf, self.__width, self.__height, depth, pitch, rmask, gmask, bmask, amask)
			
			if self.texture:
				sdl2.SDL_DestroyTexture(self.texture)
			# create texture
			self.texture = sdl2.SDL_CreateTextureFromSurface(self.__renderer, surface)
			sdl2.SDL_FreeSurface(surface)
		else:
			print "Unsupport element_type in OnPaint"

def exit_app():
	sdl2.SDL_Quit()
	cef.Shutdown()
	print "exited"

if __name__ == "__main__":
	
	width = 1024
	height = 768
	headerHeight = 0 # useful if for leaving space for controls at the top of the window (future implementation?)
	browserHeight = height - headerHeight
	browserWidth = width
	
	WindowUtils = cef.WindowUtils()
	
	sys.excepthook = cef.ExceptHook
	
	cef.Initialize(settings={"windowless_rendering_enabled": True})
	
	sdl2.SDL_Init(sdl2.SDL_INIT_VIDEO)
	 
	window = sdl2.video.SDL_CreateWindow('cefpython3 SDL2 Demo', sdl2.video.SDL_WINDOWPOS_UNDEFINED, sdl2.video.SDL_WINDOWPOS_UNDEFINED, width, height, 0)
	
	backgroundColour = sdl2.SDL_Color(0, 0, 0)
	
	renderer = sdl2.SDL_CreateRenderer(window, -1, sdl2.render.SDL_RENDERER_ACCELERATED)
	
	window_info = cef.WindowInfo()
	window_info.SetAsOffscreen(0)
	
	renderHandler = RenderHandler(renderer, width, height - headerHeight)
	
	browser = cef.CreateBrowserSync(window_info, url="https://www.google.com/")
	browser.SetClientHandler(LoadHandler())
	browser.SetClientHandler(renderHandler)
	browser.SendFocusEvent(True)
	browser.WasResized()
	
	running = True
	
	# main loop, handle events and rendering here
	while running:
		
		# convert SDL2 events into CEF events (where appropriate)
		events = sdl2.ext.get_events()
		for event in events:
			if event.type == sdl2.SDL_QUIT or (event.type == sdl2.SDL_KEYDOWN and event.key.keysym.sym == sdl2.SDLK_ESCAPE):
					running = False
					break
				
			if event.type == sdl2.SDL_MOUSEBUTTONDOWN:
				if event.button.button == sdl2.SDL_BUTTON_LEFT:
					if event.button.y > headerHeight:
						browser.SendMouseClickEvent(event.button.x, event.button.y - headerHeight, cef.MOUSEBUTTON_LEFT, False, 1)
			elif event.type == sdl2.SDL_MOUSEBUTTONUP:
				if event.button.button == sdl2.SDL_BUTTON_LEFT:
					if event.button.y > headerHeight:
						browser.SendMouseClickEvent(event.button.x, event.button.y - headerHeight, cef.MOUSEBUTTON_LEFT, True, 1)
			elif event.type == sdl2.SDL_MOUSEMOTION:
				if event.button.y > headerHeight:
					browser.SendMouseMoveEvent(event.button.x, event.button.y - headerHeight, True)
					
		sdl2.SDL_SetRenderDrawColor(renderer, backgroundColour.r, backgroundColour.g, backgroundColour.b, 255)
		sdl2.SDL_RenderClear(renderer)
		
		cef.MessageLoopWork()
		
		sdl2.SDL_RenderCopy(renderer, renderHandler.texture, None, sdl2.SDL_Rect(0, headerHeight, browserWidth, browserHeight))
		
		sdl2.SDL_RenderPresent(renderer)

	exit_app()
	
