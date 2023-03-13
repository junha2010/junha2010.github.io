from datetime import date

command = ""
is_cul = False



while command.lower != "quit":
    command = input("> ")
    if command == "help":
        print("""
        website - to show my website URL
        friends - to show my friends list
        to do - to show to do list
        ID - to show my ID
        date - to show todays date""")
    if command == "website":
        print("https://junha2010.github.io/ ctrl + click to open")
    if command == "friends":
        print("""Damien, Erik""")
    if command == "to do":
        print("""
        complate Python and Pygame
        complate JavaScript
        """)
    if command == "ID":
        print("""birth year: 2010
        phone: 1234-1234-1234
        email: heavenly.junha@gmail.com, junhapark2010@gmail.com, park8325@wrdsb.ca, junhapark10@hotmail.com
        family: MOM(soyoung), DAD(sungho), SISTER(juha), ME(junha)
        """)
    if command == "date":
        today = date.today()
        print("Today's date:", today)
    