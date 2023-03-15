<<<<<<< HEAD
message = input(">>>")
words = message.split(' ')
emojis = {
    ":)": "😊",
    ":(": "😢",
}
output = ""
for word in words:
    output += emojis.get(word, word) + " "
print(output)
=======
from datetime import date
import os

# help 1 => print help 1 description
# help 2 => print help 2 description
# id 1 => print id no. 1's information
# id 2 => print id no. 2's information
# > help 1
# *** Help ***
# This is help 1

# > help 2
# *** Help ***
# this is help 2

# > help
# Please input like the below:
# help <number>

# > help <number without 1 or 2>
# *** help **
# wrong help
# 
# 
# How to do
# 
# print("-email")
# print(".", end="")
# print(".", end="")
# print("-email1")
# print(" ", end="")
# print(" ", end="")
# print("-email2")
# 
# 
command = ""

while True:
    command = input("> ")

    if command == "quit":
        break

    elif command == "help":
        print("""website - to show my website URL
        friends - to show my friends list
        to do - to show to do list
        ID - to show my ID
        date - to show todays date""")
    elif command == "website":
        print("https://junha2010.github.io/ ctrl + click to open")
    elif command == "friends":
        print("""Damien, Erik""")
    elif command == "to do":
        print("""
        complate Python and Pygame
        complate JavaScript
        """)
    elif command == "ID":
        print("""birth year: 2010
        phone: 1234-1234-1234
        email: heavenly.junha@gmail.com, junhapark2010@gmail.com, park8325@wrdsb.ca, junhapark10@hotmail.com
        family: MOM(soyoung), DAD(sungho), SISTER(juha), ME(junha)
        """)
    elif command == "date":
        today = date.today()
        print("Today's date:", today)

    else:
        print("Wrong command: " + command)
>>>>>>> 7375e81725a698d1319d18e3d5d945a1dda629c8
