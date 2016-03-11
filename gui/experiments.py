import os
import sys
import random
import shutil
import numpy as np
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
		# initialize the imlist and AQI
		self.initParameters()

	def initParameters(self):
		""" Initialize the parameters"""
		# get image names
		self.imlist = [im \
			for im in os.listdir(self.image_folder) \
			if im.endswith('.jpg')]
		# Order disrupted
		random.shuffle(self.imlist)
		self.nImg = len(self.imlist)
		self.AQI = []
		for i in range(self.nImg):
			# get aqis
			ind_first = self.imlist[i].find('-')
			ind_second = self.imlist[i].find('-',ind_first+1)
			aqi = int(self.imlist[i][ind_first+1:ind_second])
			self.AQI.append(aqi)
			self.Level.append(6 if aqi > 300 else aqi//50+1)
		self.CompPairInd = [[i,j]\
				for i in range(self.nImg)\
				for j in range(self.nImg)\
				if i != j]
		random.shuffle(self.CompPairInd)
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

class ExofClass(QtGui.QWidget):  # inherit QtGui.QWidget
	def __init__(self, folder):
		super(ExofClass, self).__init__()
		self.Images = ImageData('images')
		# the current image  and label
		self.curImage = ''
		self.pixelmapLabel = ''
		# Correcct Classification
		self.CorEsted = 0
		# All Classfication
		self.SumEsted = 0
		self.initUI()
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
		# Show Accuracy Btn
		Check = QtGui.QPushButton(_fromUtf8("ShowAccuracy"), self)
		Check.clicked.connect(self.ShowAccuracy)
		# Load Remain Data Btn
		Load = QtGui.QPushButton('Load Remian Data', self)
		Load.clicked.connect(self.LoadRemainData)
		# Set Layout
		grid = QtGui.QGridLayout()
		self.setLayout(grid)
		# Level Btns Group
		hbox = QtGui.QHBoxLayout()
		hbox.addWidget(self.btnLevel1)
		hbox.addWidget(self.btnLevel2)
		hbox.addWidget(self.btnLevel3)
		hbox.addWidget(self.btnLevel4)
		hbox.addWidget(self.btnLevel5)
		hbox.addWidget(self.btnLevel6)
		vbox = QtGui.QVBoxLayout()
		vbox.addStretch(1)
		vbox.addLayout(hbox)
		vbox.addStretch(1)
		grid.addLayout(vbox, 1, 0)
		# Image Layout
		self.pixelmapLabel = self.createPixmapLabel()
		grid.addWidget(self.pixelmapLabel, 0, 0)
		# Other Btns
		grid.addWidget(Check, 2, 0)
		grid.addWidget(Load, 3, 0, 1, -1)

	def saveDecision(self, level):
		self.CorEsted = (self.CorEsted + 1) if level == self.curLevel else self.CorEsted
		self.SumEsted += 1
		# write the decision in file result\ex_1.txt
		# with format : image_name + decision
		if os.path.isdir('result') == False:
			os.mkdir('result')
		with open('result\ex_1.txt','a') as f:
			f.write(self.curImage + ' ' + str(level) + '\n')
		self.nextImage()

	def LoadRemainData(self):
		"""Load the Remaing Data havent been judged"""
		f = open('result\ex_1_left.txt','r')
		data = f.readlines()
		f.close()
		# before load, clear the previous data 
		self.Images.nImg = int(data[1][:-1].split(':')[1])
		self.Images.imlist = []
		self.Images.AQI = []
		self.Images.Level = []
		# read
		for i in range(self.Images.nImg):
			ImageName = data[i+2][:-1]
			self.Images.imlist.append(ImageName)
			ind_first = ImageName.find('-')
			ind_second = ImageName.find('-',ind_first+1)
			aqi = int(ImageName[ind_first+1:ind_second])
			self.Images.AQI.append(aqi)
			self.Images.Level.append(6 if aqi > 300 else aqi//50+1)		
		QtGui.QMessageBox.information(self, "Load Remaing Data", "Load Successfully")
		self.nextImage()
	def nextImage(self):
		if len(self.Images.imlist) == 0:
			QtGui.QMessageBox.information(self, "Finished", "No more image" )
		else:
			# get the image and level
			self.curImage = self.Images.imlist.pop()
			self.curLevel = self.Images.Level.pop()
			# do show
			pixmap = QtGui.QPixmap(os.path.join(self.Images.image_folder, self.curImage))
			self.pixelmapLabel.setPixmap(pixmap)

	def ShowAccuracy(self):
		"""Show the current accuracy under what you have done"""
		# the situation that no judge has been done
		acc = 0 if self.SumEsted == 0 else (self.CorEsted + 0.0)/self.SumEsted
		QtGui.QMessageBox.information(self, "Accuracy", "The Accuracy is %.2f%%(%d/%d)"\
						%(acc*100,self.CorEsted,self.SumEsted))

	def closeEvent(self, event):
		if len(self.Images.imlist) != 0:
			reply = QtGui.QMessageBox.question(self, 'Message',
				"You Are you sure to quit? Remaing %d image(s)." \
				%len(self.Images.imlist), \
				QtGui.QMessageBox.Yes, QtGui.QMessageBox.No)
			if reply == QtGui.QMessageBox.Yes:
				with open('result\ex_1_left.txt','w') as f:
					f.write('Left Images of Ex_1\nImage Number:%d\n' \
						%len(self.Images.imlist))
					for im in self.Images.imlist:
						f.write(im + '\n')
				event.accept()
			else:
				event.ignore()

	def createPixmapLabel(self):
		"""Creat an empty pixmap label"""
		label = QtGui.QLabel()
  		label.setEnabled(True)
  		label.setScaledContents(True)
  		label.setAlignment(QtCore.Qt.AlignCenter)
  		label.setFrameShape(QtGui.QFrame.Box)
  		label.setSizePolicy(QtGui.QSizePolicy.Expanding,
  		        QtGui.QSizePolicy.Expanding)
  		label.setBackgroundRole(QtGui.QPalette.Base)
  		label.setAutoFillBackground(True)
  		label.setMinimumSize(420,420)
  		return label

class ExofComp(QtGui.QWidget):  # inherit QtGui.QWidget
	def __init__(self, folder):
		super(ExofComp, self).__init__()
		self.Images = ImageData('images')
		self.CompImagesNum = 2
		self.pixelmapLabels = []
		# current pair of image names
		self.curPair = []
		# current pair of image index
		self.curInds = []
		self.CorEsted = 0
		self.SumEsted = 0
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
		Check = QtGui.QPushButton(_fromUtf8("ShowAccuracy"), self)
		Check.clicked.connect(self.ShowAccuracy)
		Load = QtGui.QPushButton('Load Remian Data', self)
		Load.clicked.connect(self.LoadRemainData)
		# set layout
		grid = QtGui.QGridLayout()
		self.setLayout(grid)
		for i in range(self.CompImagesNum):
			self.pixelmapLabels.append(self.createPixmapLabel())
			grid.addWidget(self.pixelmapLabels[i], 0, i)
		grid.addWidget(self.btnA, 1, 0)
		grid.addWidget(self.btnB, 1, 1)
		grid.addWidget(Check, 2, 0, 1, -1)
		grid.addWidget(Load, 3, 0, 1, -1)
		
	def saveDecision(self, t):
		if self.Images.AQI[self.curInds[t]] < self.Images.AQI[self.curInds[t-1]]:
			self.CorEsted += 1
		self.SumEsted += 1
		if os.path.isdir('result') == False:
			os.mkdir('result')
		with open('result\ex_2.txt','a') as f:
			f.write(self.curPair[0] + ' ' + self.curPair[1] + ' ' + str(t) + '\n')
		self.nextPair()

	def ShowAccuracy(self):
		acc = 0 if self.SumEsted == 0 else (self.CorEsted + 0.0)/self.SumEsted
		QtGui.QMessageBox.information(self, "Accuracy", "The Accuracy is %.2f%%(%d/%d)"\
						%(acc*100,self.CorEsted,self.SumEsted))

	def nextPair(self):
		if len(self.Images.CompPairInd) == 0:
			QtGui.QMessageBox.information(self, "Finish", "The test is finished")
		else:
			# get the indexs and images
			self.curInds = self.Images.CompPairInd.pop()
			nextPairImages = []
			for i in range(self.CompImagesNum):
				nextPairImages.append(self.Images.imlist[self.curInds[i]])
				pixmap = QtGui.QPixmap(os.path.join(self.Images.image_folder,\
							nextPairImages[i]))
				self.pixelmapLabels[i].setPixmap(pixmap)
			self.curPair = nextPairImages

	def closeEvent(self, event):
		if len(self.Images.CompPairInd) != 0:
			reply = QtGui.QMessageBox.question(self, 'Message',
				"Are you sure to quit?", QtGui.QMessageBox.Yes, QtGui.QMessageBox.No)
			if reply == QtGui.QMessageBox.Yes:
				with open('result\ex_2_left.txt','w') as f:
					f.write('Left Image Pairs of Ex_2:\nImage Number:%d\nPairs:%s\n'\
						%(self.Images.nImg,len(self.Images.CompPairInd)))
					for im in self.Images.imlist:
						f.write(im + '\n')
					for Inds in self.Images.CompPairInd:
						f.write(str(Inds[0]) + ' ' + str(Inds[1]) + '\n')
				event.accept()
			else:
				event.ignore()

	def LoadRemainData(self):
		f = open('result\ex_2_left.txt','r')
		data = f.readlines()
		f.close()
		self.Images.nImg = int(data[1][:-1].split(':')[1])
		PairNum = int(data[2][:-1].split(':')[1])
		self.Images.imlist = []
		self.Images.AQI = []
		self.Images.Level = []
		self.Images.CompPairInd =[]
		for i in range(self.Images.nImg):
			ImageName = data[i+3][:-1]
			self.Images.imlist.append(ImageName)
			ind_first = ImageName.find('-')
			ind_second = ImageName.find('-',ind_first+1)
			aqi = int(ImageName[ind_first+1:ind_second])
			self.Images.AQI.append(aqi)
			self.Images.Level.append(6 if aqi > 300 else aqi//50+1)		
		for j in range(PairNum):
			ind = data[j+3+self.Images.nImg][:-1].split(' ')
			self.Images.CompPairInd.append([int(ind[0]),int(ind[1])])
		self.nextPair()

	def createPixmapLabel(self):		
		label = QtGui.QLabel()
		label.setEnabled(True)
		label.setScaledContents(True)
		label.setAlignment(QtCore.Qt.AlignCenter)
		#label.setFrameShape(QtGui.QFrame.Box)
		#label.setSizePolicy(QtGui.QSizePolicy.Expanding,
		#        QtGui.QSizePolicy.Expanding)
		label.setBackgroundRole(QtGui.QPalette.Base)
		#label.setAutoFillBackground(True)
		#label.setMinimumSize(420,420)

		return label