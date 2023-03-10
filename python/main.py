weight = int(input("Weight: "))
unit = input("(K)g or (L)bs: ")
if unit == "K":
    converted = weight / 0.45
    print("Weight in  Lbs:" + str(converted))
else:
    converted = weight * 0.45
    print("Weight in Kgs:" + str(converted))

