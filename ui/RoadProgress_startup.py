# Issues with sizing of forms. This shoudl run at startup and set to sensible values

from PyQt5 import QtWidgets

def my_form_open(dialog, layer, feature):
    dialog.parent().setFixedWidth(250)
    dialog.parent().setFixedHeight(110)
    dialog.parent().setSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)

    #sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.MinimumExpanding, QtWidgets.QSizePolicy.MinimumExpanding)
    #sizePolicy.setHorizontalStretch(0)
    #sizePolicy.setVerticalStretch(0)

    #dialog.parent().setSizePolicy(sizePolicy)
