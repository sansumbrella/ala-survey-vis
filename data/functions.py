#!/usr/bin/env python
# encoding: utf-8
from __future__ import division
import sys
import os

def extractColumn( table, column ):
	#returns the column without the heading
	return [row[column] for row in table][1:]

def getNumericColumn( table, column ):
	col = [row[column] for row in table][1:]
	return [ numerify(row) for row in col ]

def reverseLines( filename ):
	import string
	input = open( filename )
	output = open( filename[:-4] + "-r"+ filename[-4:], 'w' )
	
	col = input.readlines()
	print col
	r = [ col[i].strip() for i in range(len(col)-1,0,-1) ]
	print r
	output.write( string.join( r, '\n' ) )
	output.close()
	input.close()

def extractAndExport( table, column, name ):
	exportRatios( name, extractColumn( table, column ) )
	
def buildPaths( table, filename ):
	import string
	output = open( filename + '.tsv', 'w')
	#extracts	Age, Gender, Race, Region, Education, Hours, Web Amount, Excitement, Satisfaction
	paths = [ [ numerify(row[0]), row[1], row[2], row[3], row[7], row[23], row[24], row[46], row[47]  ] for row in table ]
	for p in paths:
		print('.')
		output.write( string.join( p, '\t') )
		output.write( '\n' )
	output.close()

def numerify( value ):
	try:
		value = int(value)
	except:
		value = 0
	return str(value)

def exportRatios( filename, data ):
	data.sort()
	total = len(data)
	match = data[0]
	ret = { match:1 }
	for row in data[1:]:
		if( row == match ):
			ret[match] += 1
		else:
			match = row
			ret[match] = 1
	import string
	output = open( filename + ".tsv", 'w')
	for key in ret:
		output.write( str(key) + '\t' + str(ret[key]/total) + '\n' )
	output.close()
	
	return ret

def exportTSV( filename, data ):
	import string
	output = open( filename+".tsv", 'w' )
	output.write( string.join( data, '\t' ) )
	output.close()

def isNum(n):
	from types import IntType, LongType, FloatType
	return n in (IntType, LongType, FloatType)