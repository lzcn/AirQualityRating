#!/usr/bin/python
# -*- coding: UTF-8 -*-
import sys
import os
import pickle
from PyQt4 import QtGui, QtCore, Qt
from experiments import ExofClass, ExofComp, Extra

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

class Login(QtGui.QDialog):
	def __init__(self):
		super(Login, self).__init__()
		self.initUI()

	def initUI(self):
		self.setWindowTitle('Login')
		self.setWindowIcon(QtGui.QIcon('icons/idle.ico'))
		btn_SignIn = QtGui.QPushButton('Sign In')
		btn_SignUp = QtGui.QPushButton('Sign Up')
		btn_SignIn.clicked.connect(self.SignIn)
		btn_SignUp.clicked.connect(self.SignUp)
		lname = QtGui.QLabel('Username')
		lpass = QtGui.QLabel('Password')
		self.name = QtGui.QLineEdit(self)
		self.name.setPlaceholderText('Username')
		self.password = QtGui.QLineEdit(self)
		self.password.setEchoMode(QtGui.QLineEdit.Password)
		self.password.setPlaceholderText('Password')
		grid = QtGui.QGridLayout()
		grid.addWidget(lname, 0 , 0)
		grid.addWidget(self.name, 1, 0)
		grid.addWidget(lpass, 2, 0)
		grid.addWidget(self.password, 3, 0)
		# singin signup buttons
		hbox = QtGui.QHBoxLayout()
		hbox.addWidget(btn_SignIn)
		hbox.addWidget(btn_SignUp)
		grid.addLayout(hbox, 4, 0)
		self.setLayout(grid)
	def SignIn(self):
		# read username and password
		UserSet = {}
		if os.path.exists('users.pickle'):
			with open('users.pickle','rb') as f:
				UserSet = pickle.load(f)
		username = str(self.name.text())
		# if username exists with right password
		# accpet and show main window
		if username not in UserSet:
			QtGui.QMessageBox.information(self, "SingIn", "Uesrname not exit!")
			self.name.clear()
		elif self.password.text() != UserSet[username]:
			QtGui.QMessageBox.information(self, "SignIn", "Wrong Password!")
			self.password.clear()
		else:
			self.window = Window(username)
			self.window.show()
			self.accept()
	def SignUp(self):
		# sign up for new user
		self.hide()
		signup = Input()
		signup.show()
		signup.exec_()
		self.show()
		

class Input(QtGui.QDialog):
	"""Sign Up"""
	def __init__(self):
		super(Input, self).__init__()
		# get the username and password
		self.__UserSet = {}
		if os.path.exists('users.pickle'):
			with open('users.pickle','rb') as f:
				self.__UserSet = pickle.load(f)
		self.initUI()
	def initUI(self):
		self.setWindowTitle('SignUp')
		self.setWindowIcon(QtGui.QIcon('icons/idle.ico'))
		btn_Confirm = QtGui.QPushButton('Confirm')
		btn_Confirm.clicked.connect(self.Confirm)
		# labels for name password and confirm password
		lname = QtGui.QLabel('Username')
		self.lnameStatu = QtGui.QLabel(u'\u2610')
		lpass = QtGui.QLabel('Password')
		self.lpassStatu = QtGui.QLabel(u'\u2610')
		lrepass = QtGui.QLabel('Confirm Password')
		self.lrepassStatu = QtGui.QLabel(u'\u2610')
		# line edits for name,password and confirm password
		self.name = QtGui.QLineEdit(self)
		self.name.setPlaceholderText('Username')
		self.password = QtGui.QLineEdit(self)
		self.password.setEchoMode(QtGui.QLineEdit.Password)
		self.password.setPlaceholderText('Password')
		self.repass = QtGui.QLineEdit(self)
		self.repass.setEchoMode(QtGui.QLineEdit.Password)
		self.repass.setPlaceholderText('Confirm Password')
		# set layout
		grid = QtGui.QGridLayout()
		# username
		hNameBox = QtGui.QHBoxLayout()
		hNameBox.addWidget(self.name)
		hNameBox.addWidget(self.lnameStatu)
		grid.addWidget(lname, 0 , 0)
		grid.addLayout(hNameBox, 1, 0)
		# first password 
		hPassBox = QtGui.QHBoxLayout()
		hPassBox.addWidget(self.password)
		hPassBox.addWidget(self.lpassStatu)		
		grid.addWidget(lpass, 2, 0)
		grid.addLayout(hPassBox, 3, 0)
		# re password
		hRepassBox = QtGui.QHBoxLayout()
		hRepassBox.addWidget(self.repass)
		hRepassBox.addWidget(self.lrepassStatu)		
		grid.addWidget(lrepass, 4, 0)
		grid.addLayout(hRepassBox, 5, 0)
		# singin signup buttons
		hbox = QtGui.QHBoxLayout()
		hbox.addWidget(btn_Confirm)
		grid.addLayout(hbox, 6, 0)
		self.setLayout(grid)
		# line edits text changed callback
		self.name.textChanged.connect(self.onChanged)
		self.password.textChanged.connect(self.onChanged)
		self.repass.textChanged.connect(self.onChanged)
	def onChanged(self):
		if self.name.text() in self.__UserSet:
			self.lnameStatu.setText(u'\u2612')
		else :
			self.lnameStatu.setText(u"\u2611")
		if self.password.text() == self.repass.text():
			self.lpassStatu.setText(u'\u2611')
			self.lrepassStatu.setText(u'\u2611')
		else :
			self.lpassStatu.setText(u'\u2612')
			self.lrepassStatu.setText(u'\u2612')
	def Confirm(self):
		if self.name.text() in self.__UserSet:
			QtGui.QMessageBox.information(self, "LoginUp", "Name has been used!")
		elif self.password.text() != self.repass.text():
			QtGui.QMessageBox.information(self, "LoginUp", "Passwords do not match!")
		else:
			self.__UserSet[str(self.name.text())] = str(self.password.text())
			with open('users.pickle','wb') as f:
				pickle.dump(self.__UserSet, f)
			self.accept()

