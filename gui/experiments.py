#!/usr/bin/python
# -*- coding: UTF-8 -*-
import os
import sys
import random
from PyQt4 import QtGui, QtCore

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    def _fromUtf8(s):
        return s

try:
    _encoding = QtGui.QApplication.UnicodeUTF8
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig, _encoding)
except AttributeError:
    def _translate(context, text, disambig):
        return QtGui.QApplication.translate(context, text, disambig)

class ImageData(object):
	"""
		Set ImageData
		image_folder: ~
		nImg: num of images
		imlist[]: image names(random permutation)
		AQI[]: aqis for each iagme
		CompPairInd[] : random pair index
		if given the pairs.txt file  
		load the pairs form pairs.txt
	"""
	def __init__(self, folder):
		super(ImageData, self).__init__()
		self.image_folder = folder
		# the image list
		self.imlist = []
		# aqis
		self.AQI = []
		# aqi levels
		self.Level = []
		# the comparison pair of iagmes
		self.CompPairInd = []
		self.PairLenRatio = 0.015
		# initialize the imlist and AQI
		#self.initParameters()

	def initParameters(self):
		""" Initialize the parameters"""
		# get image names
		self.imlist = [im \
			for im in os.listdir(self.image_folder) \
			if im.endswith('.jpg')]
		# Order disrupted
		random.shuffle(self.imlist)
		self.nImg = len(self.imlist)
		self.PairLen = int(self.PairLenRatio*self.nImg)
		self.AQI = []
		for i in range(self.nImg):
			# get aqis
			ind_first = self.imlist[i].find('-')
			ind_second = self.imlist[i].find('-',ind_first+1)
			aqi = int(self.imlist[i][ind_first+1:ind_second])
			self.AQI.append(aqi)
			self.Level.append(self.Aqi2Level(aqi))
		if os.path.exists('pairs.txt'):
			self.loadpair()
		else:
			self.CompPairInd = [[i,j]\
					for i in range(self.nImg)\
					for j in range(self.nImg)\
					if i != j]
			random.shuffle(self.CompPairInd)
			f = open('pairs.txt','w')
			f.write('Pairs:%s\n' %(self.PairLen))
			for j in range(self.PairLen):
				f.write(str(self.CompPairInd[j][0]) + ' ' \
						+ str(self.CompPairInd[j][1]) + '\n')
	def loadpair(self):
		f = open('pairs.txt','r')
		data = f.readlines()
		f.close()
		PairNum = int(data[0][:-1].split(':')[1])	
		for j in range(PairNum):
			ind = data[j+1][:-1].split(' ')
			self.CompPairInd.append([int(ind[0]),int(ind[1])])
	def Aqi2Level(self,aqi):
		if aqi > 300:
			level = 6
		elif aqi > 200:
			level = 5
		else:
			level = (aqi-1)//50 + 1
		return level


class Btn(QtGui.QPushButton):
	"""
		Btn class inherit frome QPushButton
		emit signal:BtnClicked(int)
	"""
	BtnClicked = QtCore.pyqtSignal(int)
	def __init__(self, id, *arges, **kwarges):
		QtGui.QPushButton.__init__(self, *arges, **kwarges)
		self.__id = id
		self.connect(self, QtCore.SIGNAL("clicked()"), self.emitBtnClicked)
	def emitBtnClicked(self):
		self.BtnClicked.emit(self.__id)

