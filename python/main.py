command = ""

while command.lower != "quit":
    command = input("> ")
    if command == "help":
        print("""
        website - to show my website URL
        friends - to show my friends list
        to do - to show to do list""")
    if command == "website":
        print("https://junha2010.github.io/ ctrl + click to open")
    if command == "friends":
        print("""Damien, Erik""")
    if command == "to do":
        print("""
        complate Python and Pygame
        complate JavaScript
        """)