# -*- coding=utf8 -*-



import os
from PIL import Image
import numpy
import generate_movesets as gm 
import re 
import shutil 

import subprocess 



def is_shiny(sprite_path):
	# A Shiny sprite has an "s" after the number.
	sprite_filename = sprite_path.split("\\")[-1]
	return "s" in sprite_filename



class SCRecolorMenu:
	# Class handling the recoloring of a sprite. 
	
	
	def __init__(self):
		# Initialises.
		
		# A dictionary: color name -> RGBA vector
		self.color_dict = {}
		
		# A dictionary: color name -> simpler name/ description 
		self.color_desc = {}
		
		# Fill the previous dictionaries.
		self.load_colors()
		
		# Translating vector. Default value to be changed after. 
		self.translate_vect = numpy.zeros(4)
		
		# Regular expression matching a selection of colors: number;number;...;number 
		self.re_list = re.compile("\d+(;\d+)*")
		
		# Regular expression matching a selection of colors ended by a try. 
		# number;number;...;number;try 
		# try is a command used for making the script try all colors in the sprite.
		# Makes exhaustive help. 
		self.re_list_try = re.compile("\d+(;\d+)*;try")
		
		# Temporary variable used to store the different attempts. 
		self.colors_to_change_try = [] 
	
	
	
	def load_colors(self):
		# Loads the colors from the file. 
		
		# Reinit. Just in case. 
		self.color_dict = {}
		self.color_desc = {}
		
		with open("color_names.csv", "r") as f:
			for line in f:
				# Line is of the form:
				# color name;R;G;B;description
				clean_line = line.replace("\r","")
				clean_line = clean_line.replace("\n","")			
				content = clean_line.split(";")
				# content = [ color name , R , G , B , description ]
				
				if content[0] == "":
					continue 
				
				# Makes the RGBA number. 
				vector = [int(content[1]), int(content[2]), int(content[3]), 255]
				
				# Stores the vector correspondig to the color name.
				self.color_dict[content[0]] = numpy.array(vector)
				
				# Stores the description of the color. 
				self.color_desc[content[0]] = content[4]
	
	
	
	def closest_color(self, other_color):
		# Finds the closest color to other_color in the color stored in color_dict. 
		# Returns a list of three elements: 
		# [ name of closest color , distance to closest color , vector of closest color ] 
		
		closest_name = "black"
		closest_dist = 1000
		closest_vect = numpy.array([0, 0, 0, 0])
		
		# Just in case
		other_vect = numpy.array(other_color)
		
		# Transrant colors; we don't care. 
		if other_color[3] == 0:
			return ["transparent", 0, closest_vect]
		
		for col in self.color_dict.keys():
			# Compute distance with L2 norm. 
			temp_dist = numpy.linalg.norm(other_vect - self.color_dict[col])
			
			if temp_dist <= closest_dist:
				closest_name = col
				closest_dist = temp_dist
				closest_vect = self.color_dict[col]
		
		return [closest_name, closest_dist, closest_vect]
	
	
	
	def get_all_colors(self, sprite_file):
		# Lists all the colors that appear in the sprite_file.
		# sprite_file is a string containing the path to the sprite. 
		# Returns a dictionary: vector RGBA -> number of pixels with that color. 
		
		all_colors = {}
		img_original = Image.open(sprite_file)
		
		# Scans all pixels and get its color. 
		for pixel in img_original.getdata():
			if pixel in all_colors:
				all_colors[pixel] += 1
			else:
				all_colors[pixel] = 1
		
		img_original.close()
		
		return all_colors
	
	
	
	def get_all_colors_several(self, double_sprite_files, for_shinies):
		# Gets all colors from the list of files in double_sprite_files. 
		# double_sprite_files = the result of SCPokedexModificationMenu.list_all_sprites
		# List of pairs [ original sprite path , new sprite path ]
		# if for_shinies is True, then get only the colors of the Shinies.
		# If false, then get only the colors of the non-shinies. 
		# Returns a dictionary: vector RGBA -> number of pixels with that color. 
		
		all_colors = {}
		
		for sprite_double in double_sprite_files:
			# sprite_double = list [ original sprite path , new sprite path ]
			
			# Take shinies only if for_shinies is True, otherwise take 
			# non shinies. 
			if for_shinies == is_shiny(sprite_double[0]):
				img_original = Image.open(sprite_double[0])
				img_original = img_original.convert("RGBA")
				
				# Scans all pixels and gets its color. 
				for pixel in img_original.getdata():
					if pixel in all_colors:
						all_colors[pixel] += 1
					else:
						all_colors[pixel] = 1
				
				img_original.close()
		
		return all_colors
	
	
	
	def name_colors(self, all_colors):
		# all_colors = dictionary: RGBA vector -> int
		# Returns a dictionary: RGBA vector -> [ corresponding color name (string) ,
		# 						distance to the color name center , color name vector ]
		
		res = {}
		
		for col in all_colors.keys():
			res[col] = self.closest_color(col)
		
		return res 
	
	
	
	def add_pixels(self, pix1, pix2, no_check = True):
		# Performs an addition of RGBA pixels. 
		# If overflow, and no_check is False, I am using a technique 
		# to stay between 0 and 255 (see to_pixel method)
		return self.to_pixel(pix1 + pix2, no_check)
	
	
	
	def diff_pixels(self, pix1, pix2, no_check = True):
		# Performs a difference of RGBA pixels. 
		# If overflow, and no_check is False, I am using a technique 
		# to stay between 0 and 255 (see to_pixel method)
		return self.add_pixels(pix1, -1* pix2, no_check)
	
	
	
	def to_pixel(self, ary, no_check = True):
		# Converts the given ary (numpy pixel or array-like)
		# If overflow, and no_check is False, I am using a technique 
		# to stay between 0 and 255 (see to_pixel method)
		
		if not no_check:
			for i in range(len(ary)):
				if ary[i] < 0:
					ary[i] = -0.5 * ary[i]
					# If -7 then converts to +3.5
				elif ary[i] > 255:
					ary[i] = 255 - 0.5 * (ary[i] - 255)
					# If 260 then converts to 255-2.5 = 252.5 
					
		return tuple([int(a) for a in ary])
	
	
	
	def change_color(self, color_names, old_color, new_color, max_distance = 60.0):
		# color_names = the result of name_colors, that is, a dictionary: 
		# 				RGBA vector -> [ corresponding color name (string) ,
		# 					distance to the color name center , color name vector ]
		# old_color = numpy array RGBA 
		# new_color = numpy array RGBA 
		
		# This will contain the "conversion": 
		new_scheme = {} 
		
		# Translation 
		self.translate_vect = self.diff_pixels(new_color, old_color)
		
		for color_tuple in color_names.keys():
			# Check closest_color to see what color_tuple is made off. 
			color_vect = numpy.array(color_tuple)
			temp_dist = numpy.linalg.norm(color_vect - old_color)
			
			if temp_dist < max_distance:
				new_scheme[color_tuple] = self.add_pixels(color_vect, self.translate_vect)
			else:
				new_scheme[color_tuple] = self.to_pixel(color_vect)
		
		return new_scheme 
	
	
	
	def translate_colors(self, color_names, colors_to_change, first_new_color):
		# print(color_names)
		# This will contain the "conversion": 
		new_scheme = {}
		coeff = 1.0
		
		# input(color_names)		
		
		
		
		new_col = numpy.array(self.color_dict[first_new_color])
		i = 0
		
		
		while not self.no_overflow(new_scheme) and i < len(colors_to_change):
			old_col = numpy.array(self.color_dict[colors_to_change[i]])
			# print(old_col)
			self.translate_vect = self.diff_pixels(coeff * new_col, coeff * old_col, True)
			
			for color_tuple in color_names.keys():
				# print(color_stuff)
				# Check closest_color to see what color_stuff is made off. 
				
				if color_names[color_tuple][0] in colors_to_change:
					color_vect = numpy.array(color_tuple)
					new_scheme[color_tuple] = self.add_pixels(color_vect, self.translate_vect, False)
		
			i+= 1
			
		old_col = numpy.array(self.color_dict[colors_to_change[0]])
		while not self.no_overflow(new_scheme):
			self.translate_vect = self.diff_pixels(coeff * new_col, coeff * old_col, True )
			
			for color_tuple in color_names.keys():
				# print(color_stuff)
				# Check closest_color to see what color_stuff is made off. 
				
				if color_names[color_tuple][0] in colors_to_change:
					color_vect = numpy.array(color_tuple)
					new_scheme[color_tuple] = self.add_pixels(color_vect, self.translate_vect, False)
		
			# coeff = 0.8 * coeff 
			
		# print(coeff)
		# print(new_scheme)
		return new_scheme 
	
	
	
	def no_overflow(self, new_scheme):
		if not new_scheme:
			return False 
			
		for original_color in new_scheme.keys():
			if min(new_scheme[original_color]) < 0 or max(new_scheme[original_color]) > 255:
				return False 
		return True 
	
	
	
	def change_color_by_names(self, color_names, old_color_name, new_color_name, max_distance = 60.0):
		old_color = self.color_dict[old_color_name]
		new_color = self.color_dict[new_color_name]
		
		return self.change_color(color_names, old_color, new_color, max_distance)
	
	
	
	def apply_changes(self, source_file, target_file, new_scheme):
		img = Image.open(source_file)
		
		for x in range(img.size[0]):
			for y in range(img.size[1]):
				pixel = img.getpixel((x,y))
				if pixel in new_scheme.keys():
					img.putpixel((x,y), new_scheme[pixel])
		
		img.save(target_file)
		img.close()
		subprocess.call(["explorer", target_file])
	
	
	
	def apply_changes_several(self, double_sprite_files, for_shinies, new_scheme):
		# print(len(new_scheme))
		for sprite_double in double_sprite_files:
			if is_shiny(sprite_double[0]) == for_shinies:
				img = Image.open(sprite_double[0])
				img = img.convert("RGBA")
				# if "b" in sprite_double[0].split("\\")[-1]:
					# input(sprite_double[0])
				
				cpt = 0 
				for x in range(img.size[0]):
					for y in range(img.size[1]):
						pixel = img.getpixel((x,y))
						if pixel in new_scheme.keys():
							img.putpixel((x,y), new_scheme[pixel])
							cpt+= 1
							
				# if "b" in sprite_double[0].split("\\")[-1]:
					# print(cpt)
					# input(sprite_double[0])
					
				
				img.save(sprite_double[1])
				img.close()
			# else:
				# print(sprite_double[0])
	
	
	def recolor_sprite(self, source_file, target_file, old_color_name, new_color_name, max_distance = 60.0):
		all_colors = self.get_all_colors(source_file)
		color_names = self.name_colors(all_colors)
		new_scheme = self.change_color_by_names(color_names, old_color_name, new_color_name, max_distance)
		self.apply_changes(source_file, target_file, new_scheme)
	
	
	
	def recolor_sprite_interactive(self, source_file, target_file, old_colors = None, new_color = ""):
		print("Recoloring " + source_file)
		print("Target file: " + target_file)
		
		subprocess.call(["explorer", source_file])
		
		all_colors = self.get_all_colors(source_file)
		# input(all_colors)
		color_names = self.name_colors(all_colors)
		
		only_color_names = [color_names[k][0] for k in color_names.keys()]
		
		# Tell the user about the present colors.
		colors_we_dont_care = ["black", "transparent", "white"] 
		colors_to_change = [] if old_colors is None else old_colors
		# new_color = "" 
		
		right_color_list = False 
		happy_with_color = False 
		
		while (not right_color_list) and (not happy_with_color):
			
			# First, choose the colors to change. 
			while not right_color_list:
				skip_test = False 
				print("Present colors: ")
				for key in all_colors.keys():
					if color_names[key][0] not in colors_we_dont_care:
						col0 = color_names[key][0]
						col_desc = self.color_desc[col0]
						print(col0.ljust(30) + col_desc.ljust(40) + ": " + str(all_colors[key]))
				
				
				if len(colors_to_change) > 0:
					print("Change the following colors?")
					for col in colors_to_change:
						print(col)
					ans = input("? [y]/n ")
					
					if ans == "n":
						right_color_list = False
						skip_test = True 
						colors_to_change = [] 
					else:
						right_color_list = True 
						
				else:
					print("Change what colors? (use semicolons \";\")")
					
					colors_to_change = input("? ")
					colors_to_change = colors_to_change.split(';')
					
					right_color_list = True 
				
				if not skip_test:
					# Verify the colors?
					for col in colors_to_change:
						if col not in only_color_names:
							print("The color \"" + col + "\" is not in the sprite.")
							right_color_list = False 
				
				happy_with_color = False 
			
			
			
			while not happy_with_color:
				
				while new_color not in self.color_dict.keys():
					new_color = input("Change the colors to what? ")
					
				new_scheme = self.translate_colors(color_names, colors_to_change, new_color)
				
				self.apply_changes(source_file, target_file, new_scheme)
				
				ans = input("Happy? ([y]/n/c)")
				
				if len(ans) > 1:
					if ans in self.color_dict.keys():
						new_color = ans
						
					elif ans == "other":
						# Change another color on the sprite. 
						source_file = target_file
						all_colors = self.get_all_colors(source_file)
						color_names = self.name_colors(all_colors)
						
						only_color_names = [color_names[k][0] for k in color_names.keys()]
						happy_with_color = True  
						right_color_list = False 
						new_color = ""
						
					else:
						print("Color " + ans + " not understood.")
				elif ans == "n":
					happy_with_color = False 
					new_color = ""
				elif ans == "c":
					happy_with_color = True  
					right_color_list = False 
					new_color = ""
				else:
					happy_with_color = True 
				
			if happy_with_color and not right_color_list:
				happy_with_color = False 
		
		print("Done :)")
		
		return colors_to_change, new_color
	
	
	
	def recolor_sprite_interactive_several(self, double_sprite_files, for_shinies):
		# print("Recoloring " + source_file)
		
		print("--------------------------------------------------")
		
		if for_shinies:
			print("Handling shinies sprites")
		else:
			print("Handling normal sprites")
		
		input(double_sprite_files)
		
		all_colors = self.get_all_colors_several(double_sprite_files, for_shinies)
		# print(len(all_colors))
		color_names = self.name_colors(all_colors)
		# print(len(color_names))
		
		only_color_names = list(dict.fromkeys([color_names[k][0] for k in color_names.keys()]))
		
		# Tell the user about the present colors.
		colors_we_dont_care = ["black", "transparent", "white"] 
		only_color_names = [col for col in only_color_names if col not in colors_we_dont_care]
		colors_to_change = []
		new_color = "" 
		
		right_color_list = False 
		happy_with_color = False 
		
		exhaustive_attempt = 0 
		self.colors_to_change_try = []
		old_ans = "" 
		
		while (not right_color_list) and (not happy_with_color):
			
			# First, choose the colors to change. 
			while not right_color_list:
				skip_test = False 
				
				if len(colors_to_change) == 0:
					print("Present colors: ")
					
					color_presentation = []
					cpt = 0 
					halflen = int((len(only_color_names)+1) / 2)
					
					for col0 in only_color_names:
						cpt += 1
						col_desc = self.color_desc[col0]
						if cpt > halflen:
							color_presentation[cpt - halflen-1] += str(cpt).ljust(5) + col0.ljust(25) + col_desc.ljust(25)
						else: 
							color_presentation.append(str(cpt).ljust(5) + col0.ljust(25) + col_desc.ljust(25))
						
					for s in color_presentation:
						print(s)
				
				
					# print("Change the following colors?")
					# for col in colors_to_change:
						# print(col)
					# ans = input("? [y]/n ")
					
					# if ans == "n":
						# right_color_list = False
						# skip_test = True 
						# colors_to_change = [] 
					# else:
					# right_color_list = True 
					
				print("Change what colors? (use semicolons \";\")")
				# input(all_colors_keys)
				colors_to_change = input("? ")
				colors_to_change = colors_to_change.split(';')
				colors_to_change = [only_color_names[int(c)-1] for c in colors_to_change if c != "" and int(c) <= len(only_color_names)]
				# colors_to_change = [color_names[k][0] for k in color_names.keys() if color_names[k][0] in colors_to_change]
				# colors_to_change = [color_names[c][0] for c in colors_to_change]
				# print(colors_to_change)
				right_color_list = True 
				
				if not skip_test:
					# Verify the colors?
					for col in colors_to_change:
						if col not in only_color_names:
							print("The color \"" + col + "\" is not in the sprite.")
							right_color_list = False 
				
				happy_with_color = False 
			
			
			
			while not happy_with_color:
				
				while new_color not in self.color_dict.keys():
					new_color = input("Change the colors to what? ")
					
				new_scheme = self.translate_colors(color_names, colors_to_change, new_color)
				
				self.apply_changes_several(double_sprite_files, for_shinies, new_scheme)
				
				ans = input("Happy? ([y]/n/c/color name) ")
				
				
				res = self.re_list.match(ans)
				res_try = self.re_list_try.match(ans)
				
				if res_try:
					# Then it's a list of colors, and one of the colors I want to find. 
					colors_to_change = ans.split(";")
					self.colors_to_change_try = [int(c)-1 for c in colors_to_change if c != "" and c != "try" and int(c) <= len(only_color_names)]
					exhaustive_attempt = 1
					old_ans = ans 
					exhaustive_attempt, colors_to_change = self.next_exhaustive_attempt(old_ans, exhaustive_attempt, only_color_names)
				elif res:
					# Then it's a new list of colors.
					colors_to_change = ans.split(';')
					colors_to_change = [only_color_names[int(c)-1] for c in colors_to_change if c != "" and int(c) <= len(only_color_names)]
					
					
				elif len(ans) > 1:
					if ans in self.color_dict.keys():
						new_color = ans
						
					elif ans == "other":
						# Change another color on the sprite. 
						double_sprite_files = [ [ d[0], d[1] ] for d in double_sprite_files ]
						
						# source_file = target_file
						all_colors = self.get_all_colors_several(double_sprite_files, for_shinies)
						color_names = self.name_colors(all_colors)
						
						only_color_names = list(dict.fromkeys([color_names[k][0] for k in color_names.keys()]))
						only_color_names = [col for col in only_color_names if col not in colors_we_dont_care]
						happy_with_color = True  
						right_color_list = False 
						new_color = ""
						colors_to_change = []
						
					elif ans == "reload":
						
						for d in double_sprite_files:
							shutil.copyfile(d[0], d[1])
						happy_with_color = True  
						right_color_list = False 
						new_color = ""
						
					else:
						print("Color " + ans + " not understood.")
				elif ans == "n":
					happy_with_color = False 
					new_color = ""
				elif ans == "c":
					happy_with_color = True  
					right_color_list = False 
					new_color = ""
				elif ans == "" and exhaustive_attempt > 0:
					# Then try the next color. 
					exhaustive_attempt += 1 
					
					exhaustive_attempt, colors_to_change = self.next_exhaustive_attempt(old_ans, exhaustive_attempt, only_color_names)
					# print(self.colors_to_change_try)
				else:
					happy_with_color = True 
					
					
				if exhaustive_attempt == 0:
					old_ans = "" 
					self.colors_to_change_try = []
					
					
			if happy_with_color and not right_color_list:
				happy_with_color = False 
		
		print("Done :)")
		
		return colors_to_change, new_color
	
	
	
	def next_exhaustive_attempt(self, old_ans, exhaustive_attempt, only_color_names):
		
		while exhaustive_attempt < len(only_color_names) and exhaustive_attempt in self.colors_to_change_try:
			exhaustive_attempt += 1 
			
		if exhaustive_attempt == len(only_color_names):
			# Then it's done. We've tried everything.
			print("All colors tried.")
			colors_to_change = old_ans.split(";")
			colors_to_change = [only_color_names[int(c)-1] for c in colors_to_change if c != "" and c != "try" and int(c) <= len(only_color_names)]
			return 0, colors_to_change
			
		else:
			# Then we reached an integer that's not already listed. Let's try it. 
			colors_to_change = old_ans.replace("try", str(exhaustive_attempt + 1))
			
			print("Trying: " + colors_to_change)
			
			colors_to_change = colors_to_change.split(";")
			colors_to_change = [only_color_names[int(c)-1] for c in colors_to_change if c != "" and int(c) <= len(only_color_names)]
			self.colors_to_change_try.append(exhaustive_attempt)
			
			return exhaustive_attempt, colors_to_change
	
	
	
	
	def generate_all_colors(self, source_file, target_file):
		all_colors = self.get_all_colors(source_file)
		color_names = self.name_colors(all_colors)
		
		only_color_names = [color_names[k][0] for k in color_names.keys()]
		
		# Tell the user about the present colors.
		colors_we_dont_care = ["black", "transparent", "white"] 
		colors_to_change = []
		new_color = "" 
		
		right_color_list = False 
		happy_with_color = False 
		
		# First, choose the colors to change. 
		while not right_color_list:
			print("Present colors: ")
			for key in all_colors.keys():
				if color_names[key][0] not in colors_we_dont_care:
					print(color_names[key][0] + ": " + str(all_colors[key]))
			
			print("Change what colors? (use semicolons \";\")")
			
			colors_to_change = input("? ")
			colors_to_change = colors_to_change.split(';')
			
			right_color_list = True 
			
			# Verify the colors?
			for col in colors_to_change:
				if col not in only_color_names:
					print("The color \"" + col + "\" is not in the sprite.")
					right_color_list = False 
		i = 0 
		for new_color in self.color_dict.keys():
			new_scheme = self.translate_colors(color_names, colors_to_change, new_color)
			target_file_temp = target_file.replace(".png", new_color + ".png")
			
			self.apply_changes(source_file, target_file_temp, new_scheme)
			i += 1
			print(str(i) + "/" + str(len(self.color_dict)) + " done", end="\r")
	