class Window(QtGui.QWidget):  # inherit 
	def __init__(self, username):
		super(Window, self).__init__()
		self.__resultFolder = os.path.join('result', username)
		if not os.path.isdir('result'):
			os.mkdir('result')
		if not os.path.isdir(self.__resultFolder):
			os.mkdir(self.__resultFolder)
		self.initUI()

	def initUI(self):
		self.setWindowTitle('Learn PyQt')
		self.resize(350, 250)
		self.center()
		self.setWindowIcon(QtGui.QIcon('icons/idle.ico'))
		#set buttons
		btn_ex1 = QtGui.QPushButton(_fromUtf8("进入实验1"), self)
		#btn_ex1.move(50,50)
		btn_ex2 = QtGui.QPushButton(_fromUtf8(("进入实验2")), self)
		#btn_ex2.move(200,50)
		#connect buttons
		self.connect(btn_ex1, QtCore.SIGNAL('clicked()'),
			self.enter_ex1)
		self.connect(btn_ex2, QtCore.SIGNAL('clicked()'),
			self.enter_ex2)
		grid = QtGui.QGridLayout()
		self.setLayout(grid)
		label1 = QtGui.QLabel(self)
		label2 = QtGui.QLabel(self)
		label1.setText(_fromUtf8("实验1：空气质量分类\n" \
			+ "1.将给出一张图片，根据这张图片判断空气质量等级。\n" \
			+ "2.空气质量等级将分为6级，1级代表最好，6级代表最差。\n" \
			+ "3.选择图片下方相应的按钮进行评价。"))
		label2.setText(_fromUtf8(("实验2：空气质量比较\n"  \
			+ "1.将给出两张图片，根据这两张图片，给出自己的判断。\n" \
			+ "2.给出认为空气质量较好的那张图片\n" \
			+ "3.点击对应图片下方的按钮做出选择")))
		grid.addWidget(label1, 0, 0)
		grid.addWidget(label2, 0, 1)
		grid.addWidget(btn_ex1, 1, 0)
		grid.addWidget(btn_ex2, 1, 1)
		# set statusbar
		#self.statusBar().showMessage('Ready')
	def	center(self):
		"move to center of screen"
		# get the size of screen
		screen = QtGui.QDesktopWidget().screenGeometry()
		#self size
		size = self.geometry()
		self.move((screen.width() - size.width()) / 2,
			(screen.height() - size.height()) / 2)

	def enter_ex1(self):
		"Enter experiment 1 "
		self.extra = Extra()
		self.extra.show()
		self.extra.exec_()
		self.ex1 = ExofClass(self.__resultFolder)
		self.ex1.show()

	def enter_ex2(self):
		"Enter experiment 2"
		self.ex2 = ExofComp(self.__resultFolder)
		self.ex2.show()
if __name__ == '__main__':
	app = QtGui.QApplication(sys.argv)
	login = Login()
	login.show()
	sys.exit(app.exec_())
