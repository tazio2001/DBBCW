import decimal
import random

def getInsert(table, values):
    return "INSERT INTO " + table + " VALUES (" + values + ")"

customerTypes = ['retail', 'wholesale']


def gc(val):
    return "\'" + str(val) + "\'"

def getNum():
    return "07" + str("%0.8d" % random.randint(0,99999999))

def cNum():
    return str("%0.16d" % random.randint(0,9999999999999999))

def um():
    return str("%0.6d" % random.randint(0,999999))

def getDate():
    return str(2000 + random.randint(15,21)) + "-" + str("%0.2d" % random.randint(1,12)) + "-"+ str("%0.2d" % random.randint(1,30))

def cusType(i):
    if(i < 21):
        return gc("retail")
    else:
        return gc("wholesale")

def empType(i):
    department = ['marketing', 'shipping', 'purchasing']
    if(i<20):
        return "administration"
    elif(i<40):
        return "sales"
    elif(i<60):
        return "technology"
    else:
        return department[i % 3]


def eml():
    return "email" + str(random.randint(0,1000)) + "@email.com"

def adres():
    return str(random.randint(0,1000)) + "Street, London"

def booll(i):
    if(i % 3 == 0):
        return gc('yes')
    else:
        return gc('no')

def money():
    return float(decimal.Decimal(random.randrange(10000, 20090))/100)

def bigmoney():
    return float(decimal.Decimal(random.randrange(100000, 300900))/100)


def getCustomers(i):
    return [gc("Customer" + str(i)), gc(getNum()), "NULL", "NULL", cusType(i + 1)]

def getRetail(i):
    return [i + 1, gc("retail"), gc(cNum()), gc("Visa"), gc("%0.2d" % random.randint(1,12) + "/" + "2025"), gc(eml()) ]

def getWhole(i):
    return [i + 21, gc("wholesale"), gc("contact" + str(i)), gc(getNum()), gc(eml()), gc(adres()), gc(adres()),gc(um()), 0.00, booll(i), gc(um())]

def getEmployee(i): 
    return [gc(empType(i)), gc("Empl" + str(i)), gc("Oyee" + str(i)), gc(adres()), bigmoney(), gc(um())]

def getAdmin(i):
    titles = ['Manager', 'Director', 'leader']
    return [i+1, gc(titles[i % 3]), money()]

def getSaleRep(i):
    return [i + 21, "0.00"]

def getTech(i):
    cert = ['Master degree', '2 month course', '6 month course', 'Bachelor Degree', "Apprenticeship Diploma"]
    area = ['Breakes', 'Engine', 'Transmission', 'Body']
    return [i + 41, gc(area[i % 4] + " Technician"), gc(cert[i % 5])]

def getPart(i):
    return [gc("Description Text"), money(), random.randint(1,20), random.randint(20,50), random.randint(1,20), 0,  gc('In Stock'), random.randint(1,20)]


def getCar(i):
    manuf = ["audi", "mercedes", "bwm", "prosche"]
    alph = ['a', 'e', 'g', 'q', 't', 's', 'j', 'se', 'tv', 'i']
    return [gc(manuf[i % 4]), gc(alph[i % 10]), 1971 + random.randint(0,50)]

def getSupplier(i):
    return [gc('supplier' + str(i))  , gc(getNum()), gc(eml()), "0"]

def getComp(i):
    return [random.randint(1,20), random.randint(1,20)]

tables = ['Customer', 'Retail', 'Wholesale', 'Employee', 'Administrator', 'SalesRepresentative', 'Specialist', 'Supplier', 'Part', 'CarModel', 'PartCompatibility', 'SalesOrder', 'OrderItem']
funcs = [getCustomers, getRetail, getWhole, getEmployee, getAdmin, getSaleRep, getTech, getSupplier, getPart, getCar, getComp]
ranges = [40, 20, 20, 70, 20, 20, 20, 20, 20, 20, 20]

# --date , cusid , id,address, adddress, money, money, no , incomplete
# --id, pid, qauntity, requested, unitprice


def getOS(i):
    return ["getdate()", random.randint(1, 39), random.randint(1, 20), gc("random billing address"), gc("random shipping address"), 0.00, 0.00, gc('yes'), gc('incomplete')]

def getOI(i): 
    return [i, random.randint(1, 20), gc('yes'), random.randint(1, 5), 0.00]

def vts(val):
    vals = ""
    for i in val:
        vals += str(i) + ", "

    s = len(vals)
    return vals[:s-2]

def tabIns(rang, table, func):
    for i in range(0,rang):
        vals = func(i)
        print(getInsert(table ,vts(vals)))

'''for i in range(0, 11):
    print("-- "+ tables[i] + " Inserts \n")
    tabIns(ranges[i], tables[i], funcs[i])
    print("go")
    print("\n")
    


print('-- inserts into SalesOrder and OrderItems')
for i in range(1, 21):
    print(getInsert('SalesOrder' ,vts(getOS(i))))
    y = random.randint(2, 4)
    for b in range(y):
        print(getInsert('OrderItem' ,vts(getOI(i))))

print("go")
'''
for i in range(1002, 1160):
    #print(getInsert('SalesOrder' ,vts(getOS(i))))
    y = random.randint(2, 4)
    for b in range(y):
        print(getInsert('OrderItem' ,vts(getOI(i))))

    if((i % 5) == 0):
        print('go')
        print('exec resetStock')
        print('go')