class SCPokedexModificationMenu:
	
	
	def __init__(self):
		self.useful_lines = []
		self.original_lines = []
		self.alterable_stuff = ["Name=", "InternalName=", "Type1=", "Type2=", "Abilities=", "HiddenAbility=", "Moves=", "EggMoves="]
		self.all_internal_names = []
		self.first_loading = True 
		self.original_name = ""
		self.new_name = ""
		self.recolor_menu = SCRecolorMenu()
		self.re_number = re.compile("\d+")
		self.new_form = 1
	
	
	
	def load_original(self, original_number):
		# To run first 
		self.useful_lines = []
		self.original_lines = []
		self.original_name = ""
		header = "[" + str(original_number) + "]" 
		headerplus1 = "[" + str(original_number+1) + "]" 
		skip_line = True 
		
		with open("../PBS/pokemon.txt", "r", encoding="utf8") as f:
			for line in f:
				line = line.replace("\r", "")
				line = line.replace("\n", "")
				
				if line.startswith(header):
					# self.useful_lines.append(header)
					# self.original_lines.append(header)
					skip_line = False 
				
				elif line.startswith(headerplus1):
					skip_line = True 
					
				if not skip_line:
					self.useful_lines.append(line)
					self.original_lines.append(line)
					
					if self.original_name == "" and line.startswith("InternalName"):
						self.original_name = line.split("=")[1]
				
				
				if self.first_loading and line.startswith("InternalName"):
					self.all_internal_names.append(line.split("=")[1])
		
		
		if self.first_loading:
			with open("alternate_forms_summary.txt", "r") as f:
				for line in f:
					line = line.replace("\r", "")
					line = line.replace("\n", "")
					
					if line.startswith("[NEW] InternalName"):
						self.all_internal_names.append(line.split("=")[1])
				
		# print(self.useful_lines)
		self.first_loading = False 
	
	
	
	def write_alternate_form(self, new_number):
		new_header = "[" + str(new_number) + "]"
		self.useful_lines[0] = new_header
		
		# Write all the data that could change. 
		# For TMs, for now my only option is to write all changes in a 
		# file, and then write the TMs of the original Pokemon. Then I 
		# will have to manually edit the TM list for all new forms, 
		# and merge it to the right tm.txt with an adaptation of the 
		# function written in generate_movesets.py. 
		
		new_name = self.new_internal_name(self.original_name)
		
		with open("alternate_forms_summary.txt", "a") as f:
			# f.write(self.useful_lines[2] + " (from " + self.original_name + ")")
			
			for i in range(len(self.useful_lines)):
				if i ==2:
					f.write("[OLD] " + self.useful_lines[2] + "\n")
					f.write("[NEW] InternalName=" + new_name + "\n")
				else:
					f.write(self.useful_lines[i] + "\n")
				
			f.write(new_name + "=" + ",".join(gm.TM_DATA_TRANSPOSE[self.original_name]))
			f.write("\n--------------------------\n\n\n")
		
		self.all_internal_names.append(new_name)
	
	
	
	def is_alterable(self, line):
		parameter = line.split("=")[0] + "="
		return parameter in self.alterable_stuff
	
	
	
	def print_useful_stuff(self):
		for line in self.useful_lines:
			
			if self.is_alterable(line):
				print(line)
	
	
	
	def change_alterable_stuff(self):
		i = 0
		while i < len(self.useful_lines):
			line = self.useful_lines[i]
			
			if self.is_alterable(line):
				parameter = line.split("=")[0]
				new_val = ""
				
				if line.startswith("Name="):
					i+=1
					continue 
					
				elif line.startswith("InternalName"):
					new_val = self.new_internal_name(line.split("=")[1])
				elif line == "EggMoves=":
					new_val = ""
				else:
					print("[OLD] " + line)
					new_val = input("[NEW] " + parameter + "=")
				
				
				if line.startswith("Moves") and new_val == "list":
					# List all moves for alternation.
					level_moves = line.replace("Moves=", "").split(",")
					new_level_moves = "Moves="
					m = 1
					
					to_end = False 
					
					while m < len(level_moves):
						print("[OLD] " + level_moves[m])
						if not to_end:
							new_move = input("[NEW] " + parameter + "=")
						else: 
							new_move = ""
						
						if new_move == "":
							new_level_moves += level_moves[m-1] + "," + level_moves[m] + ","
						elif new_move == "end":
							to_end = True 
							
						else: 
							new_level_moves += level_moves[m-1] + "," + new_move + ","
						
						m += 2
					
					self.useful_lines[i] = new_level_moves[0:len(new_level_moves)-1]
					
				elif new_val == "same" or new_val == "":
					i+=1
					continue
				elif new_val.startswith("replace"):
					
					old_val = new_val.split(" ")[1]
					new_val = new_val.split(" ")[2]
					self.useful_lines[i] = self.useful_lines[i].replace(old_val, new_val)
					i -= 1
				else:
					self.useful_lines[i] = parameter + "=" + new_val
			i += 1
	
	
	
	def new_internal_name(self, name):
		cpt = 1
		new_name = name 
		
		# print(self.all_internal_names[1045:])
		
		while new_name in self.all_internal_names:
			new_name = name + "SC" + str(cpt)
			cpt += 1 
		# print(new_name)
		return new_name 
	
	
	
	def interactive_menu(self, original_number, new_number):
		# self.load_original(original_number)
		self.print_useful_stuff()
		
		ans = input("Do you want to create a new form for " + self.original_name + "? [y]/n")
		if ans == "n":
			return 
			
		self.change_alterable_stuff()
		self.write_alternate_form(new_number)
	
	
	
	def get_last_new_number(self):
		last_num = 0 
		with open("alternate_forms_summary.txt", "r") as f:
			for line in f:
				line = line.replace("\n", "")
				line = line.replace("\r", "")
				if line.startswith("[") and line.endswith("]"):
					last_num = line.replace("[", "")
					last_num = last_num.replace("]", "")
		
		return max(int(last_num), 1040) # 1040 is the last Pokémon in the Pokédex. 
	
	
	def get_last_form_original(self, original_number):
		source_folder = "..\\..\\Project STRAT\\Graphics\\Battlers\\"
		re_pkmn = re.compile(str(original_number).rjust(3, "0") + "[a-z]*(\_\d+)?.png")
		
		max_form = 0 
		
		for f in os.listdir(source_folder):
			res = re_pkmn.match(f)
			
			if res and "_" in res.group(0):
				temp = self.get_form_of_sprite(res.group(0))
				
				if int(temp) > max_form:
					max_form = int(temp)
		
		# input("Max form=" + str(max_form))
		
		return max_form
	
	
	# def get_last_form_(self, original_number):
		# source_folder = "..\\..\\Project STRAT\\Graphics\\Battlers\\"
		# re_pkmn = re.compile(str(original_number).rjust(3, "0") + "[a-z]*(\_\d+)?.png")
		
		# max_form = 0 
		
		# for f in os.listdir(source_folder):
			# res = re_pkmn.match(f)
			
			# if res and "_" in res.group(0):
				# temp = self.get_form_of_sprite(res.group(0))
				
				# if int(temp) > max_form:
					# max_form = int(temp)
		
		# # input("Max form=" + str(max_form))
		
		# return max_form
		
	
	def get_form_of_sprite(self, sprite_path):
		form = 0 
		temp = sprite_path.split("\\")[-1]
		
		if "_" in temp:
			temp = temp.split("_")[1]
			temp = temp.replace(".png", "")
			form = int(temp)
		
		return form 
		
	def list_all_sprites(self, original_number):
		
		graphics_subfolders = ["Battlers", "Characters", "Icons"]
		graphics_prefixes = ["", "", "icon"]
		# sprite_names_regex = "\d+(\_\d{1,2})?\.png"
		# source_folder = "..\\Graphics\\"
		source_folder = "..\\..\\Project STRAT\\Graphics\\"
		target_folder = "Color variants\\"
		
		new_form = self.get_last_form_original(original_number) + 1
		
		original_sprite_name = str(original_number).rjust(3, "0")
		new_sprite_name = str(original_number).rjust(3, "0")
		
		all_sprites = []
		
		for i in range(len(graphics_subfolders)):
			re_pkmn = re.compile(graphics_prefixes[i] + original_sprite_name + "[a-z]*(\_\d+)?.png")
			
			for f in os.listdir(source_folder + graphics_subfolders[i]):
				
				res = re_pkmn.match(f)
				
				if res:
					source_form = self.get_form_of_sprite(res.group(0))
					target_form = source_form + new_form
					
					temp_target = ""
					
					if source_form == 0:
						# temp_target = original_sprite_name + "_" + str(target_form) + ".png"
						temp_target = res.group(0).replace(".png", "_" + str(target_form) + ".png")
						temp_target = temp_target.replace("_0.png", "_" + str(target_form) + ".png")
					else:
						temp_target = res.group(0).replace("_" + str(source_form) + ".png", "_" + str(target_form) + ".png")
					
					s = source_folder + graphics_subfolders[i] + "\\" + res.group(0)
					t = target_folder + graphics_subfolders[i] + "\\"
					t += temp_target
					all_sprites.append([s, t])
					shutil.copyfile(s, t)
		
		return all_sprites
	
	def list_all_sprites___OLD(self, original_number, new_number):
	# def list_all_sprites(self, original_number, new_number):
		self.get_last_form(original_number)
		
		
		graphics_subfolders = ["Battlers", "Characters", "Icons"]
		graphics_prefixes = ["", "", "icon"]
		# sprite_names_regex = "\d+(\_\d{1,2})?\.png"
		# source_folder = "..\\Graphics\\"
		source_folder = "..\\..\\Project STRAT\\Graphics\\"
		target_folder = "Color variants\\"
		
		original_sprite_name = str(original_number).rjust(3, "0")
		new_sprite_name = str(new_number).rjust(3, "0")
		
		all_sprites = []
		
		for i in range(len(graphics_subfolders)):
			re_pkmn = re.compile(graphics_prefixes[i] + original_sprite_name + "([a-z]*(\_\d+)?).png")
			
			for f in os.listdir(source_folder + graphics_subfolders[i]):
				
				res = re_pkmn.match(f)
				
				if res:
					s = source_folder + graphics_subfolders[i] + "\\" + res.group(0)
					t = target_folder + graphics_subfolders[i] + "\\"
					t += res.group(0).replace(original_sprite_name, new_sprite_name)
					all_sprites.append([s, t])
					shutil.copyfile(s, t)
		
		return all_sprites
	
	
	
	def copy_soundfiles(self, original_number, new_number):
		original_sprite_name = str(original_number).rjust(3, "0")
		new_sprite_name = str(new_number).rjust(3, "0")
		# source_folder = "..\\Audio\\SE\\"
		source_folder = "..\\..\\Project STRAT\\Audio\\SE\\"
		target_folder = "Color variants\\Audio\\SE\\"
		
		
		re_pkmn = re.compile(original_sprite_name + "[Cc]ry(\_\d+)?.(wav|ogg)")
		
		for f in os.listdir(source_folder):
			
			res = re_pkmn.match(f)
			
			if res:
				s = source_folder + res.group(0)
				t = target_folder + res.group(0).replace(original_sprite_name, new_sprite_name)
				# all_sprites.append([s, t])
				shutil.copyfile(s, t)
	
	
	
	def main_interactive_menu(self):
		# original_number = int(input("Start with what number? "))
		original_number = 12
		new_number = self.get_last_new_number() + 1 
		
		while True:

			all_sprites = self.list_all_sprites(original_number, new_number)
			
			old_colors = None
			new_color = ""
			
			for sprites in all_sprites:
				old_colors, new_color = self.recolor_menu.recolor_sprite_interactive(sprites[0], sprites[1], old_colors, new_color)
			
			self.interactive_menu(original_number, new_number)
			
			ans = ""
			while ans != "y" and ans != "n":
				ans = input("Do you want to alter the same Pokémon? y/n")
			
			if ans == "n":
				original_number += 1
			
			new_number += 1 
	
	
	
	def main_interactive_menu_several(self):
		original_number = int(input("Start with what number? "))
		# original_number = 12
		new_number = self.get_last_new_number() + 1 
		ans = ""
		
		while True:
			self.load_original(original_number)
			# print("lol 1")
			
			while ans != "y" and ans != "n":
				ans = input("Do you want to alter " + self.original_name + "? y/n")
				ans_match = self.re_number.match(ans)
				if ans_match:
					# So that we exit this loop and start the big loop again. 
					original_number = int(ans) - 1
					ans = "n" 
				
			
			if ans == "n":
				original_number += 1
				ans = ""
				continue 
			
			# print("lol 222222")
			
			all_sprites = self.list_all_sprites(original_number)#, new_number)
			# self.copy_soundfiles(original_number, new_number)
			
			self.recolor_menu.recolor_sprite_interactive_several(all_sprites, False)
			self.recolor_menu.recolor_sprite_interactive_several(all_sprites, True)
			
			# self.interactive_menu(original_number, new_number)
			self.write_alternate_form(new_number)
			print("Data from the original Pokémon written to alternate_forms_summary.txt.\n\n\n\n")
			
			ans = ""
			while ans != "y" and ans != "n":
				ans = input("Do you want to alter the same Pokémon? y/n")
				ans_match = self.re_number.match(ans)
				if ans_match:
					original_number = int(ans)
					ans = "" 
					break 
			
			if ans == "n":
				original_number += 1
				ans = ""
			
			new_number += 1 
	
	


	

if __name__ == "__main__":
	
	
	
	menu = SCPokedexModificationMenu()
	# menu.interactive_menu(141, 1041)
	# menu.main_interactive_menu()
	# res = menu.list_all_sprites(3, 1042)
	
	# menu.load_original(20)
	# print(menu.new_internal_name("RATICATE"))
	# print(len(menu.all_internal_names))
	
	menu.main_interactive_menu_several()
	# for r in res:
		# print(r)
	
	
	
	
	
	