class ExofClass(QtGui.QWidget):
	def __init__(self, folder):
		super(ExofClass, self).__init__()
		# Correcct Classification number
		self.CorEsted = 0
		# All Classfication number
		self.SumEsted = 0

		self.userParam = {}
		self.userParam['Folder'] = folder
		# file path for save remaining
		self.userParam['Remain'] = \
				os.path.join(folder,'ex_1_left.txt')
		# file path for save result
		self.userParam['FilePath'] = \
				os.path.join(folder,'ex_1.txt')
		"""
			load data
			if has remaining road remaining
			otherwise generate new data
		"""
		self.Images = ImageData('images')
		if os.path.exists(self.userParam['Remain']):
			self.LoadRemainData()
		else:
			self.Images.initParameters()
		# the current image and label
		self.curImage = ''
		self.pixelmapLabel = ''
		# initialize the GUI
		self.initUI()
		# show next iamge
		self.nextImage()

	def initUI(self):
		self.setWindowTitle(_fromUtf8("Image Classification"))
		self.setWindowIcon(QtGui.QIcon('icons/idle.ico'))
		# level btns
		self.btnLevel1 = Btn(1, 'Level 1',self)
		self.btnLevel2 = Btn(2, 'Level 2',self)
		self.btnLevel3 = Btn(3, 'Level 3',self)
		self.btnLevel4 = Btn(4, 'Level 4',self)
		self.btnLevel5 = Btn(5, 'Level 5',self)
		self.btnLevel6 = Btn(6, 'Level 6',self)
		# level btn connections
		self.btnLevel1.BtnClicked.connect(self.saveDecision)
		self.btnLevel2.BtnClicked.connect(self.saveDecision)
		self.btnLevel3.BtnClicked.connect(self.saveDecision)
		self.btnLevel4.BtnClicked.connect(self.saveDecision)
		self.btnLevel5.BtnClicked.connect(self.saveDecision)
		self.btnLevel6.BtnClicked.connect(self.saveDecision)
		# Level Btns Group
		hbox = QtGui.QHBoxLayout()
		hbox.addWidget(self.btnLevel1)
		hbox.addWidget(self.btnLevel2)
		hbox.addWidget(self.btnLevel3)
		hbox.addWidget(self.btnLevel4)
		hbox.addWidget(self.btnLevel5)
		hbox.addWidget(self.btnLevel6)
		vbox = QtGui.QVBoxLayout()
		#vbox.addStretch(1)
		vbox.addLayout(hbox)
		#vbox.addStretch(1)
		# Show Accuracy Btn
		self.Check = QtGui.QPushButton(_fromUtf8("ShowAccuracy"), self)
		self.Check.clicked.connect(self.ShowAccuracy)
		self.Check.hide()
		# Load Remain Data Btn
		#Load = QtGui.QPushButton('Load Remian Data', self)
		#Load.clicked.connect(self.LoadRemainData)
		# label
		self.RemainLabel = QtGui.QLabel('')
		self.RemainLabel.setText('Number Remaing:%d'\
						%len(self.Images.imlist))
		# Set Layout
		grid = QtGui.QGridLayout()
		self.setLayout(grid)
		# Image Layout
		self.pixelmapLabel = self.createPixmapLabel()
		grid.addWidget(self.pixelmapLabel, 0, 0)
		#  Btns and Label
		grid.addWidget(self.RemainLabel, 1, 0)
		grid.addLayout(vbox, 2, 0)
		hbox = QtGui.QHBoxLayout()
		hbox.addStretch(1)
		hbox.addWidget(self.Check)
		hbox.addStretch(1)
		grid.addLayout(hbox, 3, 0)
		#grid.addWidget(Load, 3, 0, 1, -1)

	def saveDecision(self, level):
		# decision made pop out image
		if len(self.Images.imlist) == 0:
			QtGui.QMessageBox.information(self, "Finished", "No more image" )
			self.ShowAccuracy()
			self.Check.show()
		else:
			self.Images.imlist.pop()
			self.Images.Level.pop()
			# left number of images
			self.RemainLabel.setText('Number Remaing:%d'\
							%len(self.Images.imlist))
			# if made a right decision
			self.CorEsted = (self.CorEsted + 1) if level == self.curLevel else self.CorEsted
			self.SumEsted += 1
			# save the decision
			with open(self.userParam['FilePath'],'a') as f:
				f.write(self.curImage + ' ' + str(level) + '\n')
			# show next image
			self.nextImage()


	def LoadRemainData(self):
		"""
			Load the Remaing Data havent been judged
			Data Format:
			------------------
			Left Images of Ex_1
			Image Number:
			CorEsted,SumEsted
			image1
			image2
			...
			----------------
		"""

		f = open(self.userParam['Remain'],'r')
		data = f.readlines()
		f.close()
		# before load, clear the previous data 
		self.Images.nImg = int(data[1][:-1].split(':')[1])
		self.CorEsted = int(data[2].split(',')[0])
		self.SumEsted = int(data[2].split(',')[1])
		self.Images.imlist = []
		self.Images.AQI = []
		self.Images.Level = []
		# read file
		for i in range(self.Images.nImg):
			ImageName = data[i+3][:-1]
			self.Images.imlist.append(ImageName)
			ind_first = ImageName.find('-')
			ind_second = ImageName.find('-',ind_first+1)
			aqi = int(ImageName[ind_first+1:ind_second])
			self.Images.AQI.append(aqi)
			self.Images.Level.append(6 if aqi > 300 else aqi//50+1)		
		#QtGui.QMessageBox.information(self, "Load Remaing Data", "Load Successfully")


	def nextImage(self):
		if len(self.Images.imlist) != 0:
			# get the last image and level
			self.curImage = self.Images.imlist[-1]
			self.curLevel = self.Images.Level[-1]
			# do show
			pixmap = QtGui.QPixmap(\
					os.path.join(self.Images.image_folder, self.curImage))
			self.pixelmapLabel.setPixmap(pixmap)
		else:
			pixmap = QtGui.QPixmap('')
			self.pixelmapLabel.setPixmap(pixmap)

	def ShowAccuracy(self):
		"""Show the current accuracy under what you have done"""
		# the situation that no judge has been done
		acc = 0 if self.SumEsted == 0 else (self.CorEsted + 0.0)/self.SumEsted
		QtGui.QMessageBox.information(self, "Accuracy", "The Accuracy is %.2f%%(%d/%d)"\
						%(acc*100,self.CorEsted,self.SumEsted))

	def closeEvent(self, event):
		"""Save the Remaining"""
		with open(self.userParam['Remain'],'w') as f:
			f.write('Left Images of Ex_1\nImage Number:%d\n%d,%d\n' \
				%(len(self.Images.imlist),self.CorEsted,self.SumEsted))
			for im in self.Images.imlist:
				f.write(im + '\n')
		self.close()


	def createPixmapLabel(self):
		"""Creat an empty pixmap label"""
		label = QtGui.QLabel()
  		label.setEnabled(True)
  		#label.setScaledContents(True)
  		label.setAlignment(QtCore.Qt.AlignJustify)
  		label.setSizePolicy(QtGui.QSizePolicy.Expanding,
  		        QtGui.QSizePolicy.Expanding)
  		label.setBackgroundRole(QtGui.QPalette.Base)
  		label.setAutoFillBackground(True)
  		label.setMinimumSize(624,468)
  		return label

class ExofComp(QtGui.QWidget):  # inherit QtGui.QWidget
	def __init__(self, folder):
		super(ExofComp, self).__init__()
		self.CorEsted = 0
		self.SumEsted = 0		
		self.userParam = {}
		self.userParam['Folder'] = folder
		# file path for save remaining
		self.userParam['Remain'] = \
				os.path.join(folder,'ex_2_left.txt')
		# file path for save result
		self.userParam['FilePath'] = \
				os.path.join(folder,'ex_2.txt')
		"""
			load data
			if has remaining road remaining
			otherwise generate new data
		"""
		self.Images = ImageData('images')
		if os.path.exists(self.userParam['Remain']):
			self.LoadRemainData()
		else:
			self.Images.initParameters()

		self.CompImagesNum = 2
		self.pixelmapLabels = []
		# current pair of image names
		self.curPair = []
		# current pair of image index
		self.curInds = []

		self.initUI()
		self.nextPair()

	def initUI(self):
		self.setWindowTitle('Image Comparison')
		self.setWindowIcon(QtGui.QIcon('icons/idle.ico'))
		# btns
		self.btnA = Btn(0, 'Left is better',self)
		self.btnB = Btn(1, 'Right is better',self)
		self.btnA.BtnClicked.connect(self.saveDecision)
		self.btnB.BtnClicked.connect(self.saveDecision)
		# check and load
		self.Check = QtGui.QPushButton(_fromUtf8("ShowAccuracy"), self)
		self.Check.clicked.connect(self.ShowAccuracy)
		self.Check.hide()
		#Load = QtGui.QPushButton('Load Remian Data', self)
		#Load.clicked.connect(self.LoadRemainData)
		self.RemainLabel = QtGui.QLabel('')
		self.RemainLabel.setText('Number Remaing:%d'\
						%len(self.Images.CompPairInd))		
		# set layout
		grid = QtGui.QGridLayout()
		self.setLayout(grid)
		for i in range(self.CompImagesNum):
			self.pixelmapLabels.append(self.createPixmapLabel())
			grid.addWidget(self.pixelmapLabels[i], 0, i)
		#Layout of button A
		hboxA = QtGui.QHBoxLayout()
		hboxA.addStretch(1)
		hboxA.addWidget(self.btnA)
		hboxA.addStretch(1)
		#Layout of button B
		hboxB = QtGui.QHBoxLayout()
		hboxB.addStretch(1)
		hboxB.addWidget(self.btnB)
		hboxB.addStretch(1)
		grid.addLayout(hboxA, 2, 0)
		grid.addLayout(hboxB, 2, 1)
		grid.addWidget(self.RemainLabel, 1, 0, 1, -1)
		#Layout of button Check
		hboxCheck = QtGui.QHBoxLayout()
		hboxCheck.addStretch(1)
		hboxCheck.addWidget(self.Check)
		hboxCheck.addStretch(1)
		grid.addLayout(hboxCheck, 3, 0, 1, -1)
		#grid.addWidget(Load, 3, 0, 1, -1)
		
	def saveDecision(self, t):
		if len(self.Images.CompPairInd) == 0:
			QtGui.QMessageBox.information(self, "Finished", "No more image" )
			#self.ShowAccuracy()
			self.Check.show()
		else:
			self.Images.CompPairInd.pop()
			self.RemainLabel.setText('Number Remaing:%d'\
							%len(self.Images.CompPairInd))
			if self.Images.AQI[self.curInds[t]] < self.Images.AQI[self.curInds[t-1]]:
				self.CorEsted += 1
			self.SumEsted += 1
			with open(self.userParam['FilePath'],'a') as f:
				f.write(self.curPair[0] + ' ' + self.curPair[1] + ' ' + str(t) + '\n')
			self.nextPair()

	def ShowAccuracy(self):
		acc = 0 if self.SumEsted == 0 \
				else (self.CorEsted + 0.0)/self.SumEsted
		QtGui.QMessageBox.information(\
					self, "Accuracy", \
					"The Accuracy is %.2f%%(%d/%d)"\
					%(acc*100,self.CorEsted,self.SumEsted))

	def nextPair(self):
		if len(self.Images.CompPairInd) != 0:
			self.curInds = self.Images.CompPairInd[-1]
			nextPairImages = []
			for i in range(self.CompImagesNum):
				nextPairImages.append(self.Images.imlist[self.curInds[i]])
				pixmap = QtGui.QPixmap(\
							os.path.join(self.Images.image_folder,\
							nextPairImages[i]))
				self.pixelmapLabels[i].setPixmap(pixmap)
			self.curPair = nextPairImages
		else:
			pixmap = QtGui.QPixmap('')
			self.pixelmapLabels[0].setPixmap(pixmap)
			self.pixelmapLabels[1].setPixmap(pixmap)		

	def closeEvent(self, event):
		with open(self.userParam['Remain'],'w') as f:
			f.write('Left Image Pairs of Ex_2:\nImage Number:%d\nPairs:%s\n%d,%d\n'\
					%(self.Images.nImg,\
					len(self.Images.CompPairInd),\
					self.CorEsted,self.SumEsted))
			for im in self.Images.imlist:
				f.write(im + '\n')
			for Inds in self.Images.CompPairInd:
				f.write(str(Inds[0]) + ' ' + str(Inds[1]) + '\n')


	def LoadRemainData(self):
		"""
			Load the Remaing Data havent been judged
			Data Format:
			------------------
			Left Images Pairs of Ex_2
			Image Number:
			Pairs:
			CorEsted,SumEsted
			image0
			image2
			...
			pair0
			pair1
			----------------
		"""
		f = open(self.userParam['Remain'],'r')
		data = f.readlines()
		f.close()
		self.Images.nImg = int(data[1][:-1].split(':')[1])
		PairNum = int(data[2][:-1].split(':')[1])
		self.CorEsted = int(data[3].split(',')[0])
		self.SumEsted = int(data[3].split(',')[1])
		self.Images.imlist = []
		self.Images.AQI = []
		self.Images.Level = []
		self.Images.CompPairInd =[]
		for i in range(self.Images.nImg):
			ImageName = data[i+4][:-1]
			self.Images.imlist.append(ImageName)
			ind_first = ImageName.find('-')
			ind_second = ImageName.find('-',ind_first+1)
			aqi = int(ImageName[ind_first+1:ind_second])
			self.Images.AQI.append(aqi)
			self.Images.Level.append(6 if aqi > 300 else aqi//50+1)		
		for j in range(PairNum):
			ind = data[j+4+self.Images.nImg][:-1].split(' ')
			self.Images.CompPairInd.append([int(ind[0]),int(ind[1])])

	def createPixmapLabel(self):		
		label = QtGui.QLabel()
  		label.setEnabled(True)
  		#label.setScaledContents(True)
  		label.setAlignment(QtCore.Qt.AlignJustify)
  		label.setSizePolicy(QtGui.QSizePolicy.Expanding,
  		        QtGui.QSizePolicy.Expanding)
  		label.setBackgroundRole(QtGui.QPalette.Base)
  		label.setAutoFillBackground(True)
  		label.setMinimumSize(624,468)
  		return label


class Extra(QtGui.QDialog):
	def __init__(self):
		super(Extra, self).__init__()
		self.imlist = [im \
			for im in os.listdir('example') \
			if im.endswith('.jpg')]
		self.curImage = ''
		self.pixelmapLabel = ''
		self.initUI()
		#self.nextImage()
	def initUI(self):
		self.setWindowTitle(_fromUtf8("Example"))
		self.setWindowIcon(QtGui.QIcon('icons/idle.ico'))
		self.Label = QtGui.QLabel()
		# Image Layout
		self.pixelmapLabel = self.createLabel()
		self.pixelmapLabel.setText("These will be some Examples and Explanation Beforehead:\n" +\
							"Level 1 = AQI: 0-50\n" + \
							"Level 2 = AQI: 51-100\n" + \
							"Level 3 = AQI: 101-150\n" + \
							"Level 4 = AQI: 151-200\n" + \
							"Level 5 = AQI: 201-300\n" + \
							"Level 6 = AQI > 300\n")

		btn_next = QtGui.QPushButton('Show Next Example', self)
		btn_next.clicked.connect(self.nextImage)
		btn_skip = QtGui.QPushButton('Skip', self)
		btn_skip.clicked.connect(self.close)
		# Set Layout
		grid = QtGui.QGridLayout()
		self.setLayout(grid)
		grid.addWidget(self.pixelmapLabel, 0, 0)
		#  Btns and Label
		grid.addWidget(self.Label, 1, 0)
		hbox = QtGui.QHBoxLayout()
		hbox.addWidget(btn_next)
		hbox.addWidget(btn_skip)
		grid.addLayout(hbox, 2, 0)
	def createLabel(self):
		"""Creat an empty pixmap label"""
		label = QtGui.QLabel()
  		label.setEnabled(True)
  		#label.setScaledContents(True)
  		label.setAlignment(QtCore.Qt.AlignJustify)
		label.setFont(QtGui.QFont("Roman times",15,QtGui.QFont.Bold))
  		label.setSizePolicy(QtGui.QSizePolicy.Expanding,
  		        QtGui.QSizePolicy.Expanding)
  		label.setBackgroundRole(QtGui.QPalette.Base)
  		label.setAutoFillBackground(True)
  		label.setMinimumSize(624,468)
  		return label
	def nextImage(self):
		if len(self.imlist) != 0:
			# get the last image and level
			self.curImage = self.imlist.pop()
			ind_first = self.curImage.find('-')
			ind_second = self.curImage.find('-',ind_first+1)
			aqi = int(self.curImage[ind_first+1:ind_second])
			# do show
			pixmap = QtGui.QPixmap(\
					os.path.join('example', self.curImage))
			self.pixelmapLabel.setPixmap(pixmap)
			self.Label.setText("AQI:%d,Level:%d"%(aqi,self.Aqi2Level(aqi)))
		else:
			self.Label.setText("No More Example!")
	def Aqi2Level(self,aqi):
		if aqi > 300:
			level = 6
		elif aqi > 200:
			level = 5
		else:
			level = (aqi-1)//50 + 1
		